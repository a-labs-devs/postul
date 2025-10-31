import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

/// 🔊 Serviço de Instruções por Voz para Navegação
/// Fornece comandos de voz naturais e claros durante a navegação
class VoiceInstructionsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isEnabled = true;
  
  // Controle de instruções
  String? _lastInstruction;
  double? _lastDistance;
  DateTime? _lastSpeakTime;
  
  // Intervalos de distância para repetir instruções
  static const List<double> _distanceThresholds = [1000, 500, 200, 100, 50];

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage("pt-BR");
      await _flutterTts.setSpeechRate(0.5); // Velocidade normal
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      // Android específico
      await _flutterTts.awaitSpeakCompletion(true);

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        print('Erro TTS: $msg');
        _isSpeaking = false;
      });

      _isInitialized = true;
      print('✅ Voice Instructions Service inicializado');
    } catch (e) {
      print('❌ Erro ao inicializar TTS: $e');
    }
  }

  /// Ativar/desativar instruções de voz
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled && _isSpeaking) {
      stop();
    }
  }

  bool get isEnabled => _isEnabled;

  /// Falar texto
  Future<void> speak(String text) async {
    if (!_isEnabled) return;
    if (!_isInitialized) await initialize();
    if (_isSpeaking) await _flutterTts.stop();
    
    _isSpeaking = true;
    _lastSpeakTime = DateTime.now();
    await _flutterTts.speak(text);
  }

  /// Parar a fala
  Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  /// Processar instrução de navegação
  Future<void> announceNavigation({
    required String instruction,
    required double distanceToManeuver,
    String? streetName,
  }) async {
    if (!_isEnabled) return;

    // Verificar se deve anunciar baseado na distância
    if (!_shouldAnnounce(instruction, distanceToManeuver)) {
      return;
    }

    final text = _buildInstructionText(
      instruction: instruction,
      distance: distanceToManeuver,
      streetName: streetName,
    );

    if (text.isNotEmpty) {
      await speak(text);
      _lastInstruction = instruction;
      _lastDistance = distanceToManeuver;
    }
  }

  /// Verificar se deve anunciar a instrução
  bool _shouldAnnounce(String instruction, double distance) {
    // Se for uma nova instrução, sempre anunciar
    if (_lastInstruction != instruction) {
      return true;
    }

    // Verificar se cruzou um threshold de distância
    if (_lastDistance != null) {
      for (final threshold in _distanceThresholds) {
        if (_lastDistance! > threshold && distance <= threshold) {
          return true;
        }
      }
    }

    // Não anunciar se falou recentemente (menos de 5 segundos)
    if (_lastSpeakTime != null) {
      final timeSinceLastSpeak = DateTime.now().difference(_lastSpeakTime!);
      if (timeSinceLastSpeak.inSeconds < 5) {
        return false;
      }
    }

    return false;
  }

  /// Construir texto da instrução
  String _buildInstructionText({
    required String instruction,
    required double distance,
    String? streetName,
  }) {
    final distanceText = _formatDistance(distance);
    final maneuver = _parseManeuver(instruction);
    
    String text = '';

    // Construir frase baseada na manobra
    switch (maneuver.type) {
      case ManeuverType.turnRight:
        if (distance < 50) {
          text = 'Vire à direita agora';
        } else {
          text = 'Vire à direita $distanceText';
        }
        break;

      case ManeuverType.turnLeft:
        if (distance < 50) {
          text = 'Vire à esquerda agora';
        } else {
          text = 'Vire à esquerda $distanceText';
        }
        break;

      case ManeuverType.turnSlightRight:
        text = 'Mantenha à direita $distanceText';
        break;

      case ManeuverType.turnSlightLeft:
        text = 'Mantenha à esquerda $distanceText';
        break;

      case ManeuverType.turnSharpRight:
        text = 'Curva fechada à direita $distanceText';
        break;

      case ManeuverType.turnSharpLeft:
        text = 'Curva fechada à esquerda $distanceText';
        break;

      case ManeuverType.uturn:
        text = 'Faça o retorno $distanceText';
        break;

      case ManeuverType.straight:
        if (distance > 500) {
          text = 'Continue em frente por $distanceText';
        } else {
          text = 'Continue em frente';
        }
        break;

      case ManeuverType.roundabout:
        text = 'Entre na rotatória $distanceText';
        if (maneuver.exit != null) {
          text += ' e pegue a ${_ordinalNumber(maneuver.exit!)} saída';
        }
        break;

      case ManeuverType.merge:
        text = 'Entre na via $distanceText';
        break;

      case ManeuverType.rampRight:
        text = 'Pegue a saída à direita $distanceText';
        break;

      case ManeuverType.rampLeft:
        text = 'Pegue a saída à esquerda $distanceText';
        break;

      case ManeuverType.arrive:
        text = 'Você chegou ao seu destino';
        if (distance < 100 && distance > 0) {
          text += ', à $distanceText';
        }
        break;

      case ManeuverType.waypoint:
        text = 'Ponto intermediário alcançado';
        break;

      default:
        text = instruction;
    }

    // Adicionar nome da rua se disponível
    if (streetName != null && streetName.isNotEmpty && distance > 50) {
      if (maneuver.type != ManeuverType.arrive && 
          maneuver.type != ManeuverType.straight) {
        text += ' na $streetName';
      }
    }

    return text;
  }

  /// Formatar distância em texto natural
  String _formatDistance(double meters) {
    if (meters < 50) {
      return '';
    } else if (meters < 100) {
      return 'em 50 metros';
    } else if (meters < 200) {
      return 'em 100 metros';
    } else if (meters < 500) {
      return 'em ${(meters / 50).round() * 50} metros';
    } else if (meters < 1000) {
      return 'em ${(meters / 100).round() * 100} metros';
    } else {
      final km = (meters / 1000).toStringAsFixed(1);
      return 'em $km quilômetros';
    }
  }

  /// Converter número em ordinal
  String _ordinalNumber(int number) {
    switch (number) {
      case 1: return 'primeira';
      case 2: return 'segunda';
      case 3: return 'terceira';
      case 4: return 'quarta';
      case 5: return 'quinta';
      case 6: return 'sexta';
      default: return '${number}ª';
    }
  }

  /// Anunciar início da navegação
  Future<void> announceNavigationStart(String destinationName) async {
    await speak('Iniciando navegação para $destinationName');
  }

  /// Anunciar recálculo de rota
  Future<void> announceRecalculating() async {
    await speak('Recalculando rota');
  }

  /// Anunciar chegada
  Future<void> announceArrival() async {
    await speak('Você chegou ao seu destino');
  }

  /// Anunciar velocidade
  Future<void> announceSpeed(double speedKmh, double speedLimit) async {
    if (speedKmh > speedLimit + 10) {
      await speak('Atenção, você está acima do limite de velocidade');
    }
  }

  /// Anunciar erro
  Future<void> announceError(String error) async {
    await speak('Atenção: $error');
  }

  /// Parse da instrução para identificar tipo de manobra
  _ManeuverInfo _parseManeuver(String instruction) {
    final lowerInstruction = instruction.toLowerCase();

    // Virar à direita
    if (lowerInstruction.contains('vire à direita') ||
        lowerInstruction.contains('turn right') ||
        lowerInstruction.contains('direita')) {
      return _ManeuverInfo(ManeuverType.turnRight);
    }

    // Virar à esquerda
    if (lowerInstruction.contains('vire à esquerda') ||
        lowerInstruction.contains('turn left') ||
        lowerInstruction.contains('esquerda')) {
      return _ManeuverInfo(ManeuverType.turnLeft);
    }

    // Curva suave à direita
    if (lowerInstruction.contains('mantenha à direita') ||
        lowerInstruction.contains('slight right') ||
        lowerInstruction.contains('keep right')) {
      return _ManeuverInfo(ManeuverType.turnSlightRight);
    }

    // Curva suave à esquerda
    if (lowerInstruction.contains('mantenha à esquerda') ||
        lowerInstruction.contains('slight left') ||
        lowerInstruction.contains('keep left')) {
      return _ManeuverInfo(ManeuverType.turnSlightLeft);
    }

    // Curva fechada
    if (lowerInstruction.contains('curva fechada à direita') ||
        lowerInstruction.contains('sharp right')) {
      return _ManeuverInfo(ManeuverType.turnSharpRight);
    }

    if (lowerInstruction.contains('curva fechada à esquerda') ||
        lowerInstruction.contains('sharp left')) {
      return _ManeuverInfo(ManeuverType.turnSharpLeft);
    }

    // Retorno
    if (lowerInstruction.contains('retorno') ||
        lowerInstruction.contains('u-turn') ||
        lowerInstruction.contains('meia volta')) {
      return _ManeuverInfo(ManeuverType.uturn);
    }

    // Rotatória
    if (lowerInstruction.contains('rotatória') ||
        lowerInstruction.contains('rotunda') ||
        lowerInstruction.contains('roundabout')) {
      // Tentar extrair número da saída
      final exitMatch = RegExp(r'(\d+)[ªº°]?\s*saída').firstMatch(lowerInstruction);
      final exit = exitMatch != null ? int.tryParse(exitMatch.group(1)!) : null;
      return _ManeuverInfo(ManeuverType.roundabout, exit: exit);
    }

    // Entrada/Saída
    if (lowerInstruction.contains('saída à direita') ||
        lowerInstruction.contains('ramp right')) {
      return _ManeuverInfo(ManeuverType.rampRight);
    }

    if (lowerInstruction.contains('saída à esquerda') ||
        lowerInstruction.contains('ramp left')) {
      return _ManeuverInfo(ManeuverType.rampLeft);
    }

    // Entrar na via
    if (lowerInstruction.contains('entre na via') ||
        lowerInstruction.contains('merge')) {
      return _ManeuverInfo(ManeuverType.merge);
    }

    // Chegada
    if (lowerInstruction.contains('chegou') ||
        lowerInstruction.contains('arrived') ||
        lowerInstruction.contains('destino')) {
      return _ManeuverInfo(ManeuverType.arrive);
    }

    // Continuar em frente (padrão)
    return _ManeuverInfo(ManeuverType.straight);
  }

  void dispose() {
    _flutterTts.stop();
  }
}

/// Tipos de manobra
enum ManeuverType {
  turnLeft,
  turnRight,
  turnSlightLeft,
  turnSlightRight,
  turnSharpLeft,
  turnSharpRight,
  uturn,
  straight,
  roundabout,
  merge,
  rampLeft,
  rampRight,
  arrive,
  waypoint,
  unknown,
}

/// Informação sobre a manobra
class _ManeuverInfo {
  final ManeuverType type;
  final int? exit; // Para rotatórias

  _ManeuverInfo(this.type, {this.exit});
}
