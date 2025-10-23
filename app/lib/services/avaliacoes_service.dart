import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/avaliacao.dart';

class AvaliacoesService {
  static const String baseUrl = 'http://192.168.1.2:3000/api/avaliacoes';

  // Avaliar posto
  Future<Map<String, dynamic>> avaliar({
    required int postoId,
    required int usuarioId,
    required int nota,
    String? comentario,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'posto_id': postoId,
          'usuario_id': usuarioId,
          'nota': nota,
          'comentario': comentario,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'sucesso': true,
          'mensagem': data['mensagem'],
        };
      } else {
        return {
          'sucesso': false,
          'mensagem': data['mensagem'] ?? 'Erro ao avaliar posto',
        };
      }
    } catch (e) {
      return {
        'sucesso': false,
        'mensagem': 'Erro de conexão: $e',
      };
    }
  }

  // Listar avaliações de um posto
  Future<List<Avaliacao>> listarPorPosto(int postoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posto/$postoId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['sucesso'] == true && data['avaliacoes'] != null) {
          final List<dynamic> avaliacoesJson = data['avaliacoes'];
          return avaliacoesJson.map((json) => Avaliacao.fromJson(json)).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Erro ao listar avaliações: $e');
      return [];
    }
  }

  // Obter média de avaliações
  Future<MediaAvaliacao?> obterMedia(int postoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posto/$postoId/media'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['sucesso'] == true) {
          return MediaAvaliacao.fromJson(data);
        }
      }
      
      return null;
    } catch (e) {
      print('Erro ao obter média: $e');
      return null;
    }
  }

  // Obter avaliação do usuário
  Future<Avaliacao?> obterAvaliacaoUsuario(int postoId, int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posto/$postoId/usuario/$usuarioId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['sucesso'] == true && data['avaliacao'] != null) {
          return Avaliacao.fromJson(data['avaliacao']);
        }
      }
      
      return null;
    } catch (e) {
      print('Erro ao obter avaliação: $e');
      return null;
    }
  }

  // Deletar avaliação
  Future<Map<String, dynamic>> deletar(int postoId, int usuarioId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posto/$postoId/usuario/$usuarioId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'sucesso': true,
          'mensagem': data['mensagem'],
        };
      } else {
        return {
          'sucesso': false,
          'mensagem': data['mensagem'] ?? 'Erro ao deletar avaliação',
        };
      }
    } catch (e) {
      return {
        'sucesso': false,
        'mensagem': 'Erro de conexão: $e',
      };
    }
  }
}