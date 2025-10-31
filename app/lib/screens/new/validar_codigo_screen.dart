import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/routes.dart';
import '../../services/auth_service.dart';

/// 🔑 POSTUL - Tela de Validação de Código
class ValidarCodigoScreen extends StatefulWidget {
  final String email;

  const ValidarCodigoScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<ValidarCodigoScreen> createState() => _ValidarCodigoScreenState();
}

class _ValidarCodigoScreenState extends State<ValidarCodigoScreen> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _authService = AuthService();
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animController);
    _animController.forward();
    
    // Auto-focus no primeiro campo
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  String _getCodigo() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _validarCodigo() async {
    final codigo = _getCodigo();

    if (codigo.length != 6) {
      CustomSnackbar.show(
        context,
        message: 'Digite o código completo',
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resultado = await _authService.validarCodigo(
        email: widget.email,
        codigo: codigo,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (resultado['sucesso']) {
          CustomSnackbar.show(
            context,
            message: 'Código válido!',
            type: SnackbarType.success,
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            Navigator.pushNamed(
              context,
              AppRoutes.novaSenha,
              arguments: {
                'email': widget.email,
                'codigo': codigo,
              },
            );
          }
        } else {
          CustomSnackbar.show(
            context,
            message: resultado['mensagem'] ?? 'Código inválido',
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

  Future<void> _reenviarCodigo() async {
    setState(() => _isLoading = true);

    try {
      final resultado = await _authService.solicitarRecuperacao(
        email: widget.email,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (resultado['sucesso']) {
          CustomSnackbar.show(
            context,
            message: 'Novo código enviado!',
            type: SnackbarType.success,
          );

          // Limpar campos
          for (var controller in _controllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        } else {
          CustomSnackbar.show(
            context,
            message: resultado['mensagem'] ?? 'Erro ao reenviar código',
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
                FadeTransition(
                  opacity: _fadeAnimation,
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
                      Icons.mail_outline,
                      size: 50,
                      color: Colors.white,
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
                        "Digite o código",
                        style: AppTypography.displayLarge.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                      SizedBox(height: AppSpacing.space16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space24),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white.withOpacity(0.7),
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Enviamos um código de 6 dígitos para\n',
                              ),
                              TextSpan(
                                text: widget.email,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.space48),

                // CAMPOS DE CÓDIGO
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        width: 50,
                        height: 60,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.25),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }

                            // Auto-validar quando preencher tudo
                            if (index == 5 && value.isNotEmpty) {
                              _validarCodigo();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),

                SizedBox(height: AppSpacing.space48),

                // BOTÃO VALIDAR
                _PrimaryButtonWhite(
                  label: "Validar código",
                  onPressed: _validarCodigo,
                  isLoading: _isLoading,
                  width: double.infinity,
                  height: 56,
                ),

                SizedBox(height: AppSpacing.space24),

                // REENVIAR CÓDIGO
                TextButton(
                  onPressed: _isLoading ? null : _reenviarCodigo,
                  child: Text(
                    'Não recebeu o código? Reenviar',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.space16),

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
                        Icons.access_time,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: Text(
                          'O código expira em 30 minutos',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
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
