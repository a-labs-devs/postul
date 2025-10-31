import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'app_theme.dart';

/// 🎨 THEME PROVIDER - Gerencia tema e cores do app
class ThemeProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyColorTheme = 'color_theme';

  ThemeMode _themeMode = ThemeMode.light;
  String _currentColor = 'Azul';

  ThemeMode get themeMode => _themeMode;
  String get currentColor => _currentColor;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Mapa de cores disponíveis
  final Map<String, Color> availableColors = {
    'Azul': const Color(0xFF1976D2),
    'Verde': const Color(0xFF388E3C),
    'Roxo': const Color(0xFF7B1FA2),
    'Laranja': const Color(0xFFE64A19),
    'Rosa': const Color(0xFFE91E63),
    'Vermelho': const Color(0xFFD32F2F),
    'Turquesa': const Color(0xFF00897B),
  };

  ThemeProvider() {
    _loadPreferences();
  }

  /// Carrega preferências salvas
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Carregar modo de tema
      final themeModeString = prefs.getString(_keyThemeMode) ?? 'light';
      _themeMode = themeModeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
      
      // Carregar cor do tema
      _currentColor = prefs.getString(_keyColorTheme) ?? 'Azul';
      
      // Atualizar a cor primária do AppColors
      _updateAppColors();
      
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar preferências de tema: $e');
    }
  }

  /// Atualiza as cores do AppColors baseado na seleção
  void _updateAppColors() {
    final selectedColor = availableColors[_currentColor] ?? availableColors['Azul']!;
    AppColors.setPrimaryColor(selectedColor);
  }

  /// Alterna entre modo claro e escuro
  Future<void> toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyThemeMode, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    } catch (e) {
      print('Erro ao salvar modo de tema: $e');
    }
  }

  /// Define o modo de tema
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyThemeMode, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (e) {
      print('Erro ao salvar modo de tema: $e');
    }
  }

  /// Muda a cor do tema
  Future<void> changeColorTheme(String colorName) async {
    if (!availableColors.containsKey(colorName)) {
      print('Cor não disponível: $colorName');
      return;
    }

    _currentColor = colorName;
    _updateAppColors();
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyColorTheme, colorName);
    } catch (e) {
      print('Erro ao salvar cor do tema: $e');
    }
  }

  /// Obtém o ThemeData light atualizado
  ThemeData get lightTheme => AppTheme.lightTheme;

  /// Obtém o ThemeData dark atualizado
  ThemeData get darkTheme => AppTheme.darkTheme;
}
