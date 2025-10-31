import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/routes.dart';

/// 🔐 POSTUL - Tela de Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
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
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Preencha todos os campos',
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simular login
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.map,
        arguments: MapScreenArgs(0),
      );
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
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: AppSpacing.space48),

                        // LOGO
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _fadeAnimation,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.local_gas_station,
                                size: 64,
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
                                "Postul",
                                style: AppTypography.displayLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: AppSpacing.space8),
                              Text(
                                "Encontre o melhor preço",
                                style: AppTypography.bodyLarge.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // FORMULÁRIO
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
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

                                CustomTextField(
                                  label: "Senha",
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

                                SizedBox(height: AppSpacing.space24),

                                _PrimaryButtonWhite(
                                  label: "Entrar",
                                  onPressed: _login,
                                  isLoading: _isLoading,
                                  width: double.infinity,
                                  height: 56,
                                ),

                                SizedBox(height: AppSpacing.space16),

                                CustomTextButton(
                                  label: "Esqueci minha senha",
                                  textColor: Colors.white,
                                  onPressed: () => Navigator.pushNamed(context, AppRoutes.esqueciSenha),
                                ),

                                SizedBox(height: AppSpacing.space24),

                                // DIVISOR
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        "ou",
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: AppSpacing.space24),

                                // BOTÃO CRIAR CONTA
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => Navigator.pushNamed(context, AppRoutes.cadastro),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Center(
                                        child: Text(
                                          'Criar nova conta',
                                          style: AppTypography.labelLarge.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: AppSpacing.space48),
                      ],
                    ),
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
