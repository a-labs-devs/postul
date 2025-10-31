import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/posto.dart';

// ARQUIVO ANTIGO DESABILITADO
// Use: lib/screens/new/navigation_screen.dart

class TelaNavegacao extends StatelessWidget {
  final Posto destino;

  const TelaNavegacao({Key? key, required this.destino}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navegação - Tela Antiga')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Esta tela foi desabilitada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Use: lib/screens/new/navigation_screen.dart'),
          ],
        ),
      ),
    );
  }
}
