import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../models/posto.dart';
import '../../routes/app_routes.dart';
import '../../routes/app_router.dart';

/// ⭐ POSTUL - Tela de Favoritos
class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({Key? key}) : super(key: key);

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<Posto> _favoritos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _favoritos = [
        Posto(
          id: 1,
          nome: 'Posto Shell Centro',
          endereco: 'Av. Paulista, 1000',
          latitude: -23.5505,
          longitude: -46.6333,
          aberto24h: true,
          precos: null,
          distancia: 0.5,
        ),
        Posto(
          id: 2,
          nome: 'Posto Ipiranga Norte',
          endereco: 'Av. Rebouças, 2500',
          latitude: -23.5555,
          longitude: -46.6383,
          aberto24h: false,
          precos: null,
          distancia: 1.2,
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Favoritos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: Mostrar opções de ordenação
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoritos.isEmpty
              ? _buildEstadoVazio()
              : ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.space16),
                  itemCount: _favoritos.length,
                  itemBuilder: (context, index) {
                    final posto = _favoritos[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.space12),
                      child: PostoFavoritoCard(
                        nome: posto.nome,
                        endereco: posto.endereco,
                        preco: 5.49, // Mockado
                        distancia: posto.distancia ?? 0,
                        combustivelPreferido: "Gasolina",
                        onNavigate: () => _navigateTo(posto),
                        onRemove: () => _removerFavorito(posto),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.space24),
            Text(
              'Nenhum favorito ainda',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.space8),
            Text(
              'Adicione postos aos favoritos para\nacessá-los rapidamente',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.space32),
            PrimaryButton(
              label: "Explorar postos",
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(Posto posto) async {
    try {
      // Obter localização atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.navigation,
          arguments: NavigationArgs(
            posto,
            LatLng(position.latitude, position.longitude), // Localização REAL
          ),
        );
      }
    } catch (e) {
      print('Erro ao obter localização: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível obter sua localização.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removerFavorito(Posto posto) {
    CustomDialog.show(
      context,
      title: "Remover favorito?",
      description: "Tem certeza que deseja remover ${posto.nome} dos favoritos?",
      icon: Icons.favorite,
      actions: [
        SecondaryButton(
          label: "Cancelar",
          onPressed: () => Navigator.pop(context),
        ),
        PrimaryButton(
          label: "Remover",
          onPressed: () {
            setState(() => _favoritos.remove(posto));
            Navigator.pop(context);
            CustomSnackbar.show(
              context,
              message: "Removido dos favoritos",
              type: SnackbarType.success,
            );
          },
        ),
      ],
    );
  }
}
