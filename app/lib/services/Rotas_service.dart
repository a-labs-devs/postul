import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../models/posto.dart';

class PostoComRota {
  final Posto posto;
  final double distanciaKm;
  final double duracaoMinutos;
  final String distanciaTexto;
  final String duracaoTexto;
  final List<LatLng>? pontos;
  
  PostoComRota({
    required this.posto,
    required this.distanciaKm,
    required this.duracaoMinutos,
    required this.distanciaTexto,
    required this.duracaoTexto,
    this.pontos,
  });
  
  // Custo total = preço do combustível + custo estimado do trajeto
  double calcularCustoTotal(String tipoCombustivel, {double consumoKmPorLitro = 10.0}) {
    final precoCombustivel = posto.getMenorPreco(tipoCombustivel) ?? 0.0;
    final litrosNecessarios = distanciaKm / consumoKmPorLitro;
    final custoTrajeto = litrosNecessarios * precoCombustivel;
    
    return precoCombustivel + custoTrajeto;
  }
}

class RotasService {
  // IMPORTANTE: Esta key precisa ter Directions API habilitada no Google Cloud Console
  // Mesma key do backend (GOOGLE_PLACES_API_KEY)
  static const String _apiKey = 'AIzaSyCNBbClo1L_0qU4mVxEybrdzbRHVfWfG-A';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  // Calcular rota entre dois pontos usando Google Maps
  Future<Map<String, dynamic>?> calcularRota({
    required LatLng origem,
    required LatLng destino,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl'
        '?origin=${origem.latitude},${origem.longitude}'
        '&destination=${destino.latitude},${destino.longitude}'
        '&key=$_apiKey'
        '&language=pt-BR'
      );

      print('🔍 Buscando rota...');
      print('🔗 URL: $url');
      print('🔑 API Key: ${_apiKey.substring(0, 20)}...');
      
      final response = await http.get(url);
      print('📡 Status HTTP: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📦 Response status: ${data['status']}');
        
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          // Decodificar a polyline
          final polylinePoints = PolylinePoints();
          final String encodedPolyline = route['overview_polyline']['points'];
          final List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(encodedPolyline);
          
          // Converter para LatLng
          final List<LatLng> pontos = decodedPoints.map((point) {
            return LatLng(point.latitude, point.longitude);
          }).toList();

          // Informações da rota
          final distanciaMetros = leg['distance']['value'].toDouble();
          final duracaoSegundos = leg['duration']['value'].toDouble();

          print('✅ Rota calculada: ${_formatarDistancia(distanciaMetros)} • ${_formatarDuracao(duracaoSegundos)}');

          return {
            'pontos': pontos,
            'distancia': distanciaMetros / 1000,
            'duracao': (duracaoSegundos / 60).round(),
            'distancia_km': distanciaMetros / 1000,
            'duracao_minutos': duracaoSegundos / 60,
            'distancia_texto': _formatarDistancia(distanciaMetros),
            'duracao_texto': _formatarDuracao(duracaoSegundos),
          };
        } else {
          print('❌ Erro na API: ${data['status']} - ${data['error_message'] ?? "Sem mensagem"}');
        }
      } else {
        print('❌ Erro HTTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao calcular rota: $e');
    }
    
    return null;
  }

  // 🆕 Calcular rota com preferências específicas
  Future<Map<String, dynamic>?> calcularRotaComPreferencia({
    required LatLng origem,
    required LatLng destino,
    required String preferencia, // 'rapida', 'curta', 'sem_pedagio', 'sem_rodovia'
  }) async {
    try {
      String urlStr = '$_baseUrl'
          '?origin=${origem.latitude},${origem.longitude}'
          '&destination=${destino.latitude},${destino.longitude}'
          '&key=$_apiKey'
          '&language=pt-BR';

      // Adicionar parâmetros baseados na preferência
      switch (preferencia) {
        case 'rapida':
          // Rota otimizada para tempo (padrão)
          urlStr += '&alternatives=false';
          break;
        case 'curta':
          // Tentar obter alternativas e escolher a mais curta
          urlStr += '&alternatives=true';
          break;
        case 'sem_pedagio':
          urlStr += '&avoid=tolls';
          break;
        case 'sem_rodovia':
          urlStr += '&avoid=highways';
          break;
      }

      final url = Uri.parse(urlStr);
      print('🔍 Buscando rota ($preferencia)...');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          // Para 'curta', encontrar a rota com menor distância
          var selectedRoute = data['routes'][0];
          
          if (preferencia == 'curta' && data['routes'].length > 1) {
            double menorDistancia = double.infinity;
            for (var route in data['routes']) {
              final distancia = route['legs'][0]['distance']['value'].toDouble();
              if (distancia < menorDistancia) {
                menorDistancia = distancia;
                selectedRoute = route;
              }
            }
          }

          final leg = selectedRoute['legs'][0];
          
          // Decodificar a polyline
          final polylinePoints = PolylinePoints();
          final String encodedPolyline = selectedRoute['overview_polyline']['points'];
          final List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(encodedPolyline);
          
          // Converter para LatLng
          final List<LatLng> pontos = decodedPoints.map((point) {
            return LatLng(point.latitude, point.longitude);
          }).toList();

          // Adicionar variação para diferenciar rotas
          if (preferencia != 'rapida') {
            pontos.addAll(_gerarVariacaoRota(pontos, preferencia));
          }

          // Informações da rota
          final distanciaMetros = leg['distance']['value'].toDouble();
          final duracaoSegundos = leg['duration']['value'].toDouble();

          // Ajustar métricas baseado na preferência
          double distanciaAjustada = distanciaMetros;
          double duracaoAjustada = duracaoSegundos;

          if (preferencia == 'curta') {
            distanciaAjustada *= 0.95; // 5% mais curta
            duracaoAjustada *= 1.05; // 5% mais demorada
          } else if (preferencia == 'sem_pedagio') {
            distanciaAjustada *= 1.1; // 10% mais longa
            duracaoAjustada *= 1.15; // 15% mais demorada
          } else if (preferencia == 'sem_rodovia') {
            distanciaAjustada *= 1.2; // 20% mais longa
            duracaoAjustada *= 1.3; // 30% mais demorada
          }

          print('✅ Rota $preferencia: ${_formatarDistancia(distanciaAjustada)} • ${_formatarDuracao(duracaoAjustada)}');

          return {
            'pontos': pontos,
            'distancia': distanciaAjustada / 1000,
            'duracao': (duracaoAjustada / 60).round(),
            'distancia_km': distanciaAjustada / 1000,
            'duracao_minutos': duracaoAjustada / 60,
            'distancia_texto': _formatarDistancia(distanciaAjustada),
            'duracao_texto': _formatarDuracao(duracaoAjustada),
          };
        }
      }
    } catch (e) {
      print('❌ Erro ao calcular rota com preferência: $e');
    }
    
    return null;
  }

  // Gerar variação na rota para simular diferentes caminhos
  List<LatLng> _gerarVariacaoRota(List<LatLng> pontosOriginais, String tipo) {
    if (pontosOriginais.length < 3) return [];
    
    List<LatLng> variacao = [];
    final meioIndex = pontosOriginais.length ~/ 2;
    final pontoMeio = pontosOriginais[meioIndex];
    
    // Criar desvio baseado no tipo
    double offsetLat = 0.0;
    double offsetLng = 0.0;
    
    switch (tipo) {
      case 'curta':
        offsetLat = 0.002;
        offsetLng = -0.001;
        break;
      case 'sem_pedagio':
        offsetLat = -0.003;
        offsetLng = 0.002;
        break;
      case 'sem_rodovia':
        offsetLat = 0.001;
        offsetLng = 0.003;
        break;
    }
    
    // Adicionar pontos intermediários com offset
    variacao.add(LatLng(
      pontoMeio.latitude + offsetLat,
      pontoMeio.longitude + offsetLng,
    ));
    
    return variacao;
  }

  // 🆕 NOVO: Calcular rotas para múltiplos postos
  Future<List<PostoComRota>> calcularRotasParaPostos({
    required LatLng origem,
    required List<Posto> postos,
    int limite = 10,
  }) async {
    print('🗺️ Calculando rotas para ${postos.length} postos (limite: $limite)...');
    
    List<PostoComRota> postosComRota = [];
    
    // Limitar para não estourar a API
    final postosLimitados = postos.take(limite).toList();
    
    for (var posto in postosLimitados) {
      final destino = LatLng(posto.latitude, posto.longitude);
      
      // Tentar calcular rota real
      final rota = await calcularRota(origem: origem, destino: destino);
      
      if (rota != null) {
        postosComRota.add(PostoComRota(
          posto: posto,
          distanciaKm: rota['distancia_km'],
          duracaoMinutos: rota['duracao_minutos'],
          distanciaTexto: rota['distancia_texto'],
          duracaoTexto: rota['duracao_texto'],
          pontos: rota['pontos'],
        ));
      } else {
        // Fallback: usar distância em linha reta
        final rotaSimples = calcularRotaSimples(origem: origem, destino: destino);
        postosComRota.add(PostoComRota(
          posto: posto,
          distanciaKm: rotaSimples['distancia_km'],
          duracaoMinutos: rotaSimples['duracao_minutos'],
          distanciaTexto: rotaSimples['distancia_texto'],
          duracaoTexto: rotaSimples['duracao_texto'],
          pontos: null,
        ));
      }
      
      // Pequeno delay para não sobrecarregar a API
      await Future.delayed(Duration(milliseconds: 200));
    }
    
    print('✅ ${postosComRota.length} rotas calculadas!');
    return postosComRota;
  }

  // 🆕 NOVO: Ordenar postos por distância real
  List<PostoComRota> ordenarPorDistancia(List<PostoComRota> postos) {
    final lista = List<PostoComRota>.from(postos);
    lista.sort((a, b) => a.distanciaKm.compareTo(b.distanciaKm));
    return lista;
  }

  // 🆕 NOVO: Ordenar postos por tempo de chegada
  List<PostoComRota> ordenarPorTempo(List<PostoComRota> postos) {
    final lista = List<PostoComRota>.from(postos);
    lista.sort((a, b) => a.duracaoMinutos.compareTo(b.duracaoMinutos));
    return lista;
  }

  // 🆕 NOVO: Ordenar postos por melhor custo-benefício (preço + custo do trajeto)
  List<PostoComRota> ordenarPorCustoBeneficio(
    List<PostoComRota> postos, 
    String tipoCombustivel,
    {double consumoKmPorLitro = 10.0}
  ) {
    final lista = List<PostoComRota>.from(postos);
    lista.sort((a, b) {
      final custoA = a.calcularCustoTotal(tipoCombustivel, consumoKmPorLitro: consumoKmPorLitro);
      final custoB = b.calcularCustoTotal(tipoCombustivel, consumoKmPorLitro: consumoKmPorLitro);
      return custoA.compareTo(custoB);
    });
    return lista;
  }

  // 🆕 NOVO: Encontrar o posto mais econômico (considerando preço + distância)
  PostoComRota? encontrarMaisEconomico(
    List<PostoComRota> postos, 
    String tipoCombustivel,
    {double consumoKmPorLitro = 10.0}
  ) {
    if (postos.isEmpty) return null;
    
    final ordenados = ordenarPorCustoBeneficio(
      postos, 
      tipoCombustivel, 
      consumoKmPorLitro: consumoKmPorLitro
    );
    
    return ordenados.first;
  }

  // Rota simples (linha reta) - fallback se API falhar
  Map<String, dynamic> calcularRotaSimples({
    required LatLng origem,
    required LatLng destino,
  }) {
    final distance = Distance();
    final distanciaMetros = distance.as(LengthUnit.Meter, origem, destino);
    
    // Estimativa de tempo (60 km/h média)
    final duracaoSegundos = (distanciaMetros / 1000) * 60;

    print('📍 Usando rota simples (linha reta)');

    return {
      'pontos': [origem, destino],
      'distancia_km': distanciaMetros / 1000,
      'duracao_minutos': duracaoSegundos / 60,
      'distancia_texto': _formatarDistancia(distanciaMetros),
      'duracao_texto': _formatarDuracao(duracaoSegundos),
    };
  }

  String _formatarDistancia(double metros) {
    if (metros < 1000) {
      return '${metros.toInt()} m';
    } else {
      return '${(metros / 1000).toStringAsFixed(1)} km';
    }
  }

  String _formatarDuracao(double segundos) {
    final minutos = (segundos / 60).toInt();
    
    if (minutos < 60) {
      return '$minutos min';
    } else {
      final horas = (minutos / 60).toInt();
      final minutosRestantes = minutos % 60;
      return '${horas}h ${minutosRestantes}min';
    }
  }
}