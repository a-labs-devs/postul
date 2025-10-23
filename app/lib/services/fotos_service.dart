import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/foto_posto.dart';

class FotosService {
  static const String baseUrl = 'http://192.168.1.2:3000/api/fotos';
  static const String uploadsUrl = 'http://192.168.1.2:3000';

  // Upload de foto
  Future<Map<String, dynamic>> uploadFoto({
    required int postoId,
    required int usuarioId,
    required File foto,
    String? descricao,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      
      request.fields['posto_id'] = postoId.toString();
      request.fields['usuario_id'] = usuarioId.toString();
      if (descricao != null && descricao.isNotEmpty) {
        request.fields['descricao'] = descricao;
      }

      request.files.add(await http.MultipartFile.fromPath('foto', foto.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return {
          'sucesso': true,
          'mensagem': data['mensagem'],
        };
      } else {
        return {
          'sucesso': false,
          'mensagem': data['mensagem'] ?? 'Erro ao enviar foto',
        };
      }
    } catch (e) {
      return {
        'sucesso': false,
        'mensagem': 'Erro de conexão: $e',
      };
    }
  }

  // Listar fotos de um posto
  Future<List<FotoPosto>> listarPorPosto(int postoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posto/$postoId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['sucesso'] == true && data['fotos'] != null) {
          final List<dynamic> fotosJson = data['fotos'];
          return fotosJson.map((json) => FotoPosto.fromJson(json)).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Erro ao listar fotos: $e');
      return [];
    }
  }

  // Contar fotos de um posto
  Future<int> contarFotos(int postoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posto/$postoId/count'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['sucesso'] == true) {
          return data['total'] ?? 0;
        }
      }
      
      return 0;
    } catch (e) {
      print('Erro ao contar fotos: $e');
      return 0;
    }
  }

  // Deletar foto
  Future<Map<String, dynamic>> deletar(int fotoId, int usuarioId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$fotoId/usuario/$usuarioId'),
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
          'mensagem': data['mensagem'] ?? 'Erro ao deletar foto',
        };
      }
    } catch (e) {
      return {
        'sucesso': false,
        'mensagem': 'Erro de conexão: $e',
      };
    }
  }

  // Obter URL completa da foto
  String getUrlCompleta(String urlRelativa) {
    return '$uploadsUrl$urlRelativa';
  }
}