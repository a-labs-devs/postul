import 'package:flutter/material.dart';

/// 📍 Marcador de Posto Customizado
/// Marcador estilizado para o mapa
class CustomMarker extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const CustomMarker({
    Key? key,
    required this.color,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = isSelected ? 36.0 : 32.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.local_gas_station,
          size: isSelected ? 18 : 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
