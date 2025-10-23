import 'package:flutter/material.dart';

// Widget de alerta de velocidade
class SpeedLimitWarning extends StatelessWidget {
  final double currentSpeed;
  final double speedLimit;

  const SpeedLimitWarning({
    Key? key,
    required this.currentSpeed,
    required this.speedLimit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOverLimit = currentSpeed > speedLimit;
    
    if (!isOverLimit) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Velocidade máxima: ${speedLimit.toInt()} km/h',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de próximas manobras (lista pequena)
class UpcomingManeuvers extends StatelessWidget {
  final List<ManeuverInfo> maneuvers;

  const UpcomingManeuvers({
    Key? key,
    required this.maneuvers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Próximas manobras',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 10),
          ...maneuvers.take(3).map((maneuver) => _buildManeuverItem(maneuver)),
        ],
      ),
    );
  }

  Widget _buildManeuverItem(ManeuverInfo maneuver) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            maneuver.icon,
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              maneuver.instruction,
              style: TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            maneuver.distance,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de compass (bússola)
class NavigationCompass extends StatelessWidget {
  final double heading;

  const NavigationCompass({
    Key? key,
    required this.heading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
          ),
        ],
      ),
      child: Transform.rotate(
        angle: heading * (3.14159 / 180),
        child: Icon(
          Icons.navigation,
          color: Colors.blue.shade700,
          size: 30,
        ),
      ),
    );
  }
}

// Widget de ETA (Estimated Time of Arrival)
class ETAWidget extends StatelessWidget {
  final DateTime estimatedArrival;

  const ETAWidget({
    Key? key,
    required this.estimatedArrival,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hour = estimatedArrival.hour.toString().padLeft(2, '0');
    final minute = estimatedArrival.minute.toString().padLeft(2, '0');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, color: Colors.white, size: 16),
          SizedBox(width: 5),
          Text(
            'Chegada: $hour:$minute',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de rota alternativa
class AlternativeRouteButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isCalculating;

  const AlternativeRouteButton({
    Key? key,
    required this.onPressed,
    this.isCalculating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isCalculating ? null : onPressed,
      icon: isCalculating
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(Icons.alt_route),
      label: Text('Rota Alternativa'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}

// Widget de notificação de tráfego
class TrafficNotification extends StatelessWidget {
  final String message;
  final TrafficLevel level;

  const TrafficNotification({
    Key? key,
    required this.message,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    IconData icon;

    switch (level) {
      case TrafficLevel.heavy:
        backgroundColor = Colors.red;
        icon = Icons.traffic;
        break;
      case TrafficLevel.moderate:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case TrafficLevel.light:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de pontos de interesse na rota
class POIOnRoute extends StatelessWidget {
  final String name;
  final String type;
  final double distance;
  final VoidCallback onTap;

  const POIOnRoute({
    Key? key,
    required this.name,
    required this.type,
    required this.distance,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'posto':
        icon = Icons.local_gas_station;
        color = Colors.blue;
        break;
      case 'restaurante':
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'hotel':
        icon = Icons.hotel;
        color = Colors.purple;
        break;
      default:
        icon = Icons.place;
        color = Colors.grey;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${(distance / 1000).toStringAsFixed(1)} km da rota',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.add_circle_outline, color: color),
          ],
        ),
      ),
    );
  }
}

// Classes auxiliares
class ManeuverInfo {
  final String icon;
  final String instruction;
  final String distance;

  ManeuverInfo({
    required this.icon,
    required this.instruction,
    required this.distance,
  });
}

enum TrafficLevel { light, moderate, heavy }