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

  // Buscar posto por ID (NOVO)
  Future<Posto?> buscarPorId(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Posto.fromJson(data['posto']);
      } else {
        throw Exception('Erro ao buscar posto');
      }
    } catch (e) {
      print('Erro ao buscar posto: $e');
      return null;
    }
  }

  // Editar posto (NOVO)
  Future<bool> editarPosto({
    required int id,
    required String nome,
    required String endereco,
    required double latitude,
    required double longitude,
    String? telefone,
    required bool aberto24h,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/editar/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'endereco': endereco,
          'latitude': latitude,
          'longitude': longitude,
          'telefone': telefone,
          'aberto_24h': aberto24h,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['sucesso'] == true;
      } else {
        print('Erro ao editar posto: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao editar posto: $e');
      return false;
    }
  }

  // Deletar posto (NOVO)
  Future<bool> deletarPosto(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deletar/$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['sucesso'] == true;
      } else {
        print('Erro ao deletar posto: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao deletar posto: $e');
      return false;
    }
  }
}