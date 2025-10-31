import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/posto.dart';
import 'cache_service.dart';

class PostosService {
  static const String baseUrl = 'https://guestless-jinny-parsable.ngrok-free.dev/api/postos';
  final CacheService _cacheService = CacheService();

  // Listar todos os postos COM CACHE
  Future<List<Posto>> listarTodos({bool forcarAtualizacao = false}) async {
    try {
      // 1. Tentar carregar do cache primeiro (se não forçar atualização)
      if (!forcarAtualizacao) {
        final cachedData = await _cacheService.obterPostos();
        if (cachedData != null && cachedData.isNotEmpty) {
          print('⚡ Carregando postos do cache (${cachedData.length} itens)');
          return cachedData.map((json) => Posto.fromJson(json)).toList();
        }
      }

      // 2. Se não há cache ou forçou atualização, buscar do servidor
      print('🌐 Buscando postos do servidor...');
      final response = await http.get(
        Uri.parse('$baseUrl/listar'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List postosJson = data['postos'];
        
        // 3. Salvar no cache para próxima vez
        await _cacheService.salvarPostos(postosJson.cast<Map<String, dynamic>>());
        
        return postosJson.map((json) => Posto.fromJson(json)).toList();
      } else {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao buscar postos: $e');
      // Propagar o erro para ser tratado na UI
      rethrow;
    }
  }

  // Buscar postos por área (bounding box) - OTIMIZADO PARA MAPA
  Future<List<Posto>> buscarPorArea({
    required double latMin,
    required double latMax,
    required double lngMin,
    required double lngMax,
    int limit = 100,
  }) async {
    try {
      final url = '$baseUrl/area?latMin=$latMin&latMax=$latMax&lngMin=$lngMin&lngMax=$lngMax&limit=$limit';
      print('🗺️ Buscando postos na área visível do mapa...');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'ngrok-skip-browser-warning': 'true'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List postosJson = data['postos'];
        print('✅ ${postosJson.length} postos carregados na área');
        return postosJson.map((json) => Posto.fromJson(json)).toList();
      } else {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao buscar postos por área: $e');
      // Propagar o erro para ser tratado na UI
      rethrow;
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
      final response = await http.get(
        Uri.parse(url),
        headers: {'ngrok-skip-browser-warning': 'true'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List postosJson = data['postos'];
        return postosJson.map((json) => Posto.fromJson(json)).toList();
      } else {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao buscar postos próximos: $e');
      // Propagar o erro para ser tratado na UI
      rethrow;
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