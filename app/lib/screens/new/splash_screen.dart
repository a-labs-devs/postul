import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../routes/routes.dart';
import '../../services/auth_service.dart';

/// 🚀 POSTUL - Splash Screen
/// Verifica se usuário está logado e redireciona automaticamente
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animação do logo
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animController.forward();

    // Verificar login após animação
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    // Aguardar animação mínima (1.5 segundos)
    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      // Verificar se tem token salvo
      final token = await _authService.obterToken();

      if (token == null) {
        // Não está logado, ir para login
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
        return;
      }

      // Tem token, verificar se ainda é válido
      final resultado = await _authService.verificarToken();

      if (mounted) {
        if (resultado['sucesso']) {
          // Token válido, ir direto para o mapa
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.map,
            arguments: MapScreenArgs(resultado['usuario']['id'] ?? 0),
          );
        } else {
          // Token inválido/expirado, ir para login
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    } catch (e) {
      // Erro ao verificar, ir para login
      print('Erro ao verificar login: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO ANIMADO
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_gas_station,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.space32),

              // NOME DO APP
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "Postul",
                  style: AppTypography.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.space12),

              // TAGLINE
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "Encontre o melhor preço",
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.space48),

              // LOADING INDICATOR
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.7),
                    ),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
