import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/app_routes.dart';
import '../../routes/app_router.dart';
import '../../models/posto.dart';
import '../../services/posto_update_service.dart';
import 'route_selection_screen.dart';

/// 📋 POSTUL - Bottom Sheet de Detalhes do Posto
class PostoDetailBottomSheet extends StatelessWidget {
  final Posto posto;

  const PostoDetailBottomSheet({Key? key, required this.posto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // HANDLE
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.outline,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // ✅ FIX: Wrapped with Flexible to prevent 4px overflow
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.bottomSheetPadding,
                ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(posto.nome, style: AppTypography.titleLarge),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    posto.endereco,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSpacing.space16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${posto.distancia?.toStringAsFixed(1) ?? "N/A"} km',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'distância',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.space20),

                  // STATUS
                  Row(
                    children: [
                      Icon(
                        posto.aberto24h ? Icons.schedule : Icons.access_time,
                        size: 20,
                        color: posto.aberto24h
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        posto.aberto24h ? "Aberto 24 horas" : "Horário limitado",
                        style: AppTypography.bodyMedium.copyWith(
                          color: posto.aberto24h
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.space20),

                  // PREÇOS (mockado)
                  Text("Preços", style: AppTypography.titleMedium),
                  SizedBox(height: AppSpacing.space12),

                  _buildPrecosMockados(context),

                  SizedBox(height: AppSpacing.space24),

                  // BOTÕES DE AÇÃO
                  PrimaryButton(
                    label: "Navegar até aqui",
                    icon: Icons.navigation,
                    onPressed: () async {
                      // Obter localização atual do usuário
                      try {
                        // Verifica permissões
                        LocationPermission permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          permission = await Geolocator.requestPermission();
                        }

                        if (permission == LocationPermission.deniedForever) {
                          // Mostra mensagem de erro
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Permissão de localização negada. Ative nas configurações.'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                          return;
                        }

                        // Obter posição atual
                        Position position = await Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.high,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          // Navegar para tela de seleção de rotas
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RouteSelectionScreen(
                                posto: posto,
                                origem: LatLng(position.latitude, position.longitude),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Erro ao obter localização: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Não foi possível obter sua localização.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    width: double.infinity,
                    height: 56,
                  ),

                  SizedBox(height: AppSpacing.space12),

                  // GRID 2x2
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: "Atualizar\npreço",
                          icon: Icons.edit,
                          onPressed: () => _showAtualizarPrecoModal(context),
                          height: 78,
                        ),
                      ),
                      SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: SecondaryButton(
                          label: "Avaliar\nposto",
                          icon: Icons.star_outline,
                          onPressed: () => _showAvaliarModal(context),
                          height: 78,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.space12),

                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: "Adicionar\nfoto",
                          icon: Icons.camera_alt,
                          onPressed: () => _pickImage(context),
                          height: 78,
                        ),
                      ),
                      SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: SecondaryButton(
                          label: "Favorito",
                          icon: Icons.favorite_border,
                          onPressed: () => _toggleFavorito(context),
                          height: 78,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.space24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrecosMockados(BuildContext context) {
    return Column(
      children: [
        _PrecoRow(
          label: "Gasolina Comum",
          preco: 5.49,
          cor: AppColors.gasolinaComum,
        ),
        SizedBox(height: AppSpacing.space8),
        _PrecoRow(
          label: "Etanol",
          preco: 3.99,
          cor: AppColors.etanol,
        ),
        SizedBox(height: AppSpacing.space8),
        _PrecoRow(
          label: "Diesel",
          preco: 4.79,
          cor: AppColors.diesel,
        ),
      ],
    );
  }

  void _showAtualizarPrecoModal(BuildContext context) {
    final gasolinaController = TextEditingController();
    final etanolController = TextEditingController();
    final dieselController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_gas_station,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atualizar Preços',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ajude a comunidade com preços atualizados',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // FORMULÁRIO DE PREÇOS
              Text(
                'Gasolina Comum',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: gasolinaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Ex: 5.49',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Etanol',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: etanolController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Ex: 3.99',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Diesel',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dieselController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Ex: 4.79',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // BOTÕES
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Enviar',
                      onPressed: () {
                        if (gasolinaController.text.isEmpty &&
                            etanolController.text.isEmpty &&
                            dieselController.text.isEmpty) {
                          CustomSnackbar.show(
                            context,
                            message: 'Preencha pelo menos um preço',
                            type: SnackbarType.warning,
                          );
                          return;
                        }
                        
                        // Salvar preços
                        PostoUpdateService.salvarPrecos(
                          postoId: posto.id,
                          gasolina: gasolinaController.text.isNotEmpty 
                              ? double.tryParse(gasolinaController.text.replaceAll(',', '.'))
                              : null,
                          etanol: etanolController.text.isNotEmpty
                              ? double.tryParse(etanolController.text.replaceAll(',', '.'))
                              : null,
                          diesel: dieselController.text.isNotEmpty
                              ? double.tryParse(dieselController.text.replaceAll(',', '.'))
                              : null,
                        );
                        
                        Navigator.pop(context);
                        CustomSnackbar.show(
                          context,
                          message: 'Preços atualizados com sucesso! 🎉',
                          type: SnackbarType.success,
                        );
                      },
                      height: 48,
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

  void _showAvaliarModal(BuildContext context) {
    int avaliacaoSelecionada = 0;
    final comentarioController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Avaliar Posto',
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sua opinião é muito importante!',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ESTRELAS DE AVALIAÇÃO
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            avaliacaoSelecionada = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < avaliacaoSelecionada
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 48,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                if (avaliacaoSelecionada > 0)
                  Center(
                    child: Text(
                      _getAvaliacaoTexto(avaliacaoSelecionada),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // COMENTÁRIO
                Text(
                  'Comentário (opcional)',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: comentarioController,
                  maxLines: 4,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Conte sua experiência neste posto...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // BOTÕES
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Cancelar',
                        onPressed: () => Navigator.pop(context),
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Enviar',
                        onPressed: () async {
                          if (avaliacaoSelecionada == 0) {
                            CustomSnackbar.show(
                              context,
                              message: 'Selecione uma avaliação',
                              type: SnackbarType.warning,
                            );
                            return;
                          }
                          
                          // Salvar avaliação
                          await PostoUpdateService.salvarAvaliacao(
                            postoId: posto.id,
                            estrelas: avaliacaoSelecionada,
                            comentario: comentarioController.text.isNotEmpty 
                                ? comentarioController.text 
                                : null,
                          );
                          
                          Navigator.pop(context);
                          CustomSnackbar.show(
                            context,
                            message: 'Avaliação enviada com sucesso! ⭐',
                            type: SnackbarType.success,
                          );
                        },
                        height: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAvaliacaoTexto(int stars) {
    switch (stars) {
      case 1:
        return 'Muito ruim';
      case 2:
        return 'Ruim';
      case 3:
        return 'Regular';
      case 4:
        return 'Bom';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }

  void _pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Adicionar Foto do Posto',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Escolha de onde deseja adicionar a foto',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // OPÇÃO CÂMERA
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'Tirar foto',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Use a câmera do dispositivo'),
                onTap: () {
                  // Salvar contexto antes de fechar o modal
                  final scaffoldContext = Navigator.of(context).context;
                  Navigator.pop(context);
                  _processarFoto(scaffoldContext, 'camera');
                },
              ),

              // OPÇÃO GALERIA
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'Escolher foto da galeria',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Selecione uma foto existente'),
                onTap: () {
                  // Salvar contexto antes de fechar o modal
                  final scaffoldContext = Navigator.of(context).context;
                  Navigator.pop(context);
                  _processarFoto(scaffoldContext, 'gallery');
                },
              ),

              const SizedBox(height: 16),

              // BOTÃO CANCELAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SecondaryButton(
                  label: 'Cancelar',
                  onPressed: () => Navigator.pop(context),
                  width: double.infinity,
                  height: 48,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _processarFoto(BuildContext context, String source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagem;
      
      // Abrir câmera ou galeria
      if (source == 'camera') {
        imagem = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
        );
      } else {
        imagem = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
        );
      }
      
      // Se o usuário cancelou
      if (imagem == null) {
        return;
      }
      
      // Salvar referência da foto
      await PostoUpdateService.salvarFoto(
        postoId: posto.id,
        caminhoFoto: imagem.path,
      );
      
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: source == 'camera' 
              ? 'Foto capturada com sucesso! 📸' 
              : 'Foto selecionada com sucesso! 🖼️',
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      print('❌ Erro ao processar foto: $e');
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: 'Erro ao processar foto. Tente novamente.',
          type: SnackbarType.error,
        );
      }
    }
  }

  void _toggleFavorito(BuildContext context) {
    CustomSnackbar.show(
      context,
      message: "Adicionado aos favoritos",
      type: SnackbarType.success,
    );
  }
}

class _PrecoRow extends StatelessWidget {
  final String label;
  final double preco;
  final Color cor;

  const _PrecoRow({
    required this.label,
    required this.preco,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium,
            ),
          ),
          Text(
            'R\$ ${preco.toStringAsFixed(2)}',
            style: AppTypography.titleMedium.copyWith(
              color: cor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
