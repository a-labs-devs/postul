import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../routes/routes.dart';
import '../../services/perfil_service.dart';
import '../../services/ads_service.dart';

/// 📱 POSTUL - Menu Lateral (Drawer)
class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final PerfilService _perfilService = PerfilService();
  String? _fotoPerfil;
  String _nomeUsuario = 'Usuário';
  String _emailUsuario = 'user@email.com';

  @override
  void initState() {
    super.initState();
    _carregarDadosPerfil();
  }

  Future<void> _carregarDadosPerfil() async {
    final foto = await _perfilService.obterCaminhoFotoPerfil();
    final nome = await _perfilService.obterNomeUsuario();
    final email = await _perfilService.obterEmailUsuario();
    
    if (mounted) {
      setState(() {
        _fotoPerfil = foto;
        _nomeUsuario = nome;
        _emailUsuario = email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: Stack(
                children: [
                  // Padrão decorativo de fundo
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DrawerHeaderPainter(),
                    ),
                  ),
                  // Conteúdo
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.space20,
                      right: AppSpacing.space20,
                      top: AppSpacing.space16,
                      bottom: AppSpacing.space20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Foto de perfil
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: _fotoPerfil != null 
                              ? FileImage(File(_fotoPerfil!))
                              : null,
                            child: _fotoPerfil == null
                              ? Icon(
                                  Icons.person,
                                  size: 35,
                                  color: Colors.white,
                                )
                              : null,
                          ),
                        ),
                        SizedBox(height: AppSpacing.space12),
                        // Nome do usuário
                        Text(
                          _nomeUsuario,
                          style: AppTypography.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.space4),
                        // Email
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 12,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            SizedBox(width: AppSpacing.space4),
                            Expanded(
                              child: Text(
                                _emailUsuario,
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.space8),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.space8),

            // MENU
            _buildMenuItem(
              context,
              icon: Icons.favorite,
              iconColor: Colors.red.shade400,
              title: "Favoritos",
              onTap: () {
                Navigator.pop(context);
                AdsService().showInterstitialAdWithFrequency();
                Navigator.pushNamed(context, AppRoutes.favoritos);
              },
            ),

            _buildMenuItem(
              context,
              icon: Icons.notifications,
              iconColor: Colors.orange.shade400,
              title: "Notificações",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.notificacoes);
              },
            ),

            _buildMenuItem(
              context,
              icon: Icons.settings,
              iconColor: Colors.blue.shade400,
              title: "Configurações",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.configuracoes);
              },
            ),

            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              iconColor: Colors.green.shade400,
              title: "Ajuda",
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar tela de ajuda
              },
            ),

            const Spacer(),

            Divider(height: 1, color: AppColors.divider),

            _buildMenuItem(
              context,
              icon: Icons.logout,
              iconColor: AppColors.error,
              title: "Sair",
              titleColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                CustomDialog.show(
                  context,
                  title: "Sair do app?",
                  icon: Icons.logout,
                  actions: [
                    SecondaryButton(
                      label: "Cancelar",
                      onPressed: () => Navigator.pop(context),
                    ),
                    PrimaryButton(
                      label: "Sair",
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: AppSpacing.space16),
          ],
        ),
      ),
    );
  }

  /// Constrói um item de menu personalizado
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              SizedBox(width: AppSpacing.space16),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: titleColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter para criar padrão decorativo no header do drawer
class _DrawerHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Círculos decorativos
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      60,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      40,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 1.1, size.height * 0.6),
      80,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
