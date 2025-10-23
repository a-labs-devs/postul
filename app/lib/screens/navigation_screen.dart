import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/navigation_service.dart';  // ✅ CORRIGIDO
import '../services/traffic_service.dart';     // ✅ CORRIGIDO

class NavigationScreen extends StatefulWidget {
  final LatLng startLocation;
  final LatLng destinationLocation;
  final String destinationName;

  const NavigationScreen({
    Key? key,
    required this.startLocation,
    required this.destinationLocation,
    required this.destinationName,
  }) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final NavigationService _navigationService = NavigationService();
  final TrafficService _trafficService = TrafficService();
  final MapController _mapController = MapController();
  
  Position? _currentPosition;
  NavigationState? _navigationState;
  TrafficAlert? _currentAlert;
  bool _isLoading = true;
  bool _followUser = true;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  Future<void> _initializeNavigation() async {
    setState(() => _isLoading = true);

    // Listener de posição
    _navigationService.positionStreamController.stream.listen((position) {
      if (mounted) {
        setState(() => _currentPosition = position);
        
        if (_followUser) {
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            17.0,
          );
        }
      }
    });

    // Listener de estado de navegação
    _navigationService.navigationStateController.stream.listen((state) {
      if (mounted) {
        setState(() => _navigationState = state);
      }
    });

    // Listener de alertas de tráfego
    _trafficService.alertController.stream.listen((alert) {
      if (mounted) {
        setState(() => _currentAlert = alert);
        
        // Auto-hide alert após 5 segundos
        Future.delayed(Duration(seconds: 5), () {
          if (mounted && _currentAlert == alert) {
            setState(() => _currentAlert = null);
          }
        });
      }
    });

    // Iniciar navegação
    await _navigationService.startNavigation(
      widget.startLocation,
      widget.destinationLocation,
    );

    // Verificar tráfego
    await _trafficService.checkTrafficOnRoute(_navigationService.routePoints);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _navigationService.dispose();
    _trafficService.dispose();
    super.dispose();
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toInt()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      return '${(seconds / 60).toInt()} min';
    } else {
      final hours = (seconds / 3600).toInt();
      final mins = ((seconds % 3600) / 60).toInt();
      return '${hours}h ${mins}min';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Calculando melhor rota...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Mapa
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.startLocation,
              initialZoom: 17.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() => _followUser = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.postul.app',
              ),
              // Linha da rota
              if (_navigationService.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _navigationService.routePoints,
                      strokeWidth: 6.0,
                      color: Colors.blue.shade700,
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              // Marcadores
              MarkerLayer(
                markers: [
                  // Marcador de destino
                  Marker(
                    point: widget.destinationLocation,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  // Marcador de posição atual
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Painel superior - Próxima manobra
          if (_navigationState != null)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: _buildInstructionPanel(),
            ),

          // Painel inferior - Informações da viagem
          if (_navigationState != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: _buildInfoPanel(),
            ),

          // Botão de recentrar
          if (!_followUser)
            Positioned(
              bottom: 200,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                heroTag: 'recenter',
                onPressed: () {
                  setState(() => _followUser = true);
                  if (_currentPosition != null) {
                    _mapController.move(
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      17.0,
                    );
                  }
                },
                child: Icon(Icons.my_location, color: Colors.blue),
              ),
            ),

          // Botão de parar navegação
          Positioned(
            top: 50,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              mini: true,
              heroTag: 'stop',
              onPressed: _showStopNavigationDialog,
              child: Icon(Icons.close, color: Colors.white),
            ),
          ),

          // ETA (horário de chegada estimado)
          if (_navigationState != null)
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, color: Colors.white, size: 16),
                    SizedBox(width: 5),
                    Text(
                      'Chegada: ${_formatTime(_navigationState!.estimatedTime)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Alerta de velocidade (se exceder limite)
          if (_navigationState != null && _navigationState!.currentSpeed > 80)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Velocidade máxima: 80 km/h',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bússola
          if (_currentPosition != null)
            Positioned(
              top: 120,
              right: 20,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: _currentPosition!.heading * (3.14159 / 180),
                  child: Icon(
                    Icons.navigation,
                    color: Colors.blue.shade700,
                    size: 30,
                  ),
                ),
              ),
            ),

          // Botão de rota alternativa
          Positioned(
            bottom: 200,
            left: 20,
            child: FloatingActionButton.extended(
              heroTag: 'alternative',
              backgroundColor: Colors.orange,
              onPressed: _calculateAlternativeRoute,
              icon: Icon(Icons.alt_route),
              label: Text('Alternativa'),
            ),
          ),

          // Alerta de tráfego
          if (_currentAlert != null)
            Positioned(
              top: 180,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentAlert!.message,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Botão de menu
          Positioned(
            bottom: 200,
            right: 80,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              heroTag: 'menu',
              onPressed: _showNavigationMenu,
              child: Icon(Icons.more_horiz, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _showNavigationMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.alt_route, color: Colors.orange),
              title: Text('Rota Alternativa'),
              onTap: () {
                Navigator.pop(context);
                _calculateAlternativeRoute();
              },
            ),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.red),
              title: Text('Reportar Incidente'),
              onTap: () {
                Navigator.pop(context);
                _showReportIncidentDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey),
              title: Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                _openSettings();
              },
            ),
            ListTile(
              leading: Icon(Icons.add_location, color: Colors.blue),
              title: Text('Adicionar Parada'),
              onTap: () {
                Navigator.pop(context);
                _addStop();
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.green),
              title: Text('Compartilhar Localização'),
              onTap: () {
                Navigator.pop(context);
                _shareLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportIncidentDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reportar incidente em desenvolvimento'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configurações em desenvolvimento'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _addStop() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcionalidade em desenvolvimento'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link de localização copiado!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildInstructionPanel() {
    final step = _navigationState!.currentStep;
    final distance = _navigationState!.distanceToNextStep;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _navigationService.getManeuverIcon(step.instruction),
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDistance(distance),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  step.instruction,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (step.name.isNotEmpty)
                  Text(
                    step.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.destinationName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                icon: Icons.straighten,
                label: 'Distância',
                value: _formatDistance(_navigationState!.remainingDistance),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
              ),
              _buildInfoItem(
                icon: Icons.access_time,
                label: 'Tempo',
                value: _formatTime(_navigationState!.estimatedTime),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
              ),
              _buildInfoItem(
                icon: Icons.speed,
                label: 'Velocidade',
                value: '${_navigationState!.currentSpeed.toInt()} km/h',
              ),
            ],
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _navigationState!.currentStepIndex / _navigationState!.totalSteps,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade400, size: 20),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  void _showStopNavigationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Parar Navegação'),
        content: Text('Deseja realmente parar a navegação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _navigationService.stopNavigation();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Parar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateAlternativeRoute() async {
    if (_currentPosition == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 15),
            Text('Calculando rota alternativa...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    await _navigationService.recalculateRoute(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nova rota calculada!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}