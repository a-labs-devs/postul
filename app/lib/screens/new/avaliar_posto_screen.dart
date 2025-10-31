import 'package:flutter/material.dart';
import '../../models/posto.dart';
import '../../services/avaliacoes_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/modals/custom_snackbar.dart';

/// 📝 Tela de Avaliação de Posto
/// Interface para usuários avaliarem postos de combustível
class AvaliarPostoScreen extends StatefulWidget {
  final Posto posto;
  final int usuarioId;

  const AvaliarPostoScreen({
    super.key,
    required this.posto,
    required this.usuarioId,
  });

  @override
  State<AvaliarPostoScreen> createState() => _AvaliarPostoScreenState();
}

class _AvaliarPostoScreenState extends State<AvaliarPostoScreen>
    with SingleTickerProviderStateMixin {
  final _avaliacoesService = AvaliacoesService();
  final _comentarioController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  int _notaSelecionada = 0;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _carregarAvaliacaoExistente();
  }

  Future<void> _carregarAvaliacaoExistente() async {
    setState(() => _carregando = true);
    
    final avaliacao = await _avaliacoesService.obterAvaliacaoUsuario(
      widget.posto.id,
      widget.usuarioId,
    );

    if (avaliacao != null && mounted) {
      setState(() {
        _notaSelecionada = avaliacao.nota;
        _comentarioController.text = avaliacao.comentario ?? '';
      });
    }

    if (mounted) setState(() => _carregando = false);
  }

  Future<void> _salvarAvaliacao() async {
    if (_notaSelecionada == 0) {
      CustomSnackbar.show(
        context,
        message: '⚠️ Selecione uma nota',
        type: SnackbarType.warning,
      );
      return;
    }

    setState(() => _carregando = true);

    final resultado = await _avaliacoesService.avaliar(
      postoId: widget.posto.id,
      usuarioId: widget.usuarioId,
      nota: _notaSelecionada,
      comentario: _comentarioController.text.trim().isEmpty 
          ? null 
          : _comentarioController.text.trim(),
    );

    if (!mounted) return;
    
    setState(() => _carregando = false);

    CustomSnackbar.show(
      context,
      message: resultado['mensagem'],
      type: resultado['sucesso'] ? SnackbarType.success : SnackbarType.error,
    );

    if (resultado['sucesso']) {
      Navigator.pop(context, true);
    }
  }

  void _selecionarNota(int nota) {
    setState(() => _notaSelecionada = nota);
    _animationController.forward().then((_) => _animationController.reverse());
  }

  String _obterTextoNota(int nota) {
    switch (nota) {
      case 1:
        return '😞 Muito Ruim';
      case 2:
        return '😕 Ruim';
      case 3:
        return '😐 Regular';
      case 4:
        return '😊 Bom';
      case 5:
        return '🤩 Excelente';
      default:
        return '';
    }
  }

  Color _obterCorNota(int nota) {
    if (nota <= 2) return AppColors.error;
    if (nota == 3) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Avaliar Posto',
          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _carregando
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card do Posto
                  Container(
                    padding: EdgeInsets.all(AppSpacing.space16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.space12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.local_gas_station,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: AppSpacing.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.posto.nome,
                                style: AppTypography.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: AppSpacing.space4),
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

                  SizedBox(height: AppSpacing.space32),

                  // Título - Sua Avaliação
                  Text(
                    'Sua avaliação',
                    style: AppTypography.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.space8),
                  Text(
                    'Toque nas estrelas para avaliar',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: AppSpacing.space24),

                  // Estrelas de Avaliação
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.space16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: _notaSelecionada > 0 
                              ? _obterCorNota(_notaSelecionada).withValues(alpha: 0.3)
                              : AppColors.outline,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final nota = index + 1;
                          final isSelected = nota <= _notaSelecionada;
                          
                          return GestureDetector(
                            onTap: () => _selecionarNota(nota),
                            child: AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: isSelected && nota == _notaSelecionada
                                      ? _scaleAnimation.value
                                      : 1.0,
                                  child: child,
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.space8,
                                ),
                                child: Icon(
                                  isSelected ? Icons.star : Icons.star_border,
                                  color: isSelected
                                      ? _obterCorNota(_notaSelecionada)
                                      : AppColors.outline,
                                  size: 48,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // Texto da Nota Selecionada
                  if (_notaSelecionada > 0) ...[
                    SizedBox(height: AppSpacing.space16),
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.space20,
                          vertical: AppSpacing.space8,
                        ),
                        decoration: BoxDecoration(
                          color: _obterCorNota(_notaSelecionada)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          _obterTextoNota(_notaSelecionada),
                          style: AppTypography.titleMedium.copyWith(
                            color: _obterCorNota(_notaSelecionada),
                          ),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: AppSpacing.space32),

                  // Campo de Comentário
                  Text(
                    'Comentário (opcional)',
                    style: AppTypography.titleMedium,
                  ),
                  SizedBox(height: AppSpacing.space12),

                  TextFormField(
                    controller: _comentarioController,
                    maxLines: 5,
                    maxLength: 500,
                    style: AppTypography.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Conte mais sobre sua experiência...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      counterStyle: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.space32),

                  // Botão Salvar
                  PrimaryButton(
                    label: 'Salvar Avaliação',
                    onPressed: _carregando ? null : _salvarAvaliacao,
                    isLoading: _carregando,
                    icon: Icons.check_circle,
                    height: 56,
                  ),

                  SizedBox(height: AppSpacing.space16),

                  // Texto Informativo
                  Center(
                    child: Text(
                      'Sua avaliação ajuda outros usuários',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
