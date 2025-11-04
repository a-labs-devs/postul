import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'voice_instructions_service.dart';

class NavigationService {
  // IMPORTANTE: Esta key precisa ter Directions API habilitada no Google Cloud Console
  // Mesma key do backend (GOOGLE_PLACES_API_KEY)
  final String apiKey = 'AIzaSyBCU-x2XxajmJLUlnMhnKP5CnOqH0opsro';
  final VoiceInstructionsService voiceService = VoiceInstructionsService();
  
  StreamController<Position> positionStreamController = StreamController<Position>.broadcast();
  StreamController<NavigationState> navigationStateController = StreamController<NavigationState>.broadcast();
  
  List<LatLng> routePoints = [];
  List<RouteStep> routeSteps = [];
  int currentStepIndex = 0;
  bool isNavigating = false;
  
  LatLng? destination;
  Position? lastPosition;
  double totalDistance = 0;
  double remainingDistance = 0;
  int estimatedTimeSeconds = 0;
  double currentSpeed = 0;
  
  StreamSubscription<Position>? _positionSubscription;
  
  // ✅ NOVO: Timer para controlar atualizações da UI
  Timer? _uiUpdateTimer;
  DateTime? _lastUIUpdate;
  static const _uiUpdateInterval = Duration(milliseconds: 500); // Atualiza UI 2x por segundo

  Future<void> startNavigation(LatLng start, LatLng end) async {
    destination = end;
    isNavigating = true;
    
    await _fetchRoute(start, end);
    await voiceService.initialize();
    _startPositionTracking();
    
    if (routeSteps.isNotEmpty) {
      _speakNextInstruction();
    }
  }

  void _startPositionTracking() {
    // ✅ OTIMIZADO: Atualiza a cada 10 metros ao invés de 5
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // ✅ 10 metros - mais suave
      ),
    ).listen((Position position) {
      lastPosition = position;
      currentSpeed = position.speed * 3.6;
      
      // ✅ Sempre adiciona posição (preciso para rastreamento)
      positionStreamController.add(position);
      
      // ✅ Calcula navegação sempre, mas só atualiza UI de forma controlada
      _updateNavigationCalculations(position);
    });
    
    // ✅ NOVO: Timer separado para atualizar UI de forma controlada
    _uiUpdateTimer = Timer.periodic(_uiUpdateInterval, (_) {
      if (isNavigating && lastPosition != null) {
        _emitNavigationState();
      }
    });
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${start.latitude},${start.longitude}'
      '&destination=${end.latitude},${end.longitude}'
      '&key=$apiKey'
      '&language=pt-BR'
    );

    try {
      print('📍 Buscando rota no Google Maps...');
      
      final response = await http.get(url);

      print('📍 Status da API: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          // Decodificar polyline
          final polylinePoints = PolylinePoints();
          final String encodedPolyline = route['overview_polyline']['points'];
          final List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(encodedPolyline);
          
          routePoints = decodedPoints.map((point) {
            return LatLng(point.latitude, point.longitude);
          }).toList();
          
          totalDistance = leg['distance']['value'].toDouble();
          remainingDistance = totalDistance;
          estimatedTimeSeconds = leg['duration']['value'].toInt();

          // Extrair steps
          final steps = leg['steps'] as List;
          routeSteps = steps.map((step) {
            return RouteStep(
              instruction: step['html_instructions']?.toString().replaceAll(RegExp(r'<[^>]*>'), '') ?? '',
              distance: step['distance']['value'].toDouble(),
              duration: step['duration']['value'].toInt(),
              type: step['maneuver']?.toString() ?? 'straight',
              name: '',
            );
          }).toList();

          currentStepIndex = 0;
          print('✅ Rota calculada: ${routePoints.length} pontos, ${routeSteps.length} passos');
          
          // Emitir primeiro estado
          _emitNavigationState();
        } else {
          print('❌ Erro na resposta: ${data['status']}');
          if (data['error_message'] != null) {
            print('Mensagem: ${data['error_message']}');
          }
          _createFallbackRoute(start, end);
        }
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        _createFallbackRoute(start, end);
      }
    } catch (e) {
      print('❌ Erro ao buscar rota: $e');
      _createFallbackRoute(start, end);
    }
  }

  void _createFallbackRoute(LatLng start, LatLng end) {
    print('📍 Usando rota simples (fallback)');
    routePoints = [start, end];
    totalDistance = _calculateDistance(start, end);
    estimatedTimeSeconds = ((totalDistance / 1000) / 50 * 3600).toInt();
    
    routeSteps = [
      RouteStep(
        instruction: 'Siga em frente até o destino',
        distance: totalDistance,
        duration: estimatedTimeSeconds,
        type: 'straight',
        name: 'Rota direta',
      ),
    ];
    currentStepIndex = 0;
    remainingDistance = totalDistance;
    
    // Emitir estado inicial
    _emitNavigationState();
  }

  void _emitNavigationState() {
    if (routeSteps.isEmpty || currentStepIndex >= routeSteps.length) {
      return;
    }
    
    // ✅ Só emite se passou tempo suficiente desde última atualização
    final now = DateTime.now();
    if (_lastUIUpdate != null && 
        now.difference(_lastUIUpdate!) < _uiUpdateInterval) {
      return;
    }
    _lastUIUpdate = now;
    
    final currentLatLng = lastPosition != null 
        ? LatLng(lastPosition!.latitude, lastPosition!.longitude)
        : routePoints.first;
    
    final nextStepPoint = _getStepEndPoint(currentStepIndex);
    final distanceToNextStep = _calculateDistance(currentLatLng, nextStepPoint);
    
    navigationStateController.add(NavigationState(
      currentStep: routeSteps[currentStepIndex],
      distanceToNextStep: distanceToNextStep,
      remainingDistance: remainingDistance,
      estimatedTime: estimatedTimeSeconds,
      currentSpeed: currentSpeed,
      currentStepIndex: currentStepIndex,
      totalSteps: routeSteps.length,
    ));
  }

  // ✅ NOVO: Separa cálculos da atualização de UI
  void _updateNavigationCalculations(Position position) {
    if (!isNavigating || routeSteps.isEmpty) return;

    final currentLatLng = LatLng(position.latitude, position.longitude);
    
    if (currentStepIndex < routeSteps.length) {
      final nextStepPoint = _getStepEndPoint(currentStepIndex);
      final distanceToNextStep = _calculateDistance(currentLatLng, nextStepPoint);

      remainingDistance = _calculateRemainingDistance(currentLatLng);
      
      if (currentSpeed > 5) {
        estimatedTimeSeconds = ((remainingDistance / 1000) / currentSpeed * 3600).toInt();
      }

      // ✅ Avançar para próximo passo
      if (distanceToNextStep < 20) {
        currentStepIndex++;
        if (currentStepIndex < routeSteps.length) {
          _speakNextInstruction();
        } else {
          _arriveAtDestination();
        }
      } 
      // ✅ Avisar quando estiver próximo
      else if (distanceToNextStep < 200 && distanceToNextStep > 150) {
        _speakNextInstruction();
      }

      // ✅ Verificar se saiu da rota
      if (_isOffRoute(currentLatLng)) {
        _recalculateRoute(currentLatLng);
      }
    }
  }

  void _speakNextInstruction() {
    if (currentStepIndex >= routeSteps.length) return;
    
    final step = routeSteps[currentStepIndex];
    final instruction = voiceService.getInstructionText(
      step.instruction,
      step.distance,
    );
    
    voiceService.speak(instruction);
  }

  bool _isOffRoute(LatLng currentPosition) {
    double minDistance = double.infinity;
    
    for (var point in routePoints) {
      final distance = _calculateDistance(currentPosition, point);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    
    return minDistance > 50;
  }

  Future<void> recalculateRoute(LatLng currentPosition) async {
    if (destination == null) return;
    
    voiceService.speak("Recalculando rota");
    await _fetchRoute(currentPosition, destination!);
    currentStepIndex = 0;
  }
  
  Future<void> _recalculateRoute(LatLng currentPosition) async {
    await recalculateRoute(currentPosition);
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const distance = Distance();
    return distance.as(LengthUnit.Meter, point1, point2);
  }

  double _calculateRemainingDistance(LatLng currentPosition) {
    double distance = 0;
    
    final nextPoint = _getStepEndPoint(currentStepIndex);
    distance += _calculateDistance(currentPosition, nextPoint);
    
    for (int i = currentStepIndex + 1; i < routeSteps.length; i++) {
      distance += routeSteps[i].distance;
    }
    
    return distance;
  }

  LatLng _getStepEndPoint(int stepIndex) {
    double accumulatedDistance = 0;
    
    for (int i = 0; i <= stepIndex; i++) {
      accumulatedDistance += routeSteps[i].distance;
    }
    
    double currentDistance = 0;
    for (int i = 0; i < routePoints.length - 1; i++) {
      final segmentDistance = _calculateDistance(routePoints[i], routePoints[i + 1]);
      if (currentDistance + segmentDistance >= accumulatedDistance) {
        return routePoints[i + 1];
      }
      currentDistance += segmentDistance;
    }
    
    return routePoints.last;
  }

  void _arriveAtDestination() {
    voiceService.speak("Você chegou ao seu destino");
    stopNavigation();
  }

  void stopNavigation() {
    isNavigating = false;
    _positionSubscription?.cancel();
    _uiUpdateTimer?.cancel(); // ✅ Cancela timer de UI
    voiceService.stop();
    
    routePoints.clear();
    routeSteps.clear();
    currentStepIndex = 0;
    _lastUIUpdate = null;
  }

  String getManeuverIcon(String instruction) {
    final lower = instruction.toLowerCase();
    
    if (lower.contains('direita') || lower.contains('right')) return '→';
    if (lower.contains('esquerda') || lower.contains('left')) return '←';
    if (lower.contains('frente') || lower.contains('straight') || lower.contains('continue')) return '↑';
    if (lower.contains('rotunda') || lower.contains('rotatória') || lower.contains('roundabout')) return '↻';
    if (lower.contains('chegou') || lower.contains('destino') || lower.contains('arrive')) return '📍';
    
    return '↑';
  }

  void dispose() {
    _positionSubscription?.cancel();
    _uiUpdateTimer?.cancel(); // ✅ Cancela timer de UI
    positionStreamController.close();
    navigationStateController.close();
    voiceService.dispose();
  }
}

class RouteStep {
  final String instruction;
  final double distance;
  final int duration;
  final String type;
  final String name;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.type,
    required this.name,
  });
}

class NavigationState {
  final RouteStep currentStep;
  final double distanceToNextStep;
  final double remainingDistance;
  final int estimatedTime;
  final double currentSpeed;
  final int currentStepIndex;
  final int totalSteps;

  NavigationState({
    required this.currentStep,
    required this.distanceToNextStep,
    required this.remainingDistance,
    required this.estimatedTime,
    required this.currentSpeed,
    required this.currentStepIndex,
    required this.totalSteps,
  });
}