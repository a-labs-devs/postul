import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../models/posto.dart';
import '../../services/rotas_service.dart';
import '../../routes/app_routes.dart';
import '../../routes/app_router.dart';

/// 🗺️ Tela de Seleção de Rotas
/// Permite ao usuário escolher entre múltiplas rotas alternativas
class RouteSelectionScreen extends StatefulWidget {
  final Posto posto;
  final LatLng origem;

  const RouteSelectionScreen({
    Key? key,
    required this.posto,
    required this.origem,
  }) : super(key: key);

  @override
  State<RouteSelectionScreen> createState() => _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends State<RouteSelectionScreen> {
  final RotasService _rotasService = RotasService();
  List<RouteOption> _routes = [];
  bool _isLoading = true;
  int? _selectedRouteIndex;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);

    try {
      final destino = LatLng(widget.posto.latitude, widget.posto.longitude);
      
      // Calcular múltiplas rotas alternativas
      final routes = await _calculateMultipleRoutes(widget.origem, destino);
      
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao calcular rotas: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Erro ao calcular rotas alternativas',
          type: SnackbarType.error,
        );
      }
    }
  }

  // Calcula múltiplas rotas com diferentes critérios
  Future<List<RouteOption>> _calculateMultipleRoutes(
    LatLng origem,
    LatLng destino,
  ) async {
    List<RouteOption> routes = [];

    // ROTA 1: Mais Rápida (Menos tempo)
    final rotaRapida = await _rotasService.calcularRotaComPreferencia(
      origem: origem,
      destino: destino,
      preferencia: 'rapida',
    );
    
    if (rotaRapida != null) {
      routes.add(RouteOption(
        nome: 'Mais Rápida',
        descricao: 'Menor tempo de viagem',
        distancia: rotaRapida['distancia'] ?? 0.0,
        duracao: rotaRapida['duracao'] ?? 0,
        pontos: rotaRapida['pontos'] ?? [],
        tipo: RouteType.rapida,
        icone: Icons.speed,
        cor: Colors.blue,
        economia: null,
      ));
    }

    // ROTA 2: Mais Curta (Menor distância)
    final rotaCurta = await _rotasService.calcularRotaComPreferencia(
      origem: origem,
      destino: destino,
      preferencia: 'curta',
    );
    
    if (rotaCurta != null && rotaCurta['distancia'] != rotaRapida?['distancia']) {
      routes.add(RouteOption(
        nome: 'Mais Curta',
        descricao: 'Menor distância percorrida',
        distancia: rotaCurta['distancia'] ?? 0.0,
        duracao: rotaCurta['duracao'] ?? 0,
        pontos: rotaCurta['pontos'] ?? [],
        tipo: RouteType.curta,
        icone: Icons.straighten,
        cor: Colors.green,
        economia: _calcularEconomia(
          rotaRapida?['distancia'] ?? 0.0,
          rotaCurta['distancia'] ?? 0.0,
        ),
      ));
    }

    // ROTA 3: Evitar Pedágios
    final rotaSemPedagio = await _rotasService.calcularRotaComPreferencia(
      origem: origem,
      destino: destino,
      preferencia: 'sem_pedagio',
    );
    
    if (rotaSemPedagio != null) {
      routes.add(RouteOption(
        nome: 'Sem Pedágios',
        descricao: 'Evita vias com pedágios',
        distancia: rotaSemPedagio['distancia'] ?? 0.0,
        duracao: rotaSemPedagio['duracao'] ?? 0,
        pontos: rotaSemPedagio['pontos'] ?? [],
        tipo: RouteType.semPedagio,
        icone: Icons.money_off,
        cor: Colors.orange,
        economia: '💰 Sem custos de pedágio',
      ));
    }

    // ROTA 4: Evitar Rodovias
    final rotaSemRodovia = await _rotasService.calcularRotaComPreferencia(
      origem: origem,
      destino: destino,
      preferencia: 'sem_rodovia',
    );
    
    if (rotaSemRodovia != null) {
      routes.add(RouteOption(
        nome: 'Vias Locais',
        descricao: 'Evita rodovias e vias expressas',
        distancia: rotaSemRodovia['distancia'] ?? 0.0,
        duracao: rotaSemRodovia['duracao'] ?? 0,
        pontos: rotaSemRodovia['pontos'] ?? [],
        tipo: RouteType.semRodovia,
        icone: Icons.local_shipping_outlined,
        cor: Colors.purple,
        economia: null,
      ));
    }

    // Se não conseguiu rotas alternativas, usa a rota padrão
    if (routes.isEmpty) {
      final rotaPadrao = await _rotasService.calcularRota(
        origem: origem,
        destino: destino,
      );
      
      if (rotaPadrao != null) {
        routes.add(RouteOption(
          nome: 'Rota Padrão',
          descricao: 'Melhor rota disponível',
          distancia: rotaPadrao['distancia'] ?? 0.0,
          duracao: rotaPadrao['duracao'] ?? 0,
          pontos: rotaPadrao['pontos'] ?? [],
          tipo: RouteType.rapida,
          icone: Icons.navigation,
          cor: AppColors.primary,
          economia: null,
        ));
      }
    }

    return routes;
  }

  String? _calcularEconomia(double distanciaReferencia, double distanciaAtual) {
    final economia = distanciaReferencia - distanciaAtual;
    if (economia > 0.1) {
      return '${economia.toStringAsFixed(1)} km mais curta';
    }
    return null;
  }

  void _startNavigation() {
    if (_selectedRouteIndex == null) {
      CustomSnackbar.show(
        context,
        message: 'Selecione uma rota para continuar',
        type: SnackbarType.warning,
      );
      return;
    }

    final selectedRoute = _routes[_selectedRouteIndex!];
    
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.navigation,
      arguments: NavigationArgs(
        widget.posto,
        widget.origem,
        routePoints: selectedRoute.pontos,
        routeType: selectedRoute.tipo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Escolha sua Rota'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Calculando rotas alternativas...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // HEADER COM INFO DO DESTINO
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_gas_station,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.posto.nome,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.posto.endereco,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
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

                // LISTA DE ROTAS
                Expanded(
                  child: _routes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma rota encontrada',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tente novamente mais tarde',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _routes.length,
                          itemBuilder: (context, index) {
                            final route = _routes[index];
                            final isSelected = _selectedRouteIndex == index;
                            
                            return _buildRouteCard(route, index, isSelected);
                          },
                        ),
                ),

                // BOTÃO INICIAR NAVEGAÇÃO
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: PrimaryButton(
                      label: 'Iniciar Navegação',
                      icon: Icons.navigation,
                      onPressed: _startNavigation,
                      width: double.infinity,
                      height: 56,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRouteCard(RouteOption route, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRouteIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? route.cor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? route.cor : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: route.cor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: route.cor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    route.icone,
                    color: route.cor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            route.nome,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? route.cor : Colors.black,
                            ),
                          ),
                          if (index == 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'RECOMENDADA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        route.descricao,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: route.cor,
                    size: 28,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ESTATÍSTICAS
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    icon: Icons.straighten,
                    label: '${route.distancia.toStringAsFixed(1)} km',
                    color: route.cor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    icon: Icons.schedule,
                    label: '${route.duracao} min',
                    color: route.cor,
                  ),
                ),
              ],
            ),

            // ECONOMIA/INFO EXTRA
            if (route.economia != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      route.economia!,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// 📊 Modelo de Opção de Rota
class RouteOption {
  final String nome;
  final String descricao;
  final double distancia;
  final int duracao;
  final List<LatLng> pontos;
  final RouteType tipo;
  final IconData icone;
  final Color cor;
  final String? economia;

  RouteOption({
    required this.nome,
    required this.descricao,
    required this.distancia,
    required this.duracao,
    required this.pontos,
    required this.tipo,
    required this.icone,
    required this.cor,
    this.economia,
  });
}
