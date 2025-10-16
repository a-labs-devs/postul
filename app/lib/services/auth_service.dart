import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

class AuthService {
  // IMPORTANTE: Use o IP da sua máquina aqui
  static const String baseUrl = 'https://guestless-jinny-parsable.ngrok-free.dev/api/auth';
  Future<Map<String, dynamic>> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cadastrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Salvar token
        await _salvarToken(data['token']);
        return {
          'sucesso': true,
          'mensagem': data['mensagem'],
          'usuario': Usuario.fromJson(data['usuario']),
        };
      } else {
        return {
          'sucesso': false,
          'mensagem': data['mensagem'] ?? 'Erro ao cadastrar',
        };
      }
    } catch (e) {
      return {
        'sucesso': false,
        'mensagem': 'Erro de conexão: $e',
      };
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Salvar token
        await _salvarToken(data['token']);
        return {
          'sucesso': true,
          'mensagem': data['mensagem'],
          'usuario': Usuario.fromJson(data['usuario']),
        };
      } else {
        return {
          'sucesso': false,
          'mensagem': data['mensagem'] ?? 'Erro ao fazer login',
        };
      }
    } catch (e) {
      return {
        'sucesso': false,
        'mensagem': 'Erro de conexão: $e',
      };
    }
  }

  // Salvar token
  Future<void> _salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Obter token
  Future<String?> obterToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Verificar se está logado
  Future<bool> estaLogado() async {
    final token = await obterToken();
    return token != null;
  }
}