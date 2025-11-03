import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../models/posto.dart';
import '../../services/Rotas_service.dart';
import '../../services/navigation_algorithm_service.dart';
import '../../services/enhanced_location_service.dart';
import '../../services/voice_instructions_service.dart';
import '../../routes/app_router.dart';

/// 🧭 POSTUL - Tela de Navegação GPS
class NavigationScreen extends StatefulWidget {
  final Posto posto;
  final LatLng origem;
  final List<LatLng>? routePoints;
  final RouteType? routeType;

  const NavigationScreen({
    Key? key,
    required this.posto,
    required this.origem,
    this.routePoints,
    this.routeType,
  }) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  String _nextInstruction = "Vire à direita";
  int _distanceToNextManeuver = 250; // metros
  String _eta = "--:--";
  double _remainingDistance = 0.0; // km
  double _currentSpeed = 0.0; // km/h
  int _currentStep = 1;
  int _totalSteps = 8;
  double _bearing = 0.0; // Direção em graus (0-360)
  double _mapBearing = 0.0; // Rotação do mapa
  List<LatLng> _routePoints = [];
  bool _loadingRoute = true;
  final RotasService _rotasService = RotasService();
  final NavigationAlgorithmService _navAlgorithm = NavigationAlgorithmService();
  final EnhancedLocationService _enhancedLocation = EnhancedLocationService();
  final VoiceInstructionsService _voiceService = VoiceInstructionsService();
  Set<google_maps.Polyline> _polylines = {};
  Set<google_maps.Marker> _markers = {};
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<EnhancedPosition>? _enhancedPositionStream;
  Position? _currentPosition;
  double _totalRouteDistance = 0.0; // km
  TrafficData? _trafficData;
  double _tempoEstimadoMinutos = 0.0;
  google_maps.GoogleMapController? _mapController;
  bool _isMapReady = false;
  bool _isUsingDeadReckoning = false; // Indicador de GPS fraco
  bool _voiceEnabled = true; // Controle de voz ativado por padrão
  bool _arrivedDialogShown = false; // Controla se já mostrou o diálogo de chegada

  double get _progress => _currentStep / _totalSteps;

  @override
  void initState() {
    super.initState();
    _initializeVoice();
    _loadRoute();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _enhancedPositionStream?.cancel();
    _enhancedLocation.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  // 🔊 Inicializar serviço de voz
  Future<void> _initializeVoice() async {
    await _voiceService.initialize();
    _voiceService.setEnabled(_voiceEnabled);
  }

  // 📍 RASTREAMENTO DE LOCALIZAÇÃO EM TEMPO REAL COM GPS ASSISTIDO
  Future<void> _startLocationTracking() async {
    // Inicia Enhanced Location Service com a rota para Map Matching
    _enhancedPositionStream = _enhancedLocation
        .startTracking(routePoints: _routePoints)
        .listen((EnhancedPosition position) {
      
      setState(() {
        // Converte EnhancedPosition para Position
        _currentPosition = position.toPosition();
        _currentSpeed = position.speed * 3.6; // m/s para km/h
        _isUsingDeadReckoning = position.isDeadReckoning;
        
        // Atualiza bearing (direção) apenas se estiver em movimento
        if (_currentSpeed > 5) {
          _bearing = position.bearing;
          _rotacionarMapa(position.bearing);
        }
        
        _calcularDistanciaRestante();
        _calcularETA();
        _atualizarMarcadorUsuario();
        _centralizarMapaNoUsuario();
      });
      
      // Log de diagnóstico
      if (position.isDeadReckoning) {
        print('🚨 Usando Dead Reckoning - GPS fraco!');
      }
      if (position.isMapMatched) {
        print('🗺️ Posição corrigida por Map Matching');
      }
    });
  }

  // 🔄 ROTACIONA O MAPA BASEADO NA DIREÇÃO DO MOVIMENTO (ESTILO WAZE)
  void _rotacionarMapa(double heading) async {
    if (_mapController != null && _isMapReady) {
      // Suaviza a rotação (evita mudanças bruscas)
      final diferencaAngulo = (heading - _mapBearing).abs();
      
      if (diferencaAngulo > 15) { // Só rotaciona se a diferença for significativa
        _mapBearing = heading;
        
        // Anima apenas o zoom e posição, sem rotação do mapa
        await _mapController!.animateCamera(
          google_maps.CameraUpdate.newCameraPosition(
            google_maps.CameraPosition(
              target: google_maps.LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              zoom: 17.5, // Zoom médio - vista aérea com contexto
              bearing: 0, // Mapa sempre voltado para o norte (sem rotação)
              tilt: 30, // Perspectiva leve (vista semi-aérea)
            ),
          ),
        );
      }
    }
  }

  // 📍 CENTRALIZA MAPA NO USUÁRIO
  void _centralizarMapaNoUsuario() async {
    if (_mapController != null && _isMapReady && _currentPosition != null) {
      await _mapController!.animateCamera(
        google_maps.CameraUpdate.newCameraPosition(
          google_maps.CameraPosition(
            target: google_maps.LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 17.5, // Zoom médio - vista aérea com contexto
            bearing: 0, // Mapa sempre voltado para o norte (sem rotação)
            tilt: 30, // Perspectiva leve (vista semi-aérea)
          ),
        ),
      );
    }
  }

  // 📏 CALCULA DISTÂNCIA RESTANTE
  void _calcularDistanciaRestante() {
    if (_currentPosition == null) return;

    final destino = LatLng(widget.posto.latitude, widget.posto.longitude);
    final origem = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    // Calcula distância em linha reta (Haversine)
    final distanceInMeters = Geolocator.distanceBetween(
      origem.latitude,
      origem.longitude,
      destino.latitude,
      destino.longitude,
    );

    _remainingDistance = distanceInMeters / 1000; // metros para km
    _distanceToNextManeuver = (distanceInMeters * 0.1).toInt(); // 10% da distância total para próxima manobra

    // Anunciar instrução de voz
    _announceNavigation(distanceInMeters);
    
    // 🎯 Verificar se chegou ao destino (menos de 50 metros)
    if (distanceInMeters < 50 && !_arrivedDialogShown) {
      _arrivedDialogShown = true;
      _mostrarDialogoChegada();
    }
  }

  // 🔊 Anunciar instrução de navegação por voz
  Future<void> _announceNavigation(double distanceInMeters) async {
    if (!_voiceEnabled || _nextInstruction.isEmpty) return;

    // Anunciar instrução baseada na distância
    await _voiceService.announceNavigation(
      instruction: _nextInstruction,
      distanceToManeuver: distanceInMeters,
      streetName: widget.posto.endereco,
    );

    // Anunciar chegada quando próximo
    if (distanceInMeters < 50) {
      await _voiceService.announceArrival();
    }
  }

  // ⏱️ CALCULA ETA (Horário de Chegada) com dados de tráfego
  void _calcularETA() {
    if (_remainingDistance <= 0) {
      _eta = DateFormat('HH:mm').format(DateTime.now());
      return;
    }

    double tempoEstimadoMinutos;

    if (_trafficData != null && _currentPosition != null) {
      // Usa dados de tráfego em tempo real
      final posicaoAtual = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      final velocidadeMedia = _trafficData!.getAverageSpeed(posicaoAtual);
      
      if (_currentSpeed >= 5) {
        // Combina velocidade atual com dados de tráfego
        final velocidadePonderada = (_currentSpeed * 0.7) + (velocidadeMedia * 0.3);
        tempoEstimadoMinutos = (_remainingDistance / velocidadePonderada) * 60;
      } else {
        // Parado: usa velocidade média do tráfego
        tempoEstimadoMinutos = (_remainingDistance / velocidadeMedia) * 60;
      }
    } else {
      // Fallback: velocidade média urbana
      if (_currentSpeed < 5) {
        tempoEstimadoMinutos = (_remainingDistance / 30) * 60; // 30 km/h parado
      } else {
        tempoEstimadoMinutos = (_remainingDistance / _currentSpeed) * 60;
      }
    }

    final chegada = DateTime.now().add(Duration(minutes: tempoEstimadoMinutos.ceil()));
    _eta = DateFormat('HH:mm').format(chegada);
  }

  // 🔄 ATUALIZA MARCADOR DO USUÁRIO COM SETA AZUL
  void _atualizarMarcadorUsuario() async {
    if (_currentPosition == null) return;

    _markers.removeWhere((m) => m.markerId.value == 'origin');
    
    // Muda cor baseado no status (Azul normal, Laranja se Dead Reckoning)
    final cor = _isUsingDeadReckoning 
        ? google_maps.BitmapDescriptor.hueOrange 
        : google_maps.BitmapDescriptor.hueAzure;
    
    _markers.add(
      google_maps.Marker(
        markerId: const google_maps.MarkerId('origin'),
        position: google_maps.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(cor),
        anchor: const Offset(0.5, 0.5), // Centraliza
        flat: true, // Permite rotação suave
        rotation: _bearing, // Rotaciona baseado na direção (0° = Norte)
        zIndex: 999, // Sempre no topo
      ),
    );
  }

  // 🚀 Carrega a rota usando ALGORITMO A* com dados de tráfego
  Future<void> _loadRoute() async {
    try {
      final destino = LatLng(widget.posto.latitude, widget.posto.longitude);
      
      // Se já temos pontos da rota (da tela de seleção), usar eles
      if (widget.routePoints != null && widget.routePoints!.isNotEmpty) {
        _routePoints = widget.routePoints!;
        _totalRouteDistance = _calcularDistanciaTotal(_routePoints);
        print('✅ Usando rota selecionada (${widget.routeType}): ${_routePoints.length} pontos, ${_totalRouteDistance.toStringAsFixed(2)} km');
      } else {
        // Caso contrário, calcular rota normalmente
        print('🧭 MÉTODO 1: Tentando API do Google Maps...');
        final rotaData = await _rotasService.calcularRota(
          origem: widget.origem,
          destino: destino,
        );

        if (rotaData != null && rotaData['pontos'] != null) {
          _routePoints = rotaData['pontos'] as List<LatLng>;
          _totalRouteDistance = _calcularDistanciaTotal(_routePoints);
          print('✅ Rota Google Maps: ${_routePoints.length} pontos, ${_totalRouteDistance.toStringAsFixed(2)} km');
        } else {
          print('⚠️ Google Maps falhou, usando ALGORITMO A*...');
          await _calcularRotaComAStar(destino);
        }
      }
    } catch (e) {
      print('❌ Erro na API: $e');
      print('🎯 Fallback: ALGORITMO A* com Haversine e Tráfego...');
      await _calcularRotaComAStar(LatLng(widget.posto.latitude, widget.posto.longitude));
    }

    // Calcular distância inicial
    _calcularDistanciaRestante();
    
    // Criar polyline e marcadores
    await _criarPolylineEMarcadores();
    
    setState(() => _loadingRoute = false);
    
    // Anunciar início da navegação
    if (_voiceEnabled) {
      await _voiceService.announceNavigationStart(widget.posto.nome);
    }
  }

  // 🎯 ALGORITMO A* - Calcula rota otimizada com tráfego
  Future<void> _calcularRotaComAStar(LatLng destino) async {
    final resultado = await _navAlgorithm.calcularRotaAStar(
      origem: widget.origem,
      destino: destino,
    );

    _routePoints = resultado.pontos;
    _totalRouteDistance = resultado.distanciaTotal;
    _tempoEstimadoMinutos = resultado.tempoEstimado;
    _trafficData = resultado.trafficData;

    print('🎯 A* Resultado:');
    print('   📍 Pontos: ${_routePoints.length}');
    print('   📏 Distância: ${_totalRouteDistance.toStringAsFixed(2)} km');
    print('   ⏱️ Tempo: ${_tempoEstimadoMinutos.toStringAsFixed(0)} min');
  }

  // Calcula distância total da rota
  double _calcularDistanciaTotal(List<LatLng> pontos) {
    double total = 0.0;
    for (int i = 0; i < pontos.length - 1; i++) {
      total += Geolocator.distanceBetween(
        pontos[i].latitude,
        pontos[i].longitude,
        pontos[i + 1].latitude,
        pontos[i + 1].longitude,
      );
    }
    return total / 1000; // metros para km
  }

  Future<void> _criarPolylineEMarcadores() async {
    // Criar polyline da rota
    final List<google_maps.LatLng> googlePoints = _routePoints
        .map((point) => google_maps.LatLng(point.latitude, point.longitude))
        .toList();

    _polylines = {
      google_maps.Polyline(
        polylineId: const google_maps.PolylineId('route'),
        points: googlePoints,
        color: const Color(0xFF2196F3), // Azul sólido
        width: 8,
      ),
    };

    // Criar marcadores
    _markers = {
      google_maps.Marker(
        markerId: const google_maps.MarkerId('origin'),
        position: google_maps.LatLng(widget.origem.latitude, widget.origem.longitude),
        icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 0.5),
        flat: true,
        rotation: _bearing,
      ),
      google_maps.Marker(
        markerId: const google_maps.MarkerId('destination'),
        position: google_maps.LatLng(widget.posto.latitude, widget.posto.longitude),
        icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueGreen),
        infoWindow: google_maps.InfoWindow(title: widget.posto.nome),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _confirmExit(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // MAPA DO GOOGLE COM ROTA (FULLSCREEN ESTILO WAZE)
            if (_loadingRoute)
              const Center(child: CircularProgressIndicator())
            else
              google_maps.GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  setState(() => _isMapReady = true);
                  
                  // Inicializa com perspectiva 3D e bearing
                  if (_currentPosition != null && _currentSpeed > 5) {
                    _rotacionarMapa(_bearing);
                  }
                },
                initialCameraPosition: google_maps.CameraPosition(
                  target: google_maps.LatLng(widget.origem.latitude, widget.origem.longitude),
                  zoom: 17.5, // Zoom médio - vista aérea com contexto
                  tilt: 30, // Perspectiva leve (vista semi-aérea)
                  bearing: 0, // Mapa sempre voltado para o norte (sem rotação)
                ),
                polylines: _polylines,
                markers: _markers,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                rotateGesturesEnabled: false, // Desabilita rotação manual
                tiltGesturesEnabled: false, // Desabilita tilt manual
                mapType: google_maps.MapType.normal,
                buildingsEnabled: true, // Mostra prédios 3D
              ),

            // CARD INSTRUÇÃO GRANDE (ESTILO WAZE PREMIUM)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 🚨 BADGE DE DEAD RECKONING (MELHORADO)
                    if (_isUsingDeadReckoning)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade300,
                              Colors.orange.shade400,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.signal_wifi_off,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sinal GPS fraco - Estimando posição',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // ROW PRINCIPAL (MELHORADO)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // ÍCONE GRANDE DA MANOBRA (MELHORADO)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.15),
                                  AppColors.primary.withOpacity(0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _getIconeManobra(),
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 20),
                          
                          // INSTRUÇÃO E DISTÂNCIA (MELHORADO)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // DISTÂNCIA EM METROS (DESTAQUE MAIOR)
                                Text(
                                  _formatarDistancia(_distanceToNextManeuver),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    height: 1.0,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // INSTRUÇÃO (MELHORADA)
                                Text(
                                  _nextInstruction,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // PAINEL INFERIOR ESTILO WAZE (REDESENHADO)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // INDICADOR DE ARRASTE (PILL)
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // INFO GRID MELHORADO (3 COLUNAS)
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCardWaze(
                                value: _eta,
                                label: 'Chegada',
                                icon: Icons.schedule,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCardWaze(
                                value: '${_remainingDistance.toStringAsFixed(1)} km',
                                label: 'Distância',
                                icon: Icons.route,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCardWaze(
                                value: '${_currentSpeed.toStringAsFixed(0)} km/h',
                                label: 'Velocidade',
                                icon: Icons.speed,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // BOTÃO SAIR (REDESENHADO)
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.shade300,
                              width: 2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _confirmExit(),
                              borderRadius: BorderRadius.circular(14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.close_rounded,
                                    color: Colors.red.shade600,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sair da navegação',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red.shade600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // BOTÃO FLUTUANTE: CONTROLE DE VOZ
            Positioned(
              right: 16,
              bottom: 290,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: _voiceEnabled ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _voiceEnabled = !_voiceEnabled;
                        _voiceService.setEnabled(_voiceEnabled);
                      });
                      CustomSnackbar.show(
                        context,
                        message: _voiceEnabled 
                          ? 'Instruções de voz ativadas'
                          : 'Instruções de voz desativadas',
                        type: _voiceEnabled 
                          ? SnackbarType.success
                          : SnackbarType.info,
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        _voiceEnabled ? Icons.volume_up : Icons.volume_off,
                        color: _voiceEnabled ? Colors.white : Colors.grey.shade600,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // BOTÃO FLUTUANTE: RECENTRALIZAR NO USUÁRIO (MELHORADO)
            Positioned(
              right: 16,
              bottom: 220,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: _centralizarMapaNoUsuario,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.my_location,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  INDICADOR DE TRÁFEGO EM TEMPO REAL
  Widget _buildTrafficIndicator() {
    if (_trafficData == null || _currentPosition == null) {
      return const SizedBox.shrink();
    }

    final posicaoAtual = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    final trafficFactor = _trafficData!.getTrafficFactor(posicaoAtual);

    Color trafficColor;
    String trafficText;
    IconData trafficIcon;

    if (trafficFactor < 1.2) {
      trafficColor = Colors.green;
      trafficText = 'Livre';
      trafficIcon = Icons.check_circle;
    } else if (trafficFactor < 1.6) {
      trafficColor = Colors.orange;
      trafficText = 'Moderado';
      trafficIcon = Icons.warning;
    } else {
      trafficColor = Colors.red;
      trafficText = 'Lento';
      trafficIcon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trafficColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: trafficColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trafficIcon, size: 14, color: trafficColor),
          const SizedBox(width: 4),
          Text(
            trafficText,
            style: AppTypography.labelSmall.copyWith(
              color: trafficColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // MÉTODO PARA CRIAR CARD DE INFORMAÇÃO OTIMIZADO
  Widget _buildInfoCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: AppColors.primary,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MÉTODO PARA CRIAR CARD DE INFORMAÇÃO ESTILO WAZE (MELHORADO)
  Widget _buildInfoCardWaze({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceVariant,
            AppColors.surfaceVariant.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: AppColors.primary,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // FORMATAR DISTÂNCIA ESTILO WAZE
  String _formatarDistancia(int metros) {
    if (metros >= 1000) {
      return '${(metros / 1000).toStringAsFixed(1)} km';
    } else if (metros >= 100) {
      return '${metros} m';
    } else {
      // Arredondar para múltiplos de 10
      final arredondado = ((metros / 10).round() * 10);
      return '$arredondado m';
    }
  }

  // OBTER ÍCONE DA MANOBRA
  IconData _getIconeManobra() {
    final instrucao = _nextInstruction.toLowerCase();
    
    if (instrucao.contains('direita')) {
      return Icons.turn_right;
    } else if (instrucao.contains('esquerda')) {
      return Icons.turn_left;
    } else if (instrucao.contains('reto') || instrucao.contains('siga')) {
      return Icons.arrow_upward;
    } else if (instrucao.contains('retorno') || instrucao.contains('u-turn')) {
      return Icons.u_turn_left;
    } else if (instrucao.contains('rotatória')) {
      return Icons.rotate_right; // Usando rotate_right ao invés de 360
    } else if (instrucao.contains('saída')) {
      return Icons.exit_to_app;
    } else if (instrucao.contains('chegou') || instrucao.contains('destino')) {
      return Icons.flag;
    } else {
      return Icons.navigation;
    }
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_outlined, color: AppColors.warning, size: 48),
        title: const Text("Sair da navegação?"),
        content: const Text("Você perderá o progresso atual"),
        actions: [
          SecondaryButton(
            label: "Cancelar",
            onPressed: () => Navigator.pop(context, false),
          ),
          PrimaryButton(
            label: "Sair",
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true) {
      if (mounted) {
        Navigator.pop(context);
      }
      return true;
    }
    return false;
  }

  /// 🎯 Diálogo de chegada ao destino
  void _mostrarDialogoChegada() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.check_circle, color: AppColors.success, size: 64),
        title: const Text("Você chegou ao seu destino!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Parabéns! Você completou a navegação.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              widget.posto.nome,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            label: "OK",
            onPressed: () {
              Navigator.pop(context); // Fecha o diálogo
              _mostrarDialogoVerificarPreco(); // Abre diálogo de verificação de preço
            },
          ),
        ],
      ),
    );
  }

  /// 💰 Diálogo para verificar e atualizar preço
  void _mostrarDialogoVerificarPreco() {
    final TextEditingController precoController = TextEditingController();
    bool precoCorreto = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          icon: Icon(Icons.local_gas_station, color: AppColors.primary, size: 48),
          title: const Text("Verificação de Preço"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "O preço do combustível estava correto?",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              
              // Botões Sim/Não
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        precoCorreto = true;
                      });
                    },
                    icon: Icon(precoCorreto ? Icons.check_circle : Icons.check_circle_outline),
                    label: const Text("Sim"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: precoCorreto ? AppColors.success : Colors.grey[300],
                      foregroundColor: precoCorreto ? Colors.white : Colors.black87,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        precoCorreto = false;
                      });
                    },
                    icon: Icon(!precoCorreto ? Icons.cancel : Icons.cancel_outlined),
                    label: const Text("Não"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !precoCorreto ? AppColors.error : Colors.grey[300],
                      foregroundColor: !precoCorreto ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              
              // Campo de preço (aparece apenas se "Não" for selecionado)
              if (!precoCorreto) ...[
                const SizedBox(height: 20),
                const Text(
                  "Qual é o preço correto?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: precoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Preço (R\$)",
                    hintText: "Ex: 5.89",
                    prefixText: "R\$ ",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            SecondaryButton(
              label: "Pular",
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo
                Navigator.pop(context); // Volta para a tela anterior
              },
            ),
            PrimaryButton(
              label: "Enviar",
              onPressed: () async {
                if (!precoCorreto) {
                  // Validar preço inserido
                  final precoTexto = precoController.text.trim();
                  if (precoTexto.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Por favor, insira o preço correto"),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  // Converter para double
                  final precoNovo = double.tryParse(precoTexto.replaceAll(',', '.'));
                  if (precoNovo == null || precoNovo <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Preço inválido"),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  // Enviar atualização para o backend
                  await _atualizarPreco(precoNovo);
                }

                Navigator.pop(context); // Fecha o diálogo
                Navigator.pop(context); // Volta para a tela anterior
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 📡 Envia atualização de preço para o backend
  Future<void> _atualizarPreco(double novoPreco) async {
    try {
      final response = await http.post(
        Uri.parse('http://alabsv.ddns.net:3001/api/precos/atualizar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'posto_id': widget.posto.id,
          'nome_posto': widget.posto.nome,
          'preco': novoPreco,
          'produto': 'Gasolina', // Tipo padrão
          'data_atualizacao': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Preço atualizado com sucesso!"),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        throw Exception('Erro ao atualizar preço: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao atualizar preço: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao atualizar preço. Tente novamente."),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }
}
