import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/favorito.dart';

class FavoritosService {
  static const String baseUrl = 'http://alabsv.ddns.net:3001/api/favoritos';
  // static const String baseUrl = 'http://192.168.1.2:3001/api/favoritos';

  // Listar favoritos do usuário
  Future<List<Favorito>> listar(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/listar?usuario_id=$usuarioId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List favoritosJson = data['favoritos'];
        return favoritosJson.map((json) => Favorito.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar favoritos');
      }
    } catch (e) {
      print('Erro ao listar favoritos: $e');
      return [];
    }
  }

  // Adicionar favorito
  Future<bool> adicionar({
    required int usuarioId,
    required int postoId,
    String combustivelPreferido = 'Gasolina Comum',
    double? precoAlvo,
    bool notificarSempre = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/adicionar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': usuarioId,
          'posto_id': postoId,
          'combustivel_preferido': combustivelPreferido,
          'preco_alvo': precoAlvo,
          'notificar_sempre': notificarSempre,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        print('Erro: ${data['mensagem']}');
        return false;
      }
    } catch (e) {
      print('Erro ao adicionar favorito: $e');
      return false;
    }
  }

  // Remover favorito
  Future<bool> remover(int favoritoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/remover/$favoritoId'),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erro ao remover favorito: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao remover favorito: $e');
      return false;
    }
  }

  // Atualizar favorito
  Future<bool> atualizar({
    required int favoritoId,
    String? combustivelPreferido,
    double? precoAlvo,
    bool? notificarSempre,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/atualizar/$favoritoId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'combustivel_preferido': combustivelPreferido,
          'preco_alvo': precoAlvo,
          'notificar_sempre': notificarSempre,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erro ao atualizar favorito: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao atualizar favorito: $e');
      return false;
    }
  }

  // Verificar se posto é favorito
  Future<Map<String, dynamic>> verificar({
    required int usuarioId,
    required int postoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verificar?usuario_id=$usuarioId&posto_id=$postoId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'favorito': data['favorito'] ?? false,
          'dados': data['dados'] != null ? Favorito.fromJson(data['dados']) : null,
        };
      } else {
        return {'favorito': false, 'dados': null};
      }
    } catch (e) {
      print('Erro ao verificar favorito: $e');
      return {'favorito': false, 'dados': null};
    }
  }

  // Obter histórico de preços
  Future<List<HistoricoPreco>> obterHistorico({
    required int postoId,
    required String tipoCombustivel,
    int dias = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/historico?posto_id=$postoId&tipo_combustivel=$tipoCombustivel&dias=$dias'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List historicoJson = data['historico'];
        return historicoJson.map((json) => HistoricoPreco.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar histórico');
      }
    } catch (e) {
      print('Erro ao obter histórico: $e');
      return [];
    }
  }

  // Verificar quedas de preço (para notificações)
  Future<List<Map<String, dynamic>>> verificarQuedasPreco() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verificar-quedas'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List notificacoesJson = data['notificacoes'];
        return List<Map<String, dynamic>>.from(notificacoesJson);
      } else {
        return [];
      }
    } catch (e) {
      print('Erro ao verificar quedas de preço: $e');
      return [];
    }
  }
}