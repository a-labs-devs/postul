import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/posto.dart';

class PrecosService {
  static const String baseUrl = 'http://192.168.1.2:3000/api/precos';

  // Buscar preços de um posto
  Future<List<Preco>> buscarPrecosPorPosto(int postoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posto/$postoId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['sucesso'] == true && data['precos'] != null) {
          final List<dynamic> precosJson = data['precos'];
          return precosJson.map((json) => Preco.fromJson(json)).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Erro ao buscar preços: $e');
      return [];
    }
  }

  // Atualizar preço
  Future<Map<String, dynamic>> atualizarPreco({
    required int postoId,
    required String tipoCombustivel,
    required double preco,
    required int usuarioId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'posto_id': postoId,
          'tipo_combustivel': tipoCombustivel,
          'preco': preco,
          'usuario_id': usuarioId,
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
          'mensagem': data['mensagem'] ?? 'Erro ao atualizar preço',
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