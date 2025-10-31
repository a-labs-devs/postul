import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// 🧭 POSTUL - Serviço de Algoritmo de Navegação Avançado
/// Implementa A* (A-star) com dados em tempo real
class NavigationAlgorithmService {
  // Raio da Terra em km
  static const double _earthRadiusKm = 6371.0;

  /// 📏 HAVERSINE: Calcula distância "em linha reta" entre dois pontos
  /// Usado como heurística (h) no algoritmo A*
  double calcularDistanciaHaversine(LatLng origem, LatLng destino) {
    final lat1 = _toRadians(origem.latitude);
    final lon1 = _toRadians(origem.longitude);
    final lat2 = _toRadians(destino.latitude);
    final lon2 = _toRadians(destino.longitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2);

    final c = 2 * math.asin(math.sqrt(a));

    return _earthRadiusKm * c; // Retorna em km
  }

  /// 🎯 ALGORITMO A* (A-STAR): Encontra a rota mais eficiente
  /// Considera: distância, tráfego, velocidade média, condições da via
  Future<RouteResult> calcularRotaAStar({
    required LatLng origem,
    required LatLng destino,
    TrafficData? trafficData,
  }) async {
    print('🚀 Iniciando cálculo A* de rota...');
    
    // Dados de tráfego em tempo real (simulado)
    final traffic = trafficData ?? TrafficData.simulate();

    // Inicializar estruturas do A*
    final openSet = PriorityQueue<Node>();
    final closedSet = <String>{};
    final cameFrom = <String, Node>{};

    // Nó inicial
    final startNode = Node(
      position: origem,
      g: 0, // Custo do início até este nó
      h: calcularDistanciaHaversine(origem, destino), // Heurística (Haversine)
    );

    openSet.add(startNode);

    // Grid de pontos intermediários (simula rede de ruas)
    final intermediatePoints = _gerarPontosIntermediarios(origem, destino);

    Node? destinoNode;
    int iteracoes = 0;
    final maxIteracoes = 100;

    // Loop principal do A*
    while (openSet.isNotEmpty && iteracoes < maxIteracoes) {
      iteracoes++;

      // Pega o nó com menor f (g + h)
      final currentNode = openSet.removeFirst();
      final currentKey = _nodeKey(currentNode.position);

      // Chegou ao destino?
      if (calcularDistanciaHaversine(currentNode.position, destino) < 0.05) {
        destinoNode = currentNode;
        break;
      }

      closedSet.add(currentKey);

      // Explorar vizinhos
      final vizinhos = _getVizinhos(
        currentNode.position,
        intermediatePoints,
        destino,
      );

      for (final vizinhoPos in vizinhos) {
        final vizinhoKey = _nodeKey(vizinhoPos);

        if (closedSet.contains(vizinhoKey)) continue;

        // Calcula custos
        final distancia = calcularDistanciaHaversine(
          currentNode.position,
          vizinhoPos,
        );

        // Aplica fatores de tráfego
        final trafficFactor = traffic.getTrafficFactor(vizinhoPos);
        final speedFactor = traffic.getSpeedFactor(vizinhoPos);

        // g(n) = custo real do caminho
        final tentativeG = currentNode.g + (distancia * trafficFactor * speedFactor);

        // h(n) = heurística (Haversine até o destino)
        final h = calcularDistanciaHaversine(vizinhoPos, destino);

        final vizinhoNode = Node(
          position: vizinhoPos,
          g: tentativeG,
          h: h,
          parent: currentNode,
        );

        // Adiciona à fila de prioridade (menor f primeiro)
        openSet.add(vizinhoNode);
        cameFrom[vizinhoKey] = currentNode;
      }
    }

    // Reconstrói o caminho
    if (destinoNode != null) {
      final path = _reconstruirCaminho(destinoNode);
      final totalDistance = destinoNode.g;
      final estimatedTime = _calcularTempoEstimado(path, traffic);

      print('✅ Rota A* encontrada: ${path.length} pontos, ${totalDistance.toStringAsFixed(2)} km');
      print('⏱️ Tempo estimado: ${estimatedTime.toStringAsFixed(0)} minutos');

      return RouteResult(
        pontos: path,
        distanciaTotal: totalDistance,
        tempoEstimado: estimatedTime,
        trafficData: traffic,
      );
    }

    // Fallback: linha reta se não encontrar rota
    print('⚠️ A* não encontrou rota, usando fallback');
    return RouteResult(
      pontos: [origem, destino],
      distanciaTotal: calcularDistanciaHaversine(origem, destino),
      tempoEstimado: 10,
      trafficData: traffic,
    );
  }

  /// 🗺️ Gera pontos intermediários (simula grid de ruas)
  List<LatLng> _gerarPontosIntermediarios(LatLng origem, LatLng destino) {
    final pontos = <LatLng>[];
    const steps = 10; // Grade 10x10

    final latDiff = destino.latitude - origem.latitude;
    final lonDiff = destino.longitude - origem.longitude;

    for (int i = 1; i <= steps; i++) {
      for (int j = 1; j <= steps; j++) {
        final lat = origem.latitude + (latDiff * i / steps);
        final lon = origem.longitude + (lonDiff * j / steps);
        pontos.add(LatLng(lat, lon));
      }
    }

    return pontos;
  }

  /// 👥 Pega vizinhos próximos do ponto atual
  List<LatLng> _getVizinhos(
    LatLng atual,
    List<LatLng> pontosDisponiveis,
    LatLng destino,
  ) {
    final vizinhos = <LatLng>[];

    // Adiciona pontos próximos (dentro de 0.5 km)
    for (final ponto in pontosDisponiveis) {
      final dist = calcularDistanciaHaversine(atual, ponto);
      if (dist < 0.5 && dist > 0.01) {
        vizinhos.add(ponto);
      }
    }

    // Sempre adiciona o destino como opção
    if (calcularDistanciaHaversine(atual, destino) < 2.0) {
      vizinhos.add(destino);
    }

    // Limita a 8 vizinhos (otimização)
    if (vizinhos.length > 8) {
      vizinhos.sort((a, b) {
        final distA = calcularDistanciaHaversine(a, destino);
        final distB = calcularDistanciaHaversine(b, destino);
        return distA.compareTo(distB);
      });
      return vizinhos.sublist(0, 8);
    }

    return vizinhos;
  }

  /// 🔄 Reconstrói o caminho do destino até a origem
  List<LatLng> _reconstruirCaminho(Node destinoNode) {
    final path = <LatLng>[];
    Node? current = destinoNode;

    while (current != null) {
      path.insert(0, current.position);
      current = current.parent;
    }

    return path;
  }

  /// ⏱️ Calcula tempo estimado considerando tráfego
  double _calcularTempoEstimado(List<LatLng> path, TrafficData traffic) {
    double tempoTotal = 0.0; // em minutos

    for (int i = 0; i < path.length - 1; i++) {
      final distancia = calcularDistanciaHaversine(path[i], path[i + 1]);
      final velocidadeMedia = traffic.getAverageSpeed(path[i]);
      
      // Tempo = distância / velocidade (convertido para minutos)
      tempoTotal += (distancia / velocidadeMedia) * 60;
    }

    return tempoTotal;
  }

  /// 🔑 Gera chave única para um nó
  String _nodeKey(LatLng position) {
    return '${position.latitude.toStringAsFixed(5)},${position.longitude.toStringAsFixed(5)}';
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}

/// 📦 NÓ DO ALGORITMO A*
class Node implements Comparable<Node> {
  final LatLng position;
  final double g; // Custo do início até este nó
  final double h; // Heurística (estimativa até o destino)
  final Node? parent;

  Node({
    required this.position,
    required this.g,
    required this.h,
    this.parent,
  });

  // f(n) = g(n) + h(n)
  double get f => g + h;

  @override
  int compareTo(Node other) => f.compareTo(other.f);
}

/// 🚦 DADOS DE TRÁFEGO EM TEMPO REAL
class TrafficData {
  final Map<String, double> trafficFactors; // 1.0 = normal, 2.0 = congestionado
  final Map<String, double> speedLimits; // km/h

  TrafficData({
    required this.trafficFactors,
    required this.speedLimits,
  });

  /// Simula dados de tráfego
  factory TrafficData.simulate() {
    final now = DateTime.now();
    final hour = now.hour;

    // Horários de pico (7-9h, 17-19h)
    final isPeakHour = (hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19);

    return TrafficData(
      trafficFactors: {
        'default': isPeakHour ? 1.8 : 1.0,
      },
      speedLimits: {
        'default': isPeakHour ? 25.0 : 40.0, // km/h
      },
    );
  }

  double getTrafficFactor(LatLng position) {
    // Aqui você pode implementar lógica baseada em APIs reais
    // Por enquanto, retorna valor padrão
    return trafficFactors['default'] ?? 1.0;
  }

  double getSpeedFactor(LatLng position) {
    // Fator baseado na velocidade da via
    final speed = getAverageSpeed(position);
    return 60.0 / speed; // Normaliza para 60 km/h
  }

  double getAverageSpeed(LatLng position) {
    return speedLimits['default'] ?? 40.0;
  }
}

/// 📊 RESULTADO DA ROTA
class RouteResult {
  final List<LatLng> pontos;
  final double distanciaTotal; // km
  final double tempoEstimado; // minutos
  final TrafficData trafficData;

  RouteResult({
    required this.pontos,
    required this.distanciaTotal,
    required this.tempoEstimado,
    required this.trafficData,
  });
}

/// 🎯 FILA DE PRIORIDADE PARA A*
class PriorityQueue<T extends Comparable> {
  final List<T> _elements = [];

  void add(T element) {
    _elements.add(element);
    _elements.sort();
  }

  T removeFirst() => _elements.removeAt(0);

  bool get isNotEmpty => _elements.isNotEmpty;
  bool get isEmpty => _elements.isEmpty;
  int get length => _elements.length;
}
