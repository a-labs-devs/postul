import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 👤 Serviço para gerenciar perfil do usuário
class PerfilService {
  static const String _keyFotoPerfil = 'foto_perfil_path';
  static const String _keyNomeUsuario = 'nome_usuario';
  static const String _keyEmailUsuario = 'email_usuario';

  final ImagePicker _picker = ImagePicker();

  /// Selecionar foto da galeria
  Future<String?> selecionarFotoDaGaleria() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        return await _salvarFotoLocal(image.path);
      }
      return null;
    } catch (e) {
      print('Erro ao selecionar foto da galeria: $e');
      return null;
    }
  }

  /// Tirar foto com a câmera
  Future<String?> tirarFotoComCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        return await _salvarFotoLocal(image.path);
      }
      return null;
    } catch (e) {
      print('Erro ao tirar foto com câmera: $e');
      return null;
    }
  }

  /// Salvar foto no armazenamento local permanente
  Future<String?> _salvarFotoLocal(String imagePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'perfil_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(appDir.path, fileName);

      // Copiar arquivo para o diretório do app
      final File imageFile = File(imagePath);
      await imageFile.copy(savedPath);

      // Salvar caminho no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyFotoPerfil, savedPath);

      // Deletar foto antiga se existir
      final oldPath = await obterCaminhoFotoPerfil();
      if (oldPath != null && oldPath != savedPath) {
        try {
          final oldFile = File(oldPath);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (e) {
          print('Erro ao deletar foto antiga: $e');
        }
      }

      return savedPath;
    } catch (e) {
      print('Erro ao salvar foto localmente: $e');
      return null;
    }
  }

  /// Obter caminho da foto de perfil salva
  Future<String?> obterCaminhoFotoPerfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fotoPath = prefs.getString(_keyFotoPerfil);

      // Verificar se o arquivo ainda existe
      if (fotoPath != null) {
        final file = File(fotoPath);
        if (await file.exists()) {
          return fotoPath;
        } else {
          // Arquivo não existe mais, limpar preferência
          await prefs.remove(_keyFotoPerfil);
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Erro ao obter foto de perfil: $e');
      return null;
    }
  }

  /// Remover foto de perfil
  Future<bool> removerFotoPerfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fotoPath = prefs.getString(_keyFotoPerfil);

      if (fotoPath != null) {
        // Deletar arquivo
        final file = File(fotoPath);
        if (await file.exists()) {
          await file.delete();
        }

        // Remover da preferência
        await prefs.remove(_keyFotoPerfil);
      }

      return true;
    } catch (e) {
      print('Erro ao remover foto de perfil: $e');
      return false;
    }
  }

  /// Salvar nome do usuário
  Future<void> salvarNomeUsuario(String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNomeUsuario, nome);
  }

  /// Obter nome do usuário
  Future<String> obterNomeUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNomeUsuario) ?? 'Usuário';
  }

  /// Salvar email do usuário
  Future<void> salvarEmailUsuario(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmailUsuario, email);
  }

  /// Obter email do usuário
  Future<String> obterEmailUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmailUsuario) ?? 'user@email.com';
  }
}
