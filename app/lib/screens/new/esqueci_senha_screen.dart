import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/routes.dart';
import '../../services/auth_service.dart';

/// 🔑 POSTUL - Tela Esqueci Minha Senha
class EsqueciSenhaScreen extends StatefulWidget {
  const EsqueciSenhaScreen({Key? key}) : super(key: key);

  @override
  State<EsqueciSenhaScreen> createState() => _EsqueciSenhaScreenState();
}

class _EsqueciSenhaScreenState extends State<EsqueciSenhaScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
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
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _solicitarRecuperacao() async {
    if (_emailController.text.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Digite seu email',
        type: SnackbarType.error,
      );
      return;
    }

    // Validar formato de email
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
      final resultado = await _authService.solicitarRecuperacao(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (resultado['sucesso']) {
          CustomSnackbar.show(
            context,
            message: resultado['mensagem'],
            type: SnackbarType.success,
            duration: const Duration(seconds: 5),
          );

          // Navegar para tela de validação de código
          await Future.delayed(const Duration(seconds: 1));
          
          if (mounted) {
            Navigator.pushNamed(
              context,
              AppRoutes.validarCodigo,
              arguments: _emailController.text.trim(),
            );
          }
        } else {
          CustomSnackbar.show(
            context,
            message: resultado['mensagem'] ?? 'Erro ao solicitar recuperação',
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

                      SizedBox(height: AppSpacing.space48),

                      // ÍCONE - Responsivo
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _fadeAnimation,
                          child: Container(
                            width: MediaQuery.of(context).size.height < 640 ? 80 : 100,
                            height: MediaQuery.of(context).size.height < 640 ? 80 : 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.height < 640 ? 20 : 25,
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.lock_reset,
                              size: MediaQuery.of(context).size.height < 640 ? 40 : 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.space32),

                      // TÍTULO
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Text(
                              "Esqueceu sua senha?",
                              style: AppTypography.displayLarge.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppSpacing.space16),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space24),
                              child: Text(
                                "Não se preocupe! Digite seu email e enviaremos um código para recuperar sua senha.",
                                style: AppTypography.bodyLarge.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSpacing.space48),

                      // FORMULÁRIO
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
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

                              SizedBox(height: AppSpacing.space32),

                              // BOTÃO ENVIAR CÓDIGO
                              _PrimaryButtonWhite(
                                label: "Enviar código",
                                onPressed: _solicitarRecuperacao,
                                isLoading: _isLoading,
                                width: double.infinity,
                                height: 56,
                              ),

                              SizedBox(height: AppSpacing.space24),

                              // INFO
                              Container(
                                padding: EdgeInsets.all(AppSpacing.space16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: AppSpacing.space12),
                                    Expanded(
                                      child: Text(
                                        'Você receberá um código de 6 dígitos no email. O código expira em 30 minutos.',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: AppSpacing.space24),

                              // VOLTAR PARA LOGIN
                              CustomTextButton(
                                label: "Voltar para o login",
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
