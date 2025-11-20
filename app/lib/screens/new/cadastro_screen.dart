import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/routes.dart';
import '../../services/auth_service.dart';

/// 📝 POSTUL - Tela de Cadastro
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> with SingleTickerProviderStateMixin {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _aceitouTermos = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    // Validações
    if (_nomeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Preencha todos os campos',
        type: SnackbarType.error,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      CustomSnackbar.show(
        context,
        message: 'As senhas não coincidem',
        type: SnackbarType.error,
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      CustomSnackbar.show(
        context,
        message: 'A senha deve ter pelo menos 6 caracteres',
        type: SnackbarType.error,
      );
      return;
    }

    if (!_aceitouTermos) {
      CustomSnackbar.show(
        context,
        message: 'Você deve aceitar os termos de uso',
        type: SnackbarType.warning,
      );
      return;
    }

    // Validar email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      CustomSnackbar.show(
        context,
        message: 'Email inválido',
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resultado = await _authService.cadastrar(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (resultado['sucesso']) {
          // Mostrar mensagem de sucesso
          CustomSnackbar.show(
            context,
            message: '✅ Conta criada! Verifique seu email.',
            type: SnackbarType.success,
            duration: const Duration(seconds: 5),
          );

          // Aguardar 2 segundos e ir para o mapa
          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.map,
              arguments: MapScreenArgs(0),
            );
          }
        } else {
          CustomSnackbar.show(
            context,
            message: resultado['mensagem'] ?? 'Erro ao cadastrar',
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.space24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight > 48 
                        ? constraints.maxHeight - 48 
                        : 0,
                  ),
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

                      SizedBox(height: AppSpacing.space24),

                      // ÍCONE
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _fadeAnimation,
                          child: Container(
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
                              Icons.person_add,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.space24),

                      // TÍTULO
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              "Criar Conta",
                              style: AppTypography.displayLarge.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                            SizedBox(height: AppSpacing.space8),
                            Text(
                              "Junte-se à comunidade Postul",
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSpacing.space32),

                      // FORMULÁRIO
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // NOME
                              CustomTextField(
                                label: "Nome completo",
                                controller: _nomeController,
                                keyboardType: TextInputType.name,
                                prefixIcon: Icons.person_outlined,
                                backgroundColor: Colors.white.withOpacity(0.15),
                                textColor: Colors.white,
                                labelColor: Colors.white.withOpacity(0.7),
                              ),

                              SizedBox(height: AppSpacing.space16),

                              // EMAIL
                              CustomTextField(
                                label: "Email",
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                backgroundColor: Colors.white.withOpacity(0.15),
                                textColor: Colors.white,
                                labelColor: Colors.white.withOpacity(0.7),
                              ),

                              SizedBox(height: AppSpacing.space16),

                              // SENHA
                              CustomTextField(
                                label: "Senha (mínimo 6 caracteres)",
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                prefixIcon: Icons.lock_outlined,
                                suffixIcon: _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                onSuffixTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                backgroundColor: Colors.white.withOpacity(0.15),
                                textColor: Colors.white,
                                labelColor: Colors.white.withOpacity(0.7),
                              ),

                              SizedBox(height: AppSpacing.space16),

                              // CONFIRMAR SENHA
                              CustomTextField(
                                label: "Confirmar senha",
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                prefixIcon: Icons.lock_outlined,
                                suffixIcon: _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                onSuffixTap: () => setState(
                                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                                ),
                                backgroundColor: Colors.white.withOpacity(0.15),
                                textColor: Colors.white,
                                labelColor: Colors.white.withOpacity(0.7),
                              ),

                              SizedBox(height: AppSpacing.space24),

                              // CHECKBOX TERMOS
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _aceitouTermos,
                                      onChanged: (value) => setState(() => _aceitouTermos = value ?? false),
                                      fillColor: MaterialStateProperty.resolveWith((states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return Colors.white;
                                        }
                                        return Colors.transparent;
                                      }),
                                      checkColor: AppColors.primary,
                                      side: BorderSide(
                                        color: Colors.white.withOpacity(0.7),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'Aceito os ',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'termos de uso',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                          TextSpan(text: ' e '),
                                          TextSpan(
                                            text: 'política de privacidade',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: AppSpacing.space24),

                              // BOTÃO CADASTRAR - Responsivo
                              _PrimaryButtonWhite(
                                label: "Criar conta",
                                onPressed: _cadastrar,
                                isLoading: _isLoading,
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height < 640 ? 48 : 56,
                              ),

                              SizedBox(height: AppSpacing.space16),

                              // JÁ TEM CONTA
                              CustomTextButton(
                                label: "Já tem uma conta? Entrar",
                                textColor: Colors.white,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.space48),
                    ],
                  ),
                ),
              );
            },
          ),
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
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
