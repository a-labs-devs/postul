import 'package:flutter/material.dart';

// ARQUIVO ANTIGO DESABILITADO
// Use: lib/screens/new/map_screen.dart

class TelaMapa extends StatelessWidget {
  final int usuarioId;

  const TelaMapa({Key? key, required this.usuarioId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Antiga Desabilitada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Esta tela foi desabilitada',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Use a nova interface em:'),
            Text('lib/screens/new/map_screen.dart'),
          ],
        ),
      ),
    );
  }
}
