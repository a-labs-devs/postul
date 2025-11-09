import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';
import '../../models/posto.dart' as models;
import '../../models/tipos_combustivel.dart';
import '../../services/postos_service.dart';
import '../../services/ads_service.dart';
import 'app_drawer.dart';
import 'posto_detail_bottom_sheet.dart';

/// 🗺️ POSTUL - Tela Principal do Mapa
class MapScreen extends StatefulWidget {
  final int usuarioId;

  const MapScreen({Key? key, required this.usuarioId}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PostosService _postosService = PostosService();
  List<models.Posto> _postos = [];
  Set<google_maps.Marker> _markers = {};
  LatLng _userLocation = LatLng(-23.5505, -46.6333);
  LatLng _mapCenter = LatLng(-23.5505, -46.6333);
  double _mapZoom = 15.0;
  bool _isLoading = false;  // Mudado para false para não bloquear o mapa
  TipoCombustivel? _filtroAtivo;
  double _raioKm = 5.0;
  google_maps.GoogleMapController? _mapController;
  google_maps.BitmapDescriptor? _customMarker;
  google_maps.BitmapDescriptor? _userMarkerIcon;

  @override
  @override
  void initState() {
    super.initState();
    _criarIconesCustomizados();
    _obterLocalizacaoReal();
    // Carregar postos do cache imediatamente (enquanto aguarda localização e mapa)
    _carregarPostosInicial();
    
    // Mostrar dica sobre Premium após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _mostrarDicaPremium();
      }
    });
  }

  /// 💡 Mostrar dica sobre Premium
  void _mostrarDicaPremium() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          padding: EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.space16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              SizedBox(height: AppSpacing.space16),
              const Text(
                'Ganhe Premium Grátis!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.space12),
              const Text(
                'Assista um vídeo curto e ganhe 7 dias de Premium sem anúncios!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.space20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.space8,
                          horizontal: AppSpacing.space8,
                        ),
                      ),
                      child: const Text(
                        'Agora não',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.space8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Fecha o popup
                        // Mostra o anúncio Rewarded diretamente
                        AdsService().showRewardedAd(
                          onRewarded: () {
                            CustomSnackbar.show(
                              context,
                              message: '🎉 Premium ativado por 7 dias!',
                              type: SnackbarType.success,
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.space8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.button),
                        ),
                      ),
                      child: const Text(
                        'Ver Premium',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
    );
  }

  /// 📍 Carregamento inicial de postos (tenta cache primeiro)
  Future<void> _carregarPostosInicial() async {
    try {
      print('🚀 Carregando postos iniciais...');
      // Usa listarTodos que tem cache integrado
      final postos = await _postosService.listarTodos();
      
      if (postos.isNotEmpty && mounted) {
        setState(() {
          _postos = postos;
        });
        print('✅ ${postos.length} postos carregados inicialmente');
      }
    } catch (e) {
      print('⚠️ Não foi possível carregar postos iniciais: $e');
      // Não mostra erro aqui, pois o carregamento real acontecerá quando o mapa inicializar
    }
  }

  /// 📍 Obter localização real do GPS
  Future<void> _obterLocalizacaoReal() async {
    try {
      // Verificar se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Serviço de localização desabilitado');
        return;
      }

      // Verificar permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Permissão de localização negada');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Permissão de localização negada permanentemente');
        return;
      }

      // Obter posição atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _mapCenter = LatLng(position.latitude, position.longitude);
        print('✅ Localização obtida: ${position.latitude}, ${position.longitude}');
      });

      // Centralizar mapa na localização real
      if (_mapController != null) {
        _mapController!.animateCamera(
          google_maps.CameraUpdate.newLatLng(
            google_maps.LatLng(position.latitude, position.longitude),
          ),
        );
      }

      // Recarregar postos com a nova localização
      _carregarPostos();
    } catch (e) {
      print('❌ Erro ao obter localização: $e');
    }
  }

  void _criarIconesCustomizados() {
    // Usar ícones padrão do Google Maps
    _customMarker = google_maps.BitmapDescriptor.defaultMarkerWithHue(
      google_maps.BitmapDescriptor.hueBlue,
    );
    _userMarkerIcon = google_maps.BitmapDescriptor.defaultMarkerWithHue(
      google_maps.BitmapDescriptor.hueRed,
    );
  }

  Future<void> _carregarPostos() async {
    setState(() => _isLoading = true);

    try {
      if (_mapController == null) {
        print('⚠️ MapController não está pronto ainda');
        setState(() => _isLoading = false);
        return;
      }
      
      // Obter bounds visíveis do mapa
      final bounds = await _mapController!.getVisibleRegion();
      
      // Calcular bounding box
      final latMin = bounds.southwest.latitude;
      final latMax = bounds.northeast.latitude;
      final lngMin = bounds.southwest.longitude;
      final lngMax = bounds.northeast.longitude;

      print('🗺️ Carregando postos na área: lat[$latMin, $latMax], lng[$lngMin, $lngMax]');

      // Buscar postos apenas na área visível
      final postos = await _postosService.buscarPorArea(
        latMin: latMin,
        latMax: latMax,
        lngMin: lngMin,
        lngMax: lngMax,
        limit: 100,
      );

      // Calcular distância de cada posto até o usuário
      final postosComDistancia = postos.map((posto) {
        final distancia = Geolocator.distanceBetween(
          _userLocation.latitude,
          _userLocation.longitude,
          posto.latitude,
          posto.longitude,
        ) / 1000; // Converter metros para km
        
        return models.Posto(
          id: posto.id,
          nome: posto.nome,
          endereco: posto.endereco,
          latitude: posto.latitude,
          longitude: posto.longitude,
          telefone: posto.telefone,
          aberto24h: posto.aberto24h,
          precos: posto.precos,
          distancia: distancia,
        );
      }).toList();

      setState(() {
        _postos = postosComDistancia;
        _isLoading = false;
      });
      
      _criarMarcadores();
    } catch (e) {
      print('❌ Erro ao carregar postos: $e');
      
      setState(() => _isLoading = false);
      
      // Notificar usuário sobre o erro com mensagem específica
      if (mounted) {
        String mensagemErro = 'Erro ao carregar postos.';
        
        if (e.toString().contains('SocketException') || 
            e.toString().contains('Failed host lookup') ||
            e.toString().contains('TimeoutException')) {
          mensagemErro = 'Sem conexão com o servidor. Verifique sua internet.';
        } else if (e.toString().contains('HTTP')) {
          mensagemErro = 'Servidor indisponível no momento.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mensagemErro,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Os postos serão carregados quando a conexão for restabelecida.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            action: SnackBarAction(
              label: 'Tentar novamente',
              textColor: Colors.white,
              onPressed: _carregarPostos,
            ),
            duration: Duration(seconds: 7),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _criarMarcadores() {
    final Set<google_maps.Marker> markers = {};

    // Marcador do usuário
    markers.add(
      google_maps.Marker(
        markerId: const google_maps.MarkerId('user_location'),
        position: google_maps.LatLng(_userLocation.latitude, _userLocation.longitude),
        icon: _userMarkerIcon ?? google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueRed),
        anchor: const Offset(0.5, 0.5),
      ),
    );

    print('📍 Mostrando ${_postos.length} postos no mapa');

    // Adicionar marcadores dos postos (já filtrados pelo backend)
    for (var posto in _postos) {
      markers.add(
        google_maps.Marker(
          markerId: google_maps.MarkerId('posto_${posto.id}'),
          position: google_maps.LatLng(posto.latitude, posto.longitude),
          icon: _customMarker ?? google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueBlue),
          onTap: () => _showPostoDetail(posto),
          infoWindow: google_maps.InfoWindow(
            title: posto.nome,
            snippet: posto.aberto24h ? '24h' : 'Horário comercial',
          ),
        ),
      );
    }

    setState(() => _markers = markers);
  }

  void _onCameraMove(google_maps.CameraPosition position) {
    _mapCenter = LatLng(position.target.latitude, position.target.longitude);
    _mapZoom = position.zoom;
  }

  void _onCameraIdle() {
    // Recarregar postos da área visível quando o mapa parar de se mover
    _carregarPostos();
  }

  void _showFilterBottomSheet() {
    CustomBottomSheet.show(
      context,
      initialChildSize: 0.4,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.bottomSheetPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Filtrar por combustível", style: AppTypography.titleLarge),
            SizedBox(height: AppSpacing.space20),
            Wrap(
              spacing: AppSpacing.space12,
              runSpacing: AppSpacing.space12,
              children: TipoCombustivel.values.map((tipo) {
                return CustomFilterChip(
                  label: tipo.nomeAbreviado,
                  selected: _filtroAtivo == tipo,
                  avatar: tipo.icon,
                  onSelected: (selected) {
                    setState(() => _filtroAtivo = selected ? tipo : null);
                    Navigator.pop(context);
                    _carregarPostos();
                  },
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.space24),
            SecondaryButton(
              label: "Limpar filtro",
              onPressed: () {
                setState(() => _filtroAtivo = null);
                Navigator.pop(context);
                _carregarPostos();
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  void _showRadiusBottomSheet() {
    double tempRaio = _raioKm;

    CustomBottomSheet.show(
      context,
      initialChildSize: 0.35,
      child: StatefulBuilder(
        builder: (context, setStateLocal) {
          return Padding(
            padding: EdgeInsets.all(AppSpacing.bottomSheetPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Raio de busca", style: AppTypography.titleLarge),
                SizedBox(height: AppSpacing.space20),
                CustomSlider(
                  label: "Distância",
                  value: tempRaio,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  onChanged: (value) => setStateLocal(() => tempRaio = value),
                  labelFormatter: (v) => "${v.toInt()} km",
                ),
                SizedBox(height: AppSpacing.space24),
                PrimaryButton(
                  label: "Aplicar",
                  onPressed: () {
                    setState(() => _raioKm = tempRaio);
                    Navigator.pop(context);
                    _carregarPostos();
                  },
                  width: double.infinity,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPostoDetail(models.Posto posto) {
    CustomBottomSheet.show(
      context,
      maxChildSize: 0.85,
      child: PostoDetailBottomSheet(posto: posto),
    );
  }

  void _centerOnUserLocation() async {
    // Atualizar localização antes de centralizar
    await _obterLocalizacaoReal();
    
    _mapController?.animateCamera(
      google_maps.CameraUpdate.newCameraPosition(
        google_maps.CameraPosition(
          target: google_maps.LatLng(_userLocation.latitude, _userLocation.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // MAPA DO GOOGLE
          google_maps.GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              // Carregar postos assim que o mapa estiver pronto
              _carregarPostos();
            },
              initialCameraPosition: google_maps.CameraPosition(
                target: google_maps.LatLng(_userLocation.latitude, _userLocation.longitude),
                zoom: 15,
              ),
              markers: _markers,
              myLocationEnabled: true, // ✅ Ativado para mostrar localização real
              myLocationButtonEnabled: false, // Botão customizado
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              mapType: google_maps.MapType.normal,
            ),

          // APP BAR GLASSMORPHISM
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 56 + MediaQuery.of(context).padding.top,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.9),
                        AppColors.primaryDark.withOpacity(0.9),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: AppShadows.elevation1,
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                        SizedBox(width: AppSpacing.space12),
                        Text(
                          "Postul",
                          style: AppTypography.titleLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // Botão Premium
                        Container(
                          margin: EdgeInsets.only(right: AppSpacing.space8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade400,
                                Colors.orange.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.configuracoes);
                                // Mostrar dica após navegação
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (mounted) {
                                    CustomSnackbar.show(
                                      context,
                                      message: '⭐ Role até "Premium" para ganhar 7 dias grátis!',
                                      type: SnackbarType.info,
                                    );
                                  }
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.space12,
                                  vertical: AppSpacing.space8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: AppSpacing.space4),
                                    const Text(
                                      'Premium',
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
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                          onPressed: () {
                            AdsService().showInterstitialAdWithFrequency();
                            Navigator.pushNamed(
                              context,
                              AppRoutes.notificacoes,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // FABs
          Positioned(
            top: 56 + MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Column(
              children: [
                CustomFAB.small(
                  icon: Icons.filter_list,
                  tooltip: "Filtrar",
                  onPressed: _showFilterBottomSheet,
                ),
                SizedBox(height: AppSpacing.space8),
                CustomFAB.small(
                  icon: Icons.radio_button_checked,
                  tooltip: "Raio",
                  onPressed: _showRadiusBottomSheet,
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 96,
            right: 16,
            child: CustomFAB.small(
              icon: Icons.my_location,
              tooltip: "Minha localização",
              onPressed: _centerOnUserLocation,
            ),
          ),

          // INDICADOR DE LOADING FLUTUANTE
          if (_isLoading)
            Positioned(
              top: 56 + MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppShadows.elevation2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Carregando postos...',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Botão "Ver lista de postos"
          Positioned(
            bottom: 52, // Totalmente colado no banner (50px altura + 2px margem mínima)
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppShadows.elevation3,
              ),
              child: PrimaryButton(
                label: "Ver lista de postos",
                icon: Icons.list,
                onPressed: () {
                  AdsService().showInterstitialAdWithFrequency();
                  Navigator.pushNamed(
                    context,
                    AppRoutes.listaPostos,
                  );
                },
                width: double.infinity,
                height: 56,
              ),
            ),
          ),

          // 💰 BANNER DE ANÚNCIO (rodapé)
          if (AdsService().bannerAd != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                width: AdsService().bannerAd!.size.width.toDouble(),
                height: AdsService().bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: AdsService().bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}
