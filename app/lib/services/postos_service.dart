import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/posto.dart';

class PostosService {
static const String baseUrl = 'https://guestless-jinny-parsable.ngrok-free.dev/api/postos';
  // Listar todos os postos
  Future<List<Posto>> listarTodos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/listar'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List postosJson = data['postos'];
        return postosJson.map((json) => Posto.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar postos');
      }
    } catch (e) {
      print('Erro: $e');
      return [];
    }
  }

  // Buscar postos próximos
  Future<List<Posto>> buscarProximos({
    required double latitude,
    required double longitude,
    double raio = 5.0,
  }) async {
    try {
      final url = '$baseUrl/proximos?latitude=$latitude&longitude=$longitude&raio=$raio';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List postosJson = data['postos'];
        return postosJson.map((json) => Posto.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar postos próximos');
      }
    } catch (e) {
      print('Erro: $e');
      return [];
    }
  }
}