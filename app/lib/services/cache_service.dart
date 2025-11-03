import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 💾 Serviço de Cache Local
/// Gerencia cache de postos, preços e dados do app
class CacheService {
  static const String _keyPostos = 'cache_postos';
  static const String _keyPostosTimestamp = 'cache_postos_timestamp';
  static const String _keyPrecos = 'cache_precos';
  static const String _keyPrecosTimestamp = 'cache_precos_timestamp';
  
  // Tempo de validade do cache (em minutos)
  static const int _cacheValidityMinutes = 30;

  /// Salvar postos no cache
  Future<void> salvarPostos(List<Map<String, dynamic>> postos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String postosJson = jsonEncode(postos);
      
      await prefs.setString(_keyPostos, postosJson);
      await prefs.setInt(_keyPostosTimestamp, DateTime.now().millisecondsSinceEpoch);
      
      print('✅ Cache: ${postos.length} postos salvos');
    } catch (e) {
      print('❌ Erro ao salvar postos no cache: $e');
    }
  }

  /// Obter postos do cache (se válido)
  /// Se [ignorarValidade] for true, retorna dados mesmo que expirados (útil como fallback)
  Future<List<Map<String, dynamic>>?> obterPostos({bool ignorarValidade = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Verificar se existe cache
      if (!prefs.containsKey(_keyPostos)) {
        print('ℹ️ Cache: Nenhum dado de postos encontrado');
        return null;
      }

      // Verificar validade do cache (a menos que seja ignorada)
      if (!ignorarValidade) {
        final timestamp = prefs.getInt(_keyPostosTimestamp);
        if (timestamp == null || !_isCacheValid(timestamp)) {
          print('⏰ Cache: Dados de postos expirados');
          await limparPostos();
          return null;
        }
      }

      // Recuperar dados
      final String? postosJson = prefs.getString(_keyPostos);
      if (postosJson == null) return null;

      final List<dynamic> decoded = jsonDecode(postosJson);
      final List<Map<String, dynamic>> postos = 
          decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      
      final timestamp = prefs.getInt(_keyPostosTimestamp);
      final idade = timestamp != null ? _getCacheAge(timestamp) : -1;
      
      if (ignorarValidade && idade > _cacheValidityMinutes) {
        print('⚠️ Cache: ${postos.length} postos carregados (EXPIRADO - idade: ${idade}min)');
      } else {
        print('✅ Cache: ${postos.length} postos carregados (idade: ${idade}min)');
      }
      
      return postos;
    } catch (e) {
      print('❌ Erro ao obter postos do cache: $e');
      return null;
    }
  }

  /// Salvar preços no cache
  Future<void> salvarPrecos(Map<int, Map<String, dynamic>> precos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Converter Map<int, Map> para Map<String, Map> (JSON não aceita int como key)
      final Map<String, dynamic> precosParaSalvar = {};
      precos.forEach((key, value) {
        precosParaSalvar[key.toString()] = value;
      });
      
      final String precosJson = jsonEncode(precosParaSalvar);
      
      await prefs.setString(_keyPrecos, precosJson);
      await prefs.setInt(_keyPrecosTimestamp, DateTime.now().millisecondsSinceEpoch);
      
      print('✅ Cache: Preços de ${precos.length} postos salvos');
    } catch (e) {
      print('❌ Erro ao salvar preços no cache: $e');
    }
  }

  /// Obter preços do cache (se válido)
  Future<Map<int, Map<String, dynamic>>?> obterPrecos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Verificar se existe cache
      if (!prefs.containsKey(_keyPrecos)) {
        print('ℹ️ Cache: Nenhum dado de preços encontrado');
        return null;
      }

      // Verificar validade do cache
      final timestamp = prefs.getInt(_keyPrecosTimestamp);
      if (timestamp == null || !_isCacheValid(timestamp)) {
        print('⏰ Cache: Dados de preços expirados');
        await limparPrecos();
        return null;
      }

      // Recuperar dados
      final String? precosJson = prefs.getString(_keyPrecos);
      if (precosJson == null) return null;

      final Map<String, dynamic> decoded = jsonDecode(precosJson);
      
      // Converter Map<String, Map> de volta para Map<int, Map>
      final Map<int, Map<String, dynamic>> precos = {};
      decoded.forEach((key, value) {
        precos[int.parse(key)] = Map<String, dynamic>.from(value);
      });
      
      final idade = _getCacheAge(timestamp);
      print('✅ Cache: Preços de ${precos.length} postos carregados (idade: ${idade}min)');
      return precos;
    } catch (e) {
      print('❌ Erro ao obter preços do cache: $e');
      return null;
    }
  }

  /// Verificar se cache é válido (não expirou)
  bool _isCacheValid(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffMinutes = (now - timestamp) / (1000 * 60);
    return diffMinutes < _cacheValidityMinutes;
  }

  /// Obter idade do cache em minutos
  int _getCacheAge(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffMinutes = (now - timestamp) / (1000 * 60);
    return diffMinutes.round();
  }

  /// Limpar cache de postos
  Future<void> limparPostos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPostos);
      await prefs.remove(_keyPostosTimestamp);
      print('🗑️ Cache de postos limpo');
    } catch (e) {
      print('❌ Erro ao limpar cache de postos: $e');
    }
  }

  /// Limpar cache de preços
  Future<void> limparPrecos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPrecos);
      await prefs.remove(_keyPrecosTimestamp);
      print('🗑️ Cache de preços limpo');
    } catch (e) {
      print('❌ Erro ao limpar cache de preços: $e');
    }
  }

  /// Limpar todo o cache
  Future<void> limparTudo() async {
    await limparPostos();
    await limparPrecos();
    print('🗑️ Todo cache limpo');
  }

  /// Obter informações do cache
  Future<Map<String, dynamic>> obterInfoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final postosTimestamp = prefs.getInt(_keyPostosTimestamp);
      final precosTimestamp = prefs.getInt(_keyPrecosTimestamp);
      
      return {
        'postos': {
          'existe': prefs.containsKey(_keyPostos),
          'valido': postosTimestamp != null && _isCacheValid(postosTimestamp),
          'idade_minutos': postosTimestamp != null ? _getCacheAge(postosTimestamp) : null,
        },
        'precos': {
          'existe': prefs.containsKey(_keyPrecos),
          'valido': precosTimestamp != null && _isCacheValid(precosTimestamp),
          'idade_minutos': precosTimestamp != null ? _getCacheAge(precosTimestamp) : null,
        },
      };
    } catch (e) {
      print('❌ Erro ao obter info do cache: $e');
      return {};
    }
  }
}
