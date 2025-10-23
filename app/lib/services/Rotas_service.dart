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
  static const String _apiKey = 'AIzaSyDTIpHb1i5mrduNAwRHFV1zamBhWrhhgXc';
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
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
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