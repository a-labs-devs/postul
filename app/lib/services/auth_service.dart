import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

class AuthService {
  static const String baseUrl = 'http://alabsv.ddns.net:3001/api/auth';

  Future<Map<String, dynamic>> cadastrar({required String nome, required String email, required String senha}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/cadastrar'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}));
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        await _salvarToken(data['token']);
        return {'sucesso': true, 'mensagem': data['mensagem'], 'usuario': Usuario.fromJson(data['usuario'])};
      } else {
        return {'sucesso': false, 'mensagem': data['mensagem'] ?? 'Erro ao cadastrar'};
      }
    } catch (e) {
      return {'sucesso': false, 'mensagem': 'Erro de conexao: $e'};
    }
  }

  Future<Map<String, dynamic>> login({required String email, required String senha}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/login'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'senha': senha}));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await _salvarToken(data['token']);
        return {'sucesso': true, 'mensagem': data['mensagem'], 'usuario': Usuario.fromJson(data['usuario'])};
      } else {
        return {'sucesso': false, 'mensagem': data['mensagem'] ?? 'Erro ao fazer login'};
      }
    } catch (e) {
      return {'sucesso': false, 'mensagem': 'Erro de conexao: $e'};
    }
  }

  Future<void> _salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> obterToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<bool> estaLogado() async {
    final token = await obterToken();
    return token != null;
  }

  Future<Usuario?> usuarioAtual() async {
    try {
      final resultado = await verificarToken();
      if (resultado['sucesso'] == true && resultado['usuario'] != null) {
        return Usuario.fromJson(resultado['usuario']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> verificarToken() async {
    try {
      final token = await obterToken();
      if (token == null) {
        return {'sucesso': false, 'mensagem': 'Token nao encontrado'};
      }
      final response = await http.get(Uri.parse('$baseUrl/verificar'), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'sucesso': true, 'usuario': data['usuario']};
      } else {
        return {'sucesso': false, 'mensagem': data['mensagem'] ?? 'Token invalido'};
      }
    } catch (e) {
      return {'sucesso': false, 'mensagem': 'Erro de conexao: $e'};
    }
  }

  Future<Map<String, dynamic>> solicitarRecuperacao({required String email}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/solicitar-recuperacao'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email}));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'sucesso': true, 'mensagem': data['mensagem']};
      } else {
        return {'sucesso': false, 'mensagem': data['mensagem'] ?? 'Erro ao solicitar recuperacao'};
      }
    } catch (e) {
      return {'sucesso': false, 'mensagem': 'Erro de conexao: $e'};
    }
  }

  Future<Map<String, dynamic>> validarCodigo({required String email, required String codigo}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/validar-codigo'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'codigo': codigo}));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'sucesso': true, 'mensagem': data['mensagem']};
      } else {
        return {'sucesso': false, 'mensagem': data['mensagem'] ?? 'Codigo invalido'};
      }
    } catch (e) {
      return {'sucesso': false, 'mensagem': 'Erro de conexao: $e'};
    }
  }

  Future<Map<String, dynamic>> redefinirSenha({required String email, required String codigo, required String novaSenha}) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/redefinir-senha'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': email, 'codigo': codigo, 'novaSenha': novaSenha}));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'sucesso': true, 'mensagem': data['mensagem']};
      } else {
        return {'sucesso': false, 'mensagem': data['mensagem'] ?? 'Erro ao redefinir senha'};
      }
    } catch (e) {
      return {'sucesso': false, 'mensagem': 'Erro de conexao: $e'};
    }
  }
}
