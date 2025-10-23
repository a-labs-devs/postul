import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../services/navigation_service.dart';
import '../models/posto.dart';

class TelaNavegacao extends StatefulWidget {
  final Posto destino;
  final LatLng origem;

  TelaNavegacao({
    required this.destino,
    required this.origem,
  });

  @override
  _TelaNavegacaoState createState() => _TelaNavegacaoState();
}

class _TelaNavegacaoState extends State<TelaNavegacao> {
  final MapController _mapController = MapController();
  final NavigationService _navService = NavigationService();
  
  NavigationState? _navState;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<NavigationState>? _navStateSubscription;
  
  bool _menuAberto = false;
  double _zoomLevel = 18.0;
  bool _seguindoUsuario = true;

  @override
  void initState() {
    super.initState();
    _iniciarNavegacao();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _navStateSubscription?.cancel();
    _navService.dispose();
    super.dispose();
  }

  Future<void> _iniciarNavegacao() async {
    final destino = LatLng(widget.destino.latitude, widget.destino.longitude);
    
    // Iniciar navegação
    await _navService.startNavigation(widget.origem, destino);
    
    // Escutar mudanças de posição
    _positionSubscription = _navService.positionStreamController.stream.listen((position) {
      if (!mounted) return;
      
      setState(() {
        _currentPosition = position;
      });
      
      // Mover mapa seguindo usuário
      if (_seguindoUsuario) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          _zoomLevel,
        );
      }
    });
    
    // Escutar mudanças de navegação
    _navStateSubscription = _navService.navigationStateController.stream.listen((state) {
      if (!mounted) return;
      
      setState(() {
        _navState = state;
      });
    });
  }

  void _voltarParaTelaMapa() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('Cancelar Navegação?'),
          ],
        ),
        content: Text('Tem certeza que deseja sair da navegação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              _navService.stopNavigation();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Sim, Sair'),
          ),
        ],
      ),
    );
  }

  String _formatarTempo(int segundos) {
    if (segundos < 60) return '${segundos}s';
    
    final minutos = segundos ~/ 60;
    if (minutos < 60) return '${minutos} min';
    
    final horas = minutos ~/ 60;
    final minutosRestantes = minutos % 60;
    return '${horas}h ${minutosRestantes}min';
  }

  String _formatarDistancia(double metros) {
    if (metros < 1000) {
      return '${metros.toInt()} m';
    } else {
      return '${(metros / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MAPA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.origem,
              initialZoom: _zoomLevel,
              minZoom: 10.0,
              maxZoom: 20.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _seguindoUsuario = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.postul',
              ),
              
              // ROTA
              if (_navService.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _navService.routePoints,
                      color: Colors.blue,
                      strokeWidth: 6.0,
                      borderColor: Colors.white,
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),
              
              // MARCADORES
              MarkerLayer(
                markers: [
                  // Posição atual
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  
                  // Destino
                  Marker(
                    point: LatLng(widget.destino.latitude, widget.destino.longitude),
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.local_gas_station,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Text(
                            widget.destino.nome.split(' ')[0],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // PAINEL SUPERIOR - INSTRUÇÕES
          if (_navState != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20, 50, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instrução principal
                    Row(
                      children: [
                        // Ícone da manobra
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _navService.getManeuverIcon(_navState!.currentStep.instruction),
                              style: TextStyle(
                                fontSize: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        
                        // Texto da instrução
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatarDistancia(_navState!.distanceToNextStep),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _navState!.currentStep.instruction,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Barra de progresso
                    SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _navState!.currentStepIndex / _navState!.totalSteps,
                        minHeight: 6,
                        backgroundColor: Colors.white30,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // PAINEL INFERIOR - INFORMAÇÕES
          if (_navState != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Informações principais
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoCard(
                          icon: Icons.access_time,
                          label: 'Tempo',
                          value: _formatarTempo(_navState!.estimatedTime),
                          color: Colors.blue,
                        ),
                        _buildInfoCard(
                          icon: Icons.straighten,
                          label: 'Distância',
                          value: _formatarDistancia(_navState!.remainingDistance),
                          color: Colors.green,
                        ),
                        _buildInfoCard(
                          icon: Icons.speed,
                          label: 'Velocidade',
                          value: '${_navState!.currentSpeed.toInt()} km/h',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _voltarParaTelaMapa,
                            icon: Icon(Icons.close),
                            label: Text('Sair'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _menuAberto = !_menuAberto;
                              });
                            },
                            icon: Icon(Icons.more_horiz),
                            label: Text('Opções'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          // BOTÃO RECENTRAR
          if (!_seguindoUsuario)
            Positioned(
              right: 20,
              bottom: 200,
              child: FloatingActionButton(
                heroTag: 'recentrar',
                onPressed: () {
                  setState(() {
                    _seguindoUsuario = true;
                  });
                  if (_currentPosition != null) {
                    _mapController.move(
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      _zoomLevel,
                    );
                  }
                },
                backgroundColor: Colors.blue,
                child: Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          
          // MENU DE OPÇÕES
          if (_menuAberto)
            Positioned(
              bottom: 180,
              left: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.volume_up, color: Colors.blue),
                      title: Text('Silenciar instruções'),
                      onTap: () {
                        _navService.voiceService.stop();
                        setState(() {
                          _menuAberto = false;
                        });
                      },
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.refresh, color: Colors.orange),
                      title: Text('Recalcular rota'),
                      onTap: () async {
                        if (_currentPosition != null) {
                          await _navService.recalculateRoute(
                            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          );
                        }
                        setState(() {
                          _menuAberto = false;
                        });
                      },
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.share, color: Colors.green),
                      title: Text('Compartilhar localização'),
                      onTap: () {
                        // TODO: Implementar compartilhamento
                        setState(() {
                          _menuAberto = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}