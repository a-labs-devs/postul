import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/modals/custom_snackbar.dart';
import '../../routes/app_routes.dart';
import '../../services/perfil_service.dart';
import '../../services/auth_service.dart';
import '../../services/ads_service.dart';

/// ⚙️ Tela de Configurações
/// Interface de configurações e preferências do usuário
class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final PerfilService _perfilService = PerfilService();
  final AuthService _authService = AuthService();
  
  // Perfil
  String? _fotoPerfil;
  String _nomeUsuario = 'Usuário';
  String _emailUsuario = 'user@email.com';
  
  // Notificações
  bool _notificacoesAtivas = true;
  bool _notificacoesPreco = true;
  bool _notificacoesPostosProximos = true;
  bool _notificacoesAvaliacoes = false;
  bool _alertaPrecosBaixos = true;
  bool _alertaPostosFavoritos = true;
  bool _alertaPromocoes = true;
  
  // Preferências
  bool _mostrarMapaSatelite = false;
  bool _autoAtualizarLocalizacao = true;
  double _raioNotificacao = 5.0; // km
  String _corTemaApp = 'Azul'; // Cor principal do app
  
  // Privacidade
  bool _compartilharLocalizacao = true;
  bool _avaliacoesPublicas = true;

  // Cache
  String _tamanhoCache = 'Calculando...';

  @override
  void initState() {
    super.initState();
    _calcularTamanhoCache();
    _carregarPreferencias();
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

  Future<void> _carregarPreferencias() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    setState(() {
      _corTemaApp = themeProvider.currentColor;
    });
  }

  Future<void> _calcularTamanhoCache() async {
    // Simula cálculo de cache
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _tamanhoCache = '24.5 MB';
      });
    }
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
          'Configurações',
          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space16),
        children: [
          // ===== PERFIL DO USUÁRIO =====
          _buildSectionHeader('Perfil', Icons.person),
          
          // Card de Perfil
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space8,
            ),
            padding: EdgeInsets.all(AppSpacing.space16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                // Foto de Perfil
                GestureDetector(
                  onTap: _mostrarOpcoesDeImagem,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: _fotoPerfil != null 
                          ? FileImage(File(_fotoPerfil!))
                          : null,
                        child: _fotoPerfil == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primary,
                            )
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.space16),
                
                // Nome
                TextField(
                  controller: TextEditingController(text: _nomeUsuario),
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _nomeUsuario = value);
                    _perfilService.salvarNomeUsuario(value);
                  },
                ),
                SizedBox(height: AppSpacing.space12),
                
                // Email
                TextField(
                  controller: TextEditingController(text: _emailUsuario),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() => _emailUsuario = value);
                    _perfilService.salvarEmailUsuario(value);
                  },
                ),
                
                if (_fotoPerfil != null) ...[
                  SizedBox(height: AppSpacing.space12),
                  TextButton.icon(
                    onPressed: _removerFoto,
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                    label: Text(
                      'Remover foto',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ],
            ),
          ),

          _buildDivider(),

          // ===== NOTIFICAÇÕES =====
          _buildSectionHeader('Notificações', Icons.notifications),
          
          _buildSwitchTile(
            title: 'Ativar notificações',
            subtitle: 'Receber todas as notificações do app',
            value: _notificacoesAtivas,
            onChanged: (value) {
              setState(() => _notificacoesAtivas = value);
              _salvarConfiguracoes();
            },
            icon: Icons.notifications_active,
          ),
          
          if (_notificacoesAtivas) ...[
            _buildSwitchTile(
              title: 'Alterações de preço',
              subtitle: 'Notificar quando houver mudança nos preços',
              value: _notificacoesPreco,
              onChanged: (value) {
                setState(() => _notificacoesPreco = value);
                _salvarConfiguracoes();
              },
              icon: Icons.price_change,
            ),
            
            _buildSwitchTile(
              title: 'Postos próximos',
              subtitle: 'Alertar sobre novos postos na região',
              value: _notificacoesPostosProximos,
              onChanged: (value) {
                setState(() => _notificacoesPostosProximos = value);
                _salvarConfiguracoes();
              },
              icon: Icons.location_on,
            ),
            
            _buildSwitchTile(
              title: 'Avaliações',
              subtitle: 'Notificar sobre novas avaliações',
              value: _notificacoesAvaliacoes,
              onChanged: (value) {
                setState(() => _notificacoesAvaliacoes = value);
                _salvarConfiguracoes();
              },
              icon: Icons.star,
            ),
            
            _buildSwitchTile(
              title: 'Alerta de preços baixos',
              subtitle: 'Avisar quando encontrar preços vantajosos',
              value: _alertaPrecosBaixos,
              onChanged: (value) {
                setState(() => _alertaPrecosBaixos = value);
                _salvarConfiguracoes();
              },
              icon: Icons.trending_down,
            ),
            
            _buildSwitchTile(
              title: 'Postos favoritos',
              subtitle: 'Notificar mudanças nos seus postos favoritos',
              value: _alertaPostosFavoritos,
              onChanged: (value) {
                setState(() => _alertaPostosFavoritos = value);
                _salvarConfiguracoes();
              },
              icon: Icons.favorite,
            ),
            
            _buildSwitchTile(
              title: 'Promoções',
              subtitle: 'Receber notificações de promoções especiais',
              value: _alertaPromocoes,
              onChanged: (value) {
                setState(() => _alertaPromocoes = value);
                _salvarConfiguracoes();
              },
              icon: Icons.local_offer,
            ),
            
            // Raio de Notificação
            _buildSliderTile(
              title: 'Raio de notificação',
              subtitle: '${_raioNotificacao.toStringAsFixed(1)} km',
              value: _raioNotificacao,
              min: 1.0,
              max: 20.0,
              divisions: 19,
              onChanged: (value) {
                setState(() => _raioNotificacao = value);
                _salvarConfiguracoes();
              },
              icon: Icons.radar,
            ),
          ],

          _buildDivider(),

          // ===== PREMIUM =====
          _buildSectionHeader('Premium', Icons.star),
          
          // Card Premium com Rewarded Ad
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space8,
            ),
            padding: EdgeInsets.all(AppSpacing.space20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.space12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: AppSpacing.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'POSTUL Premium',
                            style: AppTypography.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSpacing.space4),
                          Text(
                            'Ganhe 7 dias grátis!',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.space16),
                
                // Benefícios
                _buildPremiumBenefit('Sem anúncios por 7 dias'),
                _buildPremiumBenefit('Rotas ilimitadas'),
                _buildPremiumBenefit('Suporte prioritário'),
                
                SizedBox(height: AppSpacing.space20),
                
                // Botão para assistir anúncio
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AdsService().showRewardedAd(
                        onRewarded: () {
                          // TODO: Implementar lógica de Premium (salvar data de expiração)
                          CustomSnackbar.show(
                            context,
                            message: '🎉 Premium ativado por 7 dias!',
                            type: SnackbarType.success,
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.play_circle_outline, size: 24),
                    label: const Text(
                      'Assistir vídeo e ganhar Premium',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.space16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          _buildDivider(),

          // ===== APARÊNCIA =====
          _buildSectionHeader('Aparência', Icons.palette),
          
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _buildSwitchTile(
                title: 'Modo escuro',
                subtitle: 'Usar tema escuro no aplicativo',
                value: themeProvider.isDarkMode,
                onChanged: (value) async {
                  await themeProvider.toggleThemeMode();
                  if (mounted) {
                    CustomSnackbar.show(
                      context,
                      message: themeProvider.isDarkMode ? 'Tema escuro ativado' : 'Tema claro ativado',
                      type: SnackbarType.success,
                    );
                  }
                },
                icon: Icons.dark_mode,
              );
            },
          ),
          
          _buildActionTile(
            title: 'Cor do tema',
            subtitle: 'Cor principal: $_corTemaApp',
            icon: Icons.color_lens,
            onTap: () {
              _mostrarSeletorCores();
            },
          ),
          
          _buildSwitchTile(
            title: 'Mapa satélite',
            subtitle: 'Mostrar visão de satélite no mapa',
            value: _mostrarMapaSatelite,
            onChanged: (value) {
              setState(() => _mostrarMapaSatelite = value);
              _salvarConfiguracoes();
            },
            icon: Icons.satellite_alt,
          ),

          _buildDivider(),

          // ===== LOCALIZAÇÃO =====
          _buildSectionHeader('Localização', Icons.location_searching),
          
          _buildSwitchTile(
            title: 'Atualização automática',
            subtitle: 'Atualizar localização em tempo real',
            value: _autoAtualizarLocalizacao,
            onChanged: (value) {
              setState(() => _autoAtualizarLocalizacao = value);
              _salvarConfiguracoes();
            },
            icon: Icons.my_location,
          ),
          
          _buildSwitchTile(
            title: 'Compartilhar localização',
            subtitle: 'Permitir que o app use sua localização',
            value: _compartilharLocalizacao,
            onChanged: (value) {
              setState(() => _compartilharLocalizacao = value);
              _salvarConfiguracoes();
            },
            icon: Icons.share_location,
          ),

          _buildDivider(),

          // ===== PRIVACIDADE =====
          _buildSectionHeader('Privacidade', Icons.privacy_tip),
          
          _buildSwitchTile(
            title: 'Avaliações públicas',
            subtitle: 'Suas avaliações serão visíveis para todos',
            value: _avaliacoesPublicas,
            onChanged: (value) {
              setState(() => _avaliacoesPublicas = value);
              _salvarConfiguracoes();
            },
            icon: Icons.public,
          ),

          _buildDivider(),

          // ===== CACHE E ARMAZENAMENTO =====
          _buildSectionHeader('Cache e Armazenamento', Icons.storage),
          
          _buildActionTile(
            title: 'Cache do aplicativo',
            subtitle: _tamanhoCache,
            icon: Icons.cached,
            onTap: () {
              _mostrarDialogLimparCache();
            },
          ),
          
          _buildActionTile(
            title: 'Limpar cache de mapas',
            subtitle: 'Remover mapas baixados',
            icon: Icons.map,
            onTap: () {
              _limparCacheMapas();
            },
          ),
          
          _buildActionTile(
            title: 'Limpar histórico',
            subtitle: 'Remover histórico de buscas e navegações',
            icon: Icons.history,
            onTap: () {
              _mostrarDialogLimparHistorico();
            },
          ),

          _buildDivider(),

          // ===== SOBRE =====
          _buildSectionHeader('Sobre', Icons.info),
          
          _buildActionTile(
            title: 'Versão do app',
            subtitle: '1.0.0 (Beta)',
            icon: Icons.app_settings_alt,
            onTap: () {
              _mostrarSobreDialog();
            },
          ),
          
          _buildActionTile(
            title: 'Termos de uso',
            subtitle: 'Ver termos e condições',
            icon: Icons.description,
            onTap: () {
              CustomSnackbar.show(
                context,
                message: 'Abrindo termos de uso...',
                type: SnackbarType.info,
              );
            },
          ),
          
          _buildActionTile(
            title: 'Política de privacidade',
            subtitle: 'Como tratamos seus dados',
            icon: Icons.shield,
            onTap: () {
              CustomSnackbar.show(
                context,
                message: 'Abrindo política de privacidade...',
                type: SnackbarType.info,
              );
            },
          ),

          SizedBox(height: AppSpacing.space32),

          // ===== BOTÃO REINICIAR APP =====
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: OutlinedButton.icon(
              onPressed: () {
                _mostrarDialogReiniciarApp();
              },
              icon: const Icon(Icons.restart_alt, color: AppColors.warning),
              label: Text(
                'Reiniciar aplicativo',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.space16,
                  horizontal: AppSpacing.space24,
                ),
                side: const BorderSide(color: AppColors.warning),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),

          SizedBox(height: AppSpacing.space16),

          // ===== BOTÃO SAIR =====
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: OutlinedButton.icon(
              onPressed: () {
                _mostrarDialogSair();
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: Text(
                'Sair da conta',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.space16,
                  horizontal: AppSpacing.space24,
                ),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),

          SizedBox(height: AppSpacing.space48),
        ],
      ),
    );
  }

  // ===== WIDGETS AUXILIARES =====

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space24,
        AppSpacing.space16,
        AppSpacing.space8,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          SizedBox(width: AppSpacing.space12),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title, style: AppTypography.bodyLarge),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        secondary: Icon(icon, color: AppColors.primary),
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space4,
      ),
      padding: EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyLarge),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTypography.bodyLarge),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: AppSpacing.space32,
      thickness: 1,
      color: AppColors.outline.withValues(alpha: 0.2),
    );
  }

  /// Widget para benefício Premium
  Widget _buildPremiumBenefit(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.space8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: AppSpacing.space12),
          Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.95),
            ),
          ),
        ],
      ),
    );
  }

  // ===== AÇÕES =====

  /// Mostrar opções para adicionar foto
  void _mostrarOpcoesDeImagem() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: AppSpacing.space16),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Título
            Row(
              children: [
                Icon(
                  Icons.photo_camera,
                  color: AppColors.primary,
                  size: 28,
                ),
                SizedBox(width: AppSpacing.space12),
                Text(
                  'Foto de Perfil',
                  style: AppTypography.headlineSmall,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.space8),
            Text(
              'Escolha como deseja adicionar sua foto',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            SizedBox(height: AppSpacing.space24),
            
            // Opção: Galeria
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              title: Text(
                'Escolher da galeria',
                style: AppTypography.titleMedium,
              ),
              subtitle: Text(
                'Selecione uma foto existente',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _selecionarDaGaleria();
              },
            ),
            
            SizedBox(height: AppSpacing.space12),
            
            // Opção: Câmera
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              title: Text(
                'Tirar foto',
                style: AppTypography.titleMedium,
              ),
              subtitle: Text(
                'Use a câmera do dispositivo',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _tirarFoto();
              },
            ),
            
            // Opção: Remover (se tiver foto)
            if (_fotoPerfil != null) ...[
              SizedBox(height: AppSpacing.space12),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Remover foto',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                subtitle: Text(
                  'Excluir foto de perfil atual',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removerFoto();
                },
              ),
            ],
            
            SizedBox(height: AppSpacing.space16),
          ],
        ),
      ),
    );
  }

  /// Selecionar foto da galeria
  Future<void> _selecionarDaGaleria() async {
    final fotoPath = await _perfilService.selecionarFotoDaGaleria();
    if (fotoPath != null && mounted) {
      setState(() => _fotoPerfil = fotoPath);
      CustomSnackbar.show(
        context,
        message: 'Foto de perfil atualizada',
        type: SnackbarType.success,
      );
    }
  }

  /// Tirar foto com a câmera
  Future<void> _tirarFoto() async {
    final fotoPath = await _perfilService.tirarFotoComCamera();
    if (fotoPath != null && mounted) {
      setState(() => _fotoPerfil = fotoPath);
      CustomSnackbar.show(
        context,
        message: 'Foto de perfil atualizada',
        type: SnackbarType.success,
      );
    }
  }

  /// Remover foto de perfil
  Future<void> _removerFoto() async {
    final sucesso = await _perfilService.removerFotoPerfil();
    if (sucesso && mounted) {
      setState(() => _fotoPerfil = null);
      CustomSnackbar.show(
        context,
        message: 'Foto de perfil removida',
        type: SnackbarType.info,
      );
    }
  }

  void _salvarConfiguracoes() {
    // TODO: Salvar configurações no SharedPreferences
    CustomSnackbar.show(
      context,
      message: 'Configurações salvas',
      type: SnackbarType.success,
    );
  }

  void _mostrarSobreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre o Postul'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Postul - Encontre os melhores preços de combustível',
              style: AppTypography.bodyMedium,
            ),
            SizedBox(height: AppSpacing.space16),
            Text('Versão: 1.0.0 (Beta)', style: AppTypography.bodySmall),
            Text(
              'Desenvolvido com ❤️ em Flutter',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogSair() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text(
          'Tem certeza que deseja sair? Você precisará fazer login novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Fecha o diálogo
              
              try {
                // Faz logout e limpa o token
                await _authService.logout();
                
                // Volta para a tela de login e remove todas as rotas anteriores
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                  
                  // Mostra mensagem de sucesso
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      CustomSnackbar.show(
                        context,
                        message: 'Você saiu da conta com sucesso',
                        type: SnackbarType.success,
                      );
                    }
                  });
                }
              } catch (e) {
                if (mounted) {
                  CustomSnackbar.show(
                    context,
                    message: 'Erro ao sair: $e',
                    type: SnackbarType.error,
                  );
                }
              }
            },
            child: Text(
              'Sair',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // ===== SELETOR DE CORES =====
  void _mostrarSeletorCores() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.palette, color: AppColors.primary),
            SizedBox(width: AppSpacing.space12),
            const Text('Escolher cor do tema'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCorOption('Azul', const Color(0xFF1976D2), themeProvider),
            _buildCorOption('Verde', const Color(0xFF388E3C), themeProvider),
            _buildCorOption('Roxo', const Color(0xFF7B1FA2), themeProvider),
            _buildCorOption('Laranja', const Color(0xFFE64A19), themeProvider),
            _buildCorOption('Rosa', const Color(0xFFE91E63), themeProvider),
            _buildCorOption('Vermelho', const Color(0xFFD32F2F), themeProvider),
            _buildCorOption('Turquesa', const Color(0xFF00897B), themeProvider),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCorOption(String nome, Color cor, ThemeProvider themeProvider) {
    bool selecionada = themeProvider.currentColor == nome;
    return InkWell(
      onTap: () async {
        await themeProvider.changeColorTheme(nome);
        setState(() => _corTemaApp = nome);
        if (mounted) {
          Navigator.pop(context);
          CustomSnackbar.show(
            context,
            message: 'Cor do tema alterada para $nome! O app será atualizado.',
            type: SnackbarType.success,
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSpacing.space8),
        padding: EdgeInsets.all(AppSpacing.space12),
        decoration: BoxDecoration(
          color: selecionada ? cor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selecionada ? cor : AppColors.outline,
            width: selecionada ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppSpacing.space16),
            Text(
              nome,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: selecionada ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (selecionada)
              Icon(Icons.check_circle, color: cor),
          ],
        ),
      ),
    );
  }

  // ===== LIMPAR CACHE =====
  void _mostrarDialogLimparCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_sweep, color: AppColors.warning),
            SizedBox(width: AppSpacing.space12),
            const Text('Limpar cache'),
          ],
        ),
        content: Text(
          'Isso irá liberar $_tamanhoCache de espaço. O aplicativo pode ficar mais lento temporariamente após limpar o cache.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _limparCache();
            },
            child: const Text(
              'Limpar',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _limparCache() async {
    CustomSnackbar.show(
      context,
      message: 'Limpando cache...',
      type: SnackbarType.info,
    );

    // Simula limpeza de cache
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _tamanhoCache = '0 MB';
    });

    if (mounted) {
      CustomSnackbar.show(
        context,
        message: 'Cache limpo com sucesso!',
        type: SnackbarType.success,
      );
      
      // Recalcula após 1 segundo
      Future.delayed(const Duration(seconds: 1), () {
        _calcularTamanhoCache();
      });
    }
  }

  Future<void> _limparCacheMapas() async {
    CustomSnackbar.show(
      context,
      message: 'Cache de mapas limpo!',
      type: SnackbarType.success,
    );
  }

  // ===== LIMPAR HISTÓRICO =====
  void _mostrarDialogLimparHistorico() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.history, color: AppColors.error),
            SizedBox(width: AppSpacing.space12),
            const Text('Limpar histórico'),
          ],
        ),
        content: const Text(
          'Isso irá remover todo o seu histórico de buscas e navegações. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              CustomSnackbar.show(
                context,
                message: 'Histórico limpo com sucesso!',
                type: SnackbarType.success,
              );
            },
            child: const Text(
              'Limpar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // ===== REINICIAR APP =====
  void _mostrarDialogReiniciarApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.restart_alt, color: AppColors.warning),
            SizedBox(width: AppSpacing.space12),
            const Text('Reiniciar aplicativo'),
          ],
        ),
        content: const Text(
          'O aplicativo será fechado e reiniciado. Todas as alterações serão aplicadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reiniciarApp();
            },
            child: const Text(
              'Reiniciar',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reiniciarApp() async {
    CustomSnackbar.show(
      context,
      message: 'Reiniciando aplicativo...',
      type: SnackbarType.info,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      // Remove todas as telas da pilha e volta para o login
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }
}
