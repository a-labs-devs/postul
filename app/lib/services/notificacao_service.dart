import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/posto.dart';
import 'dart:math';

class NotificacaoService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _inicializado = false;

  // Configurações padrão
  static const double _descontoMinimo = 0.10; // 10% mais barato
  static const double _raioMaximo = 2000; // 2km
  
  // IDs para canais de notificação
  static const String _canalPrecosBaixos = 'precos_baixos';
  static const String _canalProximidade = 'proximidade';

  /// Inicializar notificações
  static Future<void> inicializar() async {
    if (_inicializado) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Criar canais de notificação Android
    await _criarCanais();
    
    _inicializado = true;
    print('✅ Serviço de notificações inicializado!');
  }

  /// Criar canais de notificação
  static Future<void> _criarCanais() async {
    const canalPrecos = AndroidNotificationChannel(
      _canalPrecosBaixos,
      'Preços Baixos',
      description: 'Alertas de preços mais baratos próximos a você',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const canalProx = AndroidNotificationChannel(
      _canalProximidade,
      'Postos Próximos',
      description: 'Alertas quando você passa perto de postos com bons preços',
      importance: Importance.defaultImportance,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(canalPrecos);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(canalProx);
  }

  /// Callback quando usuário toca na notificação
  static void _onNotificationTap(NotificationResponse response) {
    print('Notificação tocada: ${response.payload}');
    // Aqui você pode navegar para uma tela específica
  }

  /// Solicitar permissão de notificações
  static Future<bool> solicitarPermissao() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final result = await androidPlugin.requestNotificationsPermission();
      return result ?? false;
    }
    
    return true;
  }

  /// Verificar se notificações estão habilitadas
  static Future<bool> notificacoesHabilitadas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificacoes_ativas') ?? true;
  }

  /// Habilitar/desabilitar notificações
  static Future<void> setNotificacoesHabilitadas(bool ativo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificacoes_ativas', ativo);
  }

  /// Verificar preços baixos próximos
  static Future<void> verificarPrecosBaixos({
    required List<Posto> postos,
    required double latitudeAtual,
    required double longitudeAtual,
    String combustivelPreferido = 'gasolina',
  }) async {
    if (!_inicializado) await inicializar();
    if (!await notificacoesHabilitadas()) return;

    // Filtrar postos próximos (até 2km)
    final postosProximos = postos.where((posto) {
      final distancia = Geolocator.distanceBetween(
        latitudeAtual,
        longitudeAtual,
        posto.latitude,
        posto.longitude,
      );
      return distancia <= _raioMaximo;
    }).toList();

    if (postosProximos.isEmpty) return;

    // Encontrar menor preço
    double? menorPreco;
    Posto? postoMaisBarato;

    for (var posto in postosProximos) {
      final preco = posto.getMenorPreco(combustivelPreferido);
      if (preco != null) {
        if (menorPreco == null || preco < menorPreco) {
          menorPreco = preco;
          postoMaisBarato = posto;
        }
      }
    }

    if (postoMaisBarato == null || menorPreco == null) return;

    // Calcular preço médio
    final precos = postosProximos
        .map((p) => p.getMenorPreco(combustivelPreferido))
        .where((p) => p != null)
        .cast<double>()
        .toList();

    if (precos.isEmpty) return;

    final precoMedio = precos.reduce((a, b) => a + b) / precos.length;
    final economia = ((precoMedio - menorPreco) / precoMedio);

    // Notificar se economia >= 10%
    if (economia >= _descontoMinimo) {
      final distancia = Geolocator.distanceBetween(
        latitudeAtual,
        longitudeAtual,
        postoMaisBarato.latitude,
        postoMaisBarato.longitude,
      ) / 1000;

      await _enviarNotificacao(
        id: 1,
        titulo: '💰 Preço Baixo Encontrado!',
        corpo: '${postoMaisBarato.nome}\n'
            '${_formatarCombustivel(combustivelPreferido)}: R\$ ${menorPreco.toStringAsFixed(2)}\n'
            '${(economia * 100).toStringAsFixed(0)}% mais barato que a média!\n'
            '📍 ${distancia.toStringAsFixed(1)} km de você',
        canal: _canalPrecosBaixos,
        payload: 'posto_${postoMaisBarato.id}',
      );

      // Salvar para não notificar novamente em breve
      await _salvarUltimaNotificacao('preco_baixo', postoMaisBarato.id);
    }
  }

  /// Verificar proximidade de postos com bons preços
  static Future<void> verificarProximidade({
    required List<Posto> postos,
    required double latitudeAtual,
    required double longitudeAtual,
    String combustivelPreferido = 'gasolina',
    double raioAlerta = 500, // 500m
  }) async {
    if (!_inicializado) await inicializar();
    if (!await notificacoesHabilitadas()) return;

    for (var posto in postos) {
      final distancia = Geolocator.distanceBetween(
        latitudeAtual,
        longitudeAtual,
        posto.latitude,
        posto.longitude,
      );

      // Se está próximo (< 500m) e não foi notificado recentemente
      if (distancia <= raioAlerta) {
        if (await _foiNotificadoRecentemente('proximidade', posto.id)) continue;

        final preco = posto.getMenorPreco(combustivelPreferido);
        if (preco == null) continue;

        await _enviarNotificacao(
          id: posto.id + 1000,
          titulo: '📍 Posto Próximo',
          corpo: '${posto.nome}\n'
              '${_formatarCombustivel(combustivelPreferido)}: R\$ ${preco.toStringAsFixed(2)}\n'
              '${distancia.toStringAsFixed(0)}m de você',
          canal: _canalProximidade,
          payload: 'posto_${posto.id}',
        );

        await _salvarUltimaNotificacao('proximidade', posto.id);
      }
    }
  }

  /// Enviar notificação
  static Future<void> _enviarNotificacao({
    required int id,
    required String titulo,
    required String corpo,
    required String canal,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      canal,
      canal == _canalPrecosBaixos ? 'Preços Baixos' : 'Postos Próximos',
      importance: canal == _canalPrecosBaixos ? Importance.high : Importance.defaultImportance,
      priority: canal == _canalPrecosBaixos ? Priority.high : Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(corpo),
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, titulo, corpo, details, payload: payload);
    print('🔔 Notificação enviada: $titulo');
  }

  /// Salvar última notificação para evitar spam
  static Future<void> _salvarUltimaNotificacao(String tipo, int postoId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notif_${tipo}_$postoId';
    await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
  }

  /// Verificar se já foi notificado recentemente (últimas 2 horas)
  static Future<bool> _foiNotificadoRecentemente(String tipo, int postoId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notif_${tipo}_$postoId';
    final ultimaVez = prefs.getInt(key);
    
    if (ultimaVez == null) return false;
    
    final agora = DateTime.now().millisecondsSinceEpoch;
    final duasHoras = 2 * 60 * 60 * 1000;
    
    return (agora - ultimaVez) < duasHoras;
  }

  /// Formatar nome do combustível
  static String _formatarCombustivel(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'gasolina':
      case 'gasolina comum':
        return '⛽ Gasolina';
      case 'etanol':
        return '🌽 Etanol';
      case 'diesel':
        return '🚛 Diesel';
      case 'gnv':
        return '🔥 GNV';
      default:
        return tipo;
    }
  }

  /// Cancelar todas as notificações
  static Future<void> cancelarTodas() async {
    await _notifications.cancelAll();
  }

  /// Notificação de teste
  static Future<void> enviarNotificacaoTeste() async {
    if (!_inicializado) await inicializar();
    
    await _enviarNotificacao(
      id: 999,
      titulo: '🎉 Notificações Ativadas!',
      corpo: 'Você receberá alertas de preços baixos e postos próximos',
      canal: _canalPrecosBaixos,
    );
  }
}