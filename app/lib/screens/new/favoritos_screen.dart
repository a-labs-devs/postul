import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../models/posto.dart';
import '../../models/favorito.dart';
import '../../services/favoritos_service.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../routes/app_router.dart';

/// ⭐ POSTUL - Tela de Favoritos
class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({Key? key}) : super(key: key);

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  final FavoritosService _favoritosService = FavoritosService();
  final AuthService _authService = AuthService();
  List<Posto> _postos = [];
  bool _isLoading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });
    
    try {
      // Obter usuário logado
      final usuario = await _authService.usuarioAtual();
      
      if (usuario == null) {
        setState(() {
          _erro = 'Usuário não autenticado';
          _isLoading = false;
        });
        return;
      }

      print('📱 Carregando favoritos do usuário ${usuario.id}...');
      
      // Buscar favoritos da API
      final favoritos = await _favoritosService.listar(usuario.id);
      
      print('✅ ${favoritos.length} favoritos carregados');
      
      // Converter favoritos para lista de postos
      final List<Posto> postosList = favoritos.map((fav) {
        return Posto(
          id: fav.postoId,
          nome: fav.postoNome ?? 'Posto sem nome',
          endereco: fav.postoEndereco ?? 'Endereço não disponível',
          latitude: fav.latitude ?? 0,
          longitude: fav.longitude ?? 0,
          telefone: fav.telefone,
          aberto24h: fav.aberto24h ?? false,
          precos: fav.precos?.map((p) => p.toJson()).toList(),
          distancia: null,
        );
      }).toList();
      
      setState(() {
        _postos = postosList;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar favoritos: $e');
      setState(() {
        _erro = 'Erro ao carregar favoritos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Favoritos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarFavoritos,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? _buildEstadoErro()
              : _postos.isEmpty
                  ? _buildEstadoVazio()
                  : ListView.builder(
                      padding: EdgeInsets.all(AppSpacing.space16),
                      itemCount: _postos.length,
                      itemBuilder: (context, index) {
                        final posto = _postos[index];
                        
                        // Extrair preço do combustível preferido (se disponível)
                        double? preco;
                        if (posto.precos != null && posto.precos is List && (posto.precos as List).isNotEmpty) {
                          final precoData = (posto.precos as List).first;
                          preco = double.tryParse(precoData['preco']?.toString() ?? '0');
                        }
                        
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.space12),
                          child: PostoFavoritoCard(
                            nome: posto.nome,
                            endereco: posto.endereco,
                            preco: preco,
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

  Widget _buildEstadoErro() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            SizedBox(height: AppSpacing.space24),
            Text(
              'Erro ao carregar favoritos',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.space8),
            Text(
              _erro ?? 'Erro desconhecido',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.space32),
            PrimaryButton(
              label: "Tentar novamente",
              onPressed: _carregarFavoritos,
            ),
          ],
        ),
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

  void _removerFavorito(Posto posto) async {
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
          onPressed: () async {
            Navigator.pop(context);
            
            try {
              // Obter usuário logado
              final usuario = await _authService.usuarioAtual();
              
              if (usuario == null) {
                CustomSnackbar.show(
                  context,
                  message: "Usuário não autenticado",
                  type: SnackbarType.error,
                );
                return;
              }

              // Remover da API
              final sucesso = await _favoritosService.removerPorUsuarioEPosto(usuario.id, posto.id);
              
              if (sucesso) {
                // Remover da lista local
                setState(() => _postos.remove(posto));
                
                CustomSnackbar.show(
                  context,
                  message: "Removido dos favoritos",
                  type: SnackbarType.success,
                );
              } else {
                CustomSnackbar.show(
                  context,
                  message: "Erro ao remover favorito",
                  type: SnackbarType.error,
                );
              }
            } catch (e) {
              print('❌ Erro ao remover favorito: $e');
              CustomSnackbar.show(
                context,
                message: "Erro: $e",
                type: SnackbarType.error,
              );
            }
          },
        ),
      ],
    );
  }
}
