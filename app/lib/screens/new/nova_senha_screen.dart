import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/routes.dart';
import '../../services/auth_service.dart';

/// 🔑 POSTUL - Tela de Nova Senha
class NovaSenhaScreen extends StatefulWidget {
  final String email;
  final String codigo;

  const NovaSenhaScreen({
    Key? key,
    required this.email,
    required this.codigo,
  }) : super(key: key);

  @override
  State<NovaSenhaScreen> createState() => _NovaSenhaScreenState();
}

class _NovaSenhaScreenState extends State<NovaSenhaScreen> {
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;

  @override
  void dispose() {
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _redefinirSenha() async {
    if (_senhaController.text.isEmpty || _confirmarSenhaController.text.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Preencha todos os campos',
        type: SnackbarType.error,
      );
      return;
    }

    if (_senhaController.text != _confirmarSenhaController.text) {
      CustomSnackbar.show(
        context,
        message: 'As senhas não coincidem',
        type: SnackbarType.error,
      );
      return;
    }

    if (_senhaController.text.length < 6) {
      CustomSnackbar.show(
        context,
        message: 'A senha deve ter pelo menos 6 caracteres',
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resultado = await _authService.redefinirSenha(
        email: widget.email,
        codigo: widget.codigo,
        novaSenha: _senhaController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (resultado['sucesso']) {
          CustomSnackbar.show(
            context,
            message: '✅ Senha redefinida com sucesso!',
            type: SnackbarType.success,
          );

          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            // Voltar para o login
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        } else {
          CustomSnackbar.show(
            context,
            message: resultado['mensagem'] ?? 'Erro ao redefinir senha',
            type: SnackbarType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.show(
          context,
          message: 'Erro: $e',
          type: SnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              const Color(0xFF1A1A2E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.space24),
            child: Column(
              children: [
                // BOTÃO VOLTAR
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.space48),

                // ÍCONE
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_open,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: AppSpacing.space32),

                // TÍTULO
                Text(
                  "Nova Senha",
                  style: AppTypography.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                SizedBox(height: AppSpacing.space16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.space24),
                  child: Text(
                    "Crie uma senha forte para sua conta. Use pelo menos 6 caracteres.",
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: AppSpacing.space48),

                // NOVA SENHA
                CustomTextField(
                  label: "Nova senha",
                  controller: _senhaController,
                  obscureText: _obscureSenha,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: _obscureSenha
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixTap: () => setState(() => _obscureSenha = !_obscureSenha),
                  backgroundColor: Colors.white.withOpacity(0.15),
                  textColor: Colors.white,
                  labelColor: Colors.white.withOpacity(0.7),
                ),

                SizedBox(height: AppSpacing.space16),

                // CONFIRMAR SENHA
                CustomTextField(
                  label: "Confirmar senha",
                  controller: _confirmarSenhaController,
                  obscureText: _obscureConfirmarSenha,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: _obscureConfirmarSenha
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixTap: () => setState(
                    () => _obscureConfirmarSenha = !_obscureConfirmarSenha,
                  ),
                  backgroundColor: Colors.white.withOpacity(0.15),
                  textColor: Colors.white,
                  labelColor: Colors.white.withOpacity(0.7),
                ),

                SizedBox(height: AppSpacing.space32),

                // BOTÃO REDEFINIR
                _PrimaryButtonWhite(
                  label: "Redefinir senha",
                  onPressed: _redefinirSenha,
                  isLoading: _isLoading,
                  width: double.infinity,
                  height: 56,
                ),

                SizedBox(height: AppSpacing.space24),

                // DICAS DE SENHA
                Container(
                  padding: EdgeInsets.all(AppSpacing.space16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: AppSpacing.space8),
                          Text(
                            'Dicas para uma senha forte:',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.space12),
                      _buildDica('• Pelo menos 6 caracteres'),
                      _buildDica('• Misture letras e números'),
                      _buildDica('• Use caracteres especiais (@, #, !)'),
                      _buildDica('• Evite informações pessoais'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDica(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        texto,
        style: AppTypography.bodySmall.copyWith(
          color: Colors.white.withOpacity(0.8),
          height: 1.4,
        ),
      ),
    );
  }
}

/// Variante do PrimaryButton com fundo branco
class _PrimaryButtonWhite extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const _PrimaryButtonWhite({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.primaryDark,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
