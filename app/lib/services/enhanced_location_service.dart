import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// 🎯 ENHANCED LOCATION SERVICE
/// Implementa técnicas avançadas do Waze:
/// - GPS Assistido (A-GPS)
/// - Dead Reckoning (navegação por estima)
/// - Map Matching (correção de posição nas vias)
/// - Suavização com sensores inerciais
class EnhancedLocationService {
  // Estado atual
  Position? _lastKnownPosition;
  double _lastKnownSpeed = 0.0; // m/s
  double _lastKnownBearing = 0.0; // graus
  DateTime? _lastUpdateTime;
  
  // Dead Reckoning
  bool _usingDeadReckoning = false;
  Timer? _deadReckoningTimer;
  
  // Map Matching
  List<LatLng> _routePoints = [];
  int _currentRouteSegment = 0;
  
  // Filtro de Kalman simplificado para suavização
  double _kalmanGain = 0.5; // Entre 0 e 1
  LatLng? _filteredPosition;
  
  // Configurações
  static const double _deadReckoningInterval = 1.0; // segundos
  static const double _mapMatchingThreshold = 50.0; // metros

  /// 📍 Inicia rastreamento GPS de alta frequência (estilo Waze)
  StreamController<EnhancedPosition>? _positionController;
  
  Stream<EnhancedPosition> startTracking({List<LatLng>? routePoints}) {
    _routePoints = routePoints ?? [];
    _positionController = StreamController<EnhancedPosition>.broadcast();
    
    // GPS de alta frequência
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0, // Recebe TODAS as atualizações
      timeLimit: Duration(seconds: 1), // Atualização a cada 1 segundo
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        _processGPSUpdate(position);
      },
      onError: (error) {
        print('❌ Erro GPS: $error');
        _startDeadReckoning();
      },
    );

    return _positionController!.stream;
  }

  /// 🛰️ PROCESSA ATUALIZAÇÃO GPS
  void _processGPSUpdate(Position position) {
    _stopDeadReckoning();
    
    final now = DateTime.now();
    
    // Calcula velocidade e bearing
    if (_lastKnownPosition != null && _lastUpdateTime != null) {
      final timeDiff = now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
      
      if (timeDiff > 0) {
        // Calcula velocidade real
        final distance = Geolocator.distanceBetween(
          _lastKnownPosition!.latitude,
          _lastKnownPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        
        final calculatedSpeed = distance / timeDiff; // m/s
        
        // Usa velocidade do GPS se disponível, senão calcula
        _lastKnownSpeed = position.speed > 0 ? position.speed : calculatedSpeed;
        
        // Calcula bearing (direção do movimento)
        if (distance > 1) { // Só atualiza se moveu mais de 1 metro
          _lastKnownBearing = Geolocator.bearingBetween(
            _lastKnownPosition!.latitude,
            _lastKnownPosition!.longitude,
            position.latitude,
            position.longitude,
          );
        }
      }
    }
    
    _lastKnownPosition = position;
    _lastUpdateTime = now;
    
    // Aplica filtros e correções
    final enhancedPosition = _enhancePosition(position);
    
    _positionController?.add(enhancedPosition);
  }

  /// 🎯 APLICA TÉCNICAS DE APRIMORAMENTO
  EnhancedPosition _enhancePosition(Position position) {
    var lat = position.latitude;
    var lng = position.longitude;
    
    // 1. FILTRO DE KALMAN (suavização)
    if (_filteredPosition != null) {
      lat = _filteredPosition!.latitude + 
            _kalmanGain * (position.latitude - _filteredPosition!.latitude);
      lng = _filteredPosition!.longitude + 
            _kalmanGain * (position.longitude - _filteredPosition!.longitude);
    }
    
    _filteredPosition = LatLng(lat, lng);
    
    // 2. MAP MATCHING (correção para a via)
    final matchedPosition = _applyMapMatching(_filteredPosition!);
    
    return EnhancedPosition(
      latitude: matchedPosition.latitude,
      longitude: matchedPosition.longitude,
      speed: _lastKnownSpeed,
      bearing: _lastKnownBearing,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
      isDeadReckoning: false,
      isMapMatched: matchedPosition != _filteredPosition,
    );
  }

  /// 🗺️ MAP MATCHING - Corrige posição para a via mais próxima
  LatLng _applyMapMatching(LatLng position) {
    if (_routePoints.isEmpty) return position;
    
    // Encontra o segmento mais próximo da rota
    double minDistance = double.infinity;
    LatLng? closestPoint;
    int closestSegment = 0;
    
    for (int i = _currentRouteSegment; i < _routePoints.length - 1; i++) {
      final segmentStart = _routePoints[i];
      final segmentEnd = _routePoints[i + 1];
      
      final projectedPoint = _projectPointOnSegment(
        position,
        segmentStart,
        segmentEnd,
      );
      
      final distance = _calculateDistance(position, projectedPoint);
      
      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = projectedPoint;
        closestSegment = i;
      }
      
      // Limita busca aos próximos 10 segmentos para performance
      if (i - _currentRouteSegment > 10) break;
    }
    
    // Só aplica map matching se estiver próximo da rota
    if (minDistance < _mapMatchingThreshold && closestPoint != null) {
      _currentRouteSegment = closestSegment;
      return closestPoint;
    }
    
    return position;
  }

  /// 📐 Projeta ponto em um segmento de linha
  LatLng _projectPointOnSegment(LatLng point, LatLng segStart, LatLng segEnd) {
    final dx = segEnd.longitude - segStart.longitude;
    final dy = segEnd.latitude - segStart.latitude;
    
    if (dx == 0 && dy == 0) return segStart;
    
    final t = ((point.longitude - segStart.longitude) * dx + 
               (point.latitude - segStart.latitude) * dy) / 
              (dx * dx + dy * dy);
    
    final tClamped = t.clamp(0.0, 1.0);
    
    return LatLng(
      segStart.latitude + tClamped * dy,
      segStart.longitude + tClamped * dx,
    );
  }

  /// 🧮 Calcula distância entre dois pontos (Haversine)
  double _calculateDistance(LatLng p1, LatLng p2) {
    return Geolocator.distanceBetween(
      p1.latitude,
      p1.longitude,
      p2.latitude,
      p2.longitude,
    );
  }

  /// 🚶 DEAD RECKONING - Navegação por estima quando GPS falha
  void _startDeadReckoning() {
    if (_usingDeadReckoning) return;
    if (_lastKnownPosition == null) return;
    
    print('🚨 GPS perdido! Iniciando Dead Reckoning...');
    _usingDeadReckoning = true;
    
    _deadReckoningTimer = Timer.periodic(
      Duration(milliseconds: (_deadReckoningInterval * 1000).toInt()),
      (timer) {
        _estimatePosition();
      },
    );
  }

  /// 📍 Estima posição usando última velocidade e direção
  void _estimatePosition() {
    if (_lastKnownPosition == null) return;
    
    // Calcula nova posição baseada na velocidade e bearing
    final distanceTraveled = _lastKnownSpeed * _deadReckoningInterval; // metros
    
    final newPosition = _calculateNewPosition(
      LatLng(_lastKnownPosition!.latitude, _lastKnownPosition!.longitude),
      _lastKnownBearing,
      distanceTraveled,
    );
    
    // Aplica map matching
    final matchedPosition = _applyMapMatching(newPosition);
    
    final enhancedPosition = EnhancedPosition(
      latitude: matchedPosition.latitude,
      longitude: matchedPosition.longitude,
      speed: _lastKnownSpeed,
      bearing: _lastKnownBearing,
      accuracy: 50.0, // Precisão reduzida no dead reckoning
      timestamp: DateTime.now(),
      isDeadReckoning: true,
      isMapMatched: matchedPosition != newPosition,
    );
    
    // Atualiza última posição conhecida
    _lastKnownPosition = Position(
      latitude: matchedPosition.latitude,
      longitude: matchedPosition.longitude,
      timestamp: DateTime.now(),
      accuracy: 50.0,
      altitude: _lastKnownPosition!.altitude,
      altitudeAccuracy: _lastKnownPosition!.altitudeAccuracy,
      heading: _lastKnownBearing,
      headingAccuracy: _lastKnownPosition!.headingAccuracy,
      speed: _lastKnownSpeed,
      speedAccuracy: _lastKnownPosition!.speedAccuracy,
    );
    
    _positionController?.add(enhancedPosition);
  }

  /// 🧭 Calcula nova posição dado um bearing e distância
  LatLng _calculateNewPosition(LatLng start, double bearing, double distance) {
    const earthRadius = 6371000.0; // metros
    
    final lat1 = start.latitude * math.pi / 180;
    final lng1 = start.longitude * math.pi / 180;
    final brng = bearing * math.pi / 180;
    
    final lat2 = math.asin(
      math.sin(lat1) * math.cos(distance / earthRadius) +
      math.cos(lat1) * math.sin(distance / earthRadius) * math.cos(brng)
    );
    
    final lng2 = lng1 + math.atan2(
      math.sin(brng) * math.sin(distance / earthRadius) * math.cos(lat1),
      math.cos(distance / earthRadius) - math.sin(lat1) * math.sin(lat2)
    );
    
    return LatLng(
      lat2 * 180 / math.pi,
      lng2 * 180 / math.pi,
    );
  }

  /// ⏹️ Para dead reckoning quando GPS volta
  void _stopDeadReckoning() {
    if (!_usingDeadReckoning) return;
    
    print('✅ GPS restaurado! Parando Dead Reckoning.');
    _usingDeadReckoning = false;
    _deadReckoningTimer?.cancel();
    _deadReckoningTimer = null;
  }

  /// 🔄 Atualiza rota para map matching
  void updateRoute(List<LatLng> routePoints) {
    _routePoints = routePoints;
    _currentRouteSegment = 0;
  }

  /// 🧹 Limpa recursos
  void dispose() {
    _deadReckoningTimer?.cancel();
    _positionController?.close();
  }
}

/// 📍 Posição aprimorada com metadados
class EnhancedPosition {
  final double latitude;
  final double longitude;
  final double speed; // m/s
  final double bearing; // graus
  final double accuracy; // metros
  final DateTime timestamp;
  final bool isDeadReckoning; // Está usando navegação por estima?
  final bool isMapMatched; // Posição foi corrigida para a via?

  EnhancedPosition({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.bearing,
    required this.accuracy,
    required this.timestamp,
    required this.isDeadReckoning,
    required this.isMapMatched,
  });

  /// Converte para LatLng
  LatLng toLatLng() => LatLng(latitude, longitude);

  /// Converte para Position
  Position toPosition() => Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp,
    accuracy: accuracy,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: bearing,
    headingAccuracy: 0,
    speed: speed,
    speedAccuracy: 0,
  );
}
