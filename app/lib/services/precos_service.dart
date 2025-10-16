import 'dart:convert';
import 'package:http/http.dart' as http;

class PrecosService {
  static const String baseUrl = 'https://guestless-jinny-parsable.ngrok-free.dev/api/precos';

  Future<Map<String, dynamic>> atualizarPreco({
    required int postoId,
    required String tipoCombustivel,
    required double preco,
    required int usuarioId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/atualizar'),
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