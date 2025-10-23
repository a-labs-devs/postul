import 'package:flutter_tts/flutter_tts.dart';

class VoiceInstructionsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage("pt-BR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    if (_isSpeaking) await _flutterTts.stop();
    
    _isSpeaking = true;
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  String getInstructionText(String? instruction, double distance) {
    if (instruction == null) return "";

    String distanceText;
    if (distance < 100) {
      distanceText = "em ${distance.toInt()} metros";
    } else if (distance < 1000) {
      distanceText = "em ${(distance / 100).round() * 100} metros";
    } else {
      distanceText = "em ${(distance / 1000).toStringAsFixed(1)} quilômetros";
    }

    // Detectar tipo de manobra pela instrução
    if (instruction.toLowerCase().contains('vire à direita') ||
        instruction.toLowerCase().contains('turn right')) {
      return "Vire à direita $distanceText";
    } else if (instruction.toLowerCase().contains('vire à esquerda') ||
        instruction.toLowerCase().contains('turn left')) {
      return "Vire à esquerda $distanceText";
    } else if (instruction.toLowerCase().contains('continue') ||
        instruction.toLowerCase().contains('straight')) {
      return "Continue em frente $distanceText";
    } else if (instruction.toLowerCase().contains('rotunda') ||
        instruction.toLowerCase().contains('roundabout')) {
      return "Entre na rotatória $distanceText";
    } else if (instruction.toLowerCase().contains('chegou') ||
        instruction.toLowerCase().contains('arrived')) {
      return "Você chegou ao seu destino";
    }

    return instruction;
  }

  void dispose() {
    _flutterTts.stop();
  }
}