import 'dart:async';
import 'dart:math';
import 'package:latlong2/latlong.dart';

class TrafficService {
  // Simulação de dados de tráfego (em produção, você usaria uma API real)
  final Map<String, TrafficData> _trafficCache = {};
  
  StreamController<TrafficAlert> alertController = StreamController<TrafficAlert>.broadcast();

  // Verificar tráfego na rota
  Future<TrafficData> checkTrafficOnRoute(List<LatLng> routePoints) async {
    // Em produção, você faria uma chamada à API (Google Maps, TomTom, etc)
    // Aqui vamos simular
    
    await Future.delayed(Duration(milliseconds: 500));
    
    final random = Random();
    final trafficLevel = random.nextInt(3); // 0=leve, 1=moderado, 2=pesado
    
    TrafficLevel level;
    int delayMinutes = 0;
    
    switch (trafficLevel) {
      case 0:
        level = TrafficLevel.light;
        delayMinutes = 0;
        break;
      case 1:
        level = TrafficLevel.moderate;
        delayMinutes = random.nextInt(10) + 5;
        break;
      case 2:
        level = TrafficLevel.heavy;
        delayMinutes = random.nextInt(20) + 15;
        break;
      default:
        level = TrafficLevel.light;
    }

    final trafficData = TrafficData(
      level: level,
      delayMinutes: delayMinutes,
      affectedSegments: [],
    );

    // Enviar alerta se tráfego pesado
    if (level == TrafficLevel.heavy) {
      alertController.add(TrafficAlert(
        type: AlertType.heavyTraffic,
        message: 'Trânsito pesado à frente! Atraso de $delayMinutes minutos',
        severity: AlertSeverity.warning,
      ));
    }

    return trafficData;
  }

  // Verificar acidentes ou incidentes
  Future<List<Incident>> checkIncidents(LatLng position, double radiusKm) async {
    // Simulação - em produção use API real
    await Future.delayed(Duration(milliseconds: 300));
    
    final random = Random();
    final incidents = <Incident>[];
    
    // 30% de chance de ter algum incidente
    if (random.nextInt(10) < 3) {
      incidents.add(Incident(
        type: IncidentType.values[random.nextInt(IncidentType.values.length)],
        location: LatLng(
          position.latitude + (random.nextDouble() - 0.5) * 0.01,
          position.longitude + (random.nextDouble() - 0.5) * 0.01,
        ),
        description: _getIncidentDescription(random),
        distanceMeters: random.nextInt(5000).toDouble(),
      ));
      
      // Enviar alerta
      alertController.add(TrafficAlert(
        type: AlertType.incident,
        message: incidents.first.description,
        severity: AlertSeverity.warning,
      ));
    }
    
    return incidents;
  }

  String _getIncidentDescription(Random random) {
    final descriptions = [
      'Acidente relatado à frente',
      'Obra na pista à frente',
      'Veículo parado na via',
      'Congestionamento à frente',
      'Radar de velocidade à frente',
    ];
    return descriptions[random.nextInt(descriptions.length)];
  }

  // Verificar radares de velocidade
  Future<List<SpeedCamera>> checkSpeedCameras(List<LatLng> routePoints) async {
    // Simulação - em produção use banco de dados de radares
    await Future.delayed(Duration(milliseconds: 200));
    
    final cameras = <SpeedCamera>[];
    final random = Random();
    
    // Simular alguns radares na rota
    for (int i = 0; i < routePoints.length; i += 50) {
      if (random.nextInt(10) < 2) { // 20% de chance
        cameras.add(SpeedCamera(
          location: routePoints[i],
          speedLimit: [60, 80, 100, 110][random.nextInt(4)],
          type: SpeedCameraType.fixed,
        ));
      }
    }
    
    return cameras;
  }

  // Alertar sobre radar próximo
  void alertSpeedCamera(SpeedCamera camera, double distanceMeters) {
    if (distanceMeters < 500 && distanceMeters > 400) {
      alertController.add(TrafficAlert(
        type: AlertType.speedCamera,
        message: 'Radar à frente! Limite: ${camera.speedLimit} km/h',
        severity: AlertSeverity.info,
      ));
    }
  }

  // Verificar condições climáticas
  Future<WeatherCondition> checkWeather(LatLng position) async {
    // Simulação - em produção use API de clima
    await Future.delayed(Duration(milliseconds: 300));
    
    final random = Random();
    final conditions = [
      WeatherCondition.clear,
      WeatherCondition.rain,
      WeatherCondition.fog,
    ];
    
    final condition = conditions[random.nextInt(conditions.length)];
    
    if (condition == WeatherCondition.rain || condition == WeatherCondition.fog) {
      alertController.add(TrafficAlert(
        type: AlertType.weather,
        message: condition == WeatherCondition.rain 
            ? 'Chuva na região - dirija com cuidado'
            : 'Neblina na região - reduza a velocidade',
        severity: AlertSeverity.warning,
      ));
    }
    
    return condition;
  }

  void dispose() {
    alertController.close();
  }
}

// Classes de dados
class TrafficData {
  final TrafficLevel level;
  final int delayMinutes;
  final List<String> affectedSegments;

  TrafficData({
    required this.level,
    required this.delayMinutes,
    required this.affectedSegments,
  });
}

enum TrafficLevel { light, moderate, heavy }

class Incident {
  final IncidentType type;
  final LatLng location;
  final String description;
  final double distanceMeters;

  Incident({
    required this.type,
    required this.location,
    required this.description,
    required this.distanceMeters,
  });
}

enum IncidentType { accident, construction, hazard, police, closedRoad }

class SpeedCamera {
  final LatLng location;
  final int speedLimit;
  final SpeedCameraType type;

  SpeedCamera({
    required this.location,
    required this.speedLimit,
    required this.type,
  });
}

enum SpeedCameraType { fixed, mobile }

enum WeatherCondition { clear, rain, fog, snow }

class TrafficAlert {
  final AlertType type;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;

  TrafficAlert({
    required this.type,
    required this.message,
    required this.severity,
  }) : timestamp = DateTime.now();
}

enum AlertType { heavyTraffic, incident, speedCamera, weather, accident }

enum AlertSeverity { info, warning, critical }