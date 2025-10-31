import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 📝 Serviço para gerenciar atualizações de postos
/// Salva preços, avaliações e fotos localmente
class PostoUpdateService {
  static const String _precosKey = 'postos_precos';
  static const String _avaliacoesKey = 'postos_avaliacoes';
  static const String _fotosKey = 'postos_fotos';

  // 💰 SALVAR PREÇOS
  static Future<void> salvarPrecos({
    required int postoId,
    double? gasolina,
    double? etanol,
    double? diesel,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final precosJson = prefs.getString(_precosKey) ?? '{}';
    final precos = Map<String, dynamic>.from(json.decode(precosJson));

    precos[postoId.toString()] = {
      'gasolina': gasolina,
      'etanol': etanol,
      'diesel': diesel,
      'dataAtualizacao': DateTime.now().toIso8601String(),
      'usuario': 'Usuario Atual', // TODO: Pegar do auth
    };

    await prefs.setString(_precosKey, json.encode(precos));
    print('✅ Preços salvos para posto $postoId');
  }

  // 📊 OBTER PREÇOS
  static Future<Map<String, dynamic>?> obterPrecos(int postoId) async {
    final prefs = await SharedPreferences.getInstance();
    final precosJson = prefs.getString(_precosKey) ?? '{}';
    final precos = Map<String, dynamic>.from(json.decode(precosJson));
    return precos[postoId.toString()];
  }

  // ⭐ SALVAR AVALIAÇÃO
  static Future<void> salvarAvaliacao({
    required int postoId,
    required int estrelas,
    String? comentario,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final avaliacoesJson = prefs.getString(_avaliacoesKey) ?? '{}';
    final avaliacoes = Map<String, dynamic>.from(json.decode(avaliacoesJson));

    if (!avaliacoes.containsKey(postoId.toString())) {
      avaliacoes[postoId.toString()] = [];
    }

    final listaAvaliacoes = List<Map<String, dynamic>>.from(
      avaliacoes[postoId.toString()] ?? []
    );

    listaAvaliacoes.add({
      'estrelas': estrelas,
      'comentario': comentario,
      'data': DateTime.now().toIso8601String(),
      'usuario': 'Usuario Atual', // TODO: Pegar do auth
    });

    avaliacoes[postoId.toString()] = listaAvaliacoes;
    await prefs.setString(_avaliacoesKey, json.encode(avaliacoes));
    print('✅ Avaliação salva para posto $postoId: $estrelas estrelas');
  }

  // 📊 OBTER AVALIAÇÕES
  static Future<List<Map<String, dynamic>>> obterAvaliacoes(int postoId) async {
    final prefs = await SharedPreferences.getInstance();
    final avaliacoesJson = prefs.getString(_avaliacoesKey) ?? '{}';
    final avaliacoes = Map<String, dynamic>.from(json.decode(avaliacoesJson));
    
    if (!avaliacoes.containsKey(postoId.toString())) {
      return [];
    }

    return List<Map<String, dynamic>>.from(avaliacoes[postoId.toString()]);
  }

  // 📊 CALCULAR MÉDIA DE AVALIAÇÕES
  static Future<double> calcularMediaAvaliacoes(int postoId) async {
    final avaliacoes = await obterAvaliacoes(postoId);
    if (avaliacoes.isEmpty) return 0.0;

    final soma = avaliacoes.fold<int>(
      0,
      (sum, avaliacao) => sum + (avaliacao['estrelas'] as int),
    );

    return soma / avaliacoes.length;
  }

  // 📸 SALVAR FOTO
  static Future<void> salvarFoto({
    required int postoId,
    required String caminhoFoto,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final fotosJson = prefs.getString(_fotosKey) ?? '{}';
    final fotos = Map<String, dynamic>.from(json.decode(fotosJson));

    if (!fotos.containsKey(postoId.toString())) {
      fotos[postoId.toString()] = [];
    }

    final listaFotos = List<String>.from(fotos[postoId.toString()] ?? []);
    listaFotos.add(caminhoFoto);

    fotos[postoId.toString()] = listaFotos;
    await prefs.setString(_fotosKey, json.encode(fotos));
    print('✅ Foto salva para posto $postoId');
  }

  // 📊 OBTER FOTOS
  static Future<List<String>> obterFotos(int postoId) async {
    final prefs = await SharedPreferences.getInstance();
    final fotosJson = prefs.getString(_fotosKey) ?? '{}';
    final fotos = Map<String, dynamic>.from(json.decode(fotosJson));
    
    if (!fotos.containsKey(postoId.toString())) {
      return [];
    }

    return List<String>.from(fotos[postoId.toString()]);
  }

  // 🗑️ LIMPAR TODOS OS DADOS (útil para debug)
  static Future<void> limparTodosDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_precosKey);
    await prefs.remove(_avaliacoesKey);
    await prefs.remove(_fotosKey);
    print('🗑️ Todos os dados de postos foram limpos');
  }

  // 📊 ESTATÍSTICAS GERAIS
  static Future<Map<String, int>> obterEstatisticas() async {
    final prefs = await SharedPreferences.getInstance();
    
    final precosJson = prefs.getString(_precosKey) ?? '{}';
    final precos = Map<String, dynamic>.from(json.decode(precosJson));
    
    final avaliacoesJson = prefs.getString(_avaliacoesKey) ?? '{}';
    final avaliacoes = Map<String, dynamic>.from(json.decode(avaliacoesJson));
    
    final fotosJson = prefs.getString(_fotosKey) ?? '{}';
    final fotos = Map<String, dynamic>.from(json.decode(fotosJson));

    int totalAvaliacoes = 0;
    avaliacoes.values.forEach((lista) {
      totalAvaliacoes += (lista as List).length;
    });

    int totalFotos = 0;
    fotos.values.forEach((lista) {
      totalFotos += (lista as List).length;
    });

    return {
      'postosComPrecos': precos.length,
      'totalAvaliacoes': totalAvaliacoes,
      'totalFotos': totalFotos,
      'postosAvaliados': avaliacoes.length,
      'postosComFotos': fotos.length,
    };
  }
}
