import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/posto.dart';
import '../models/foto_posto.dart';
import '../services/fotos_service.dart';

class TelaGaleriaFotos extends StatefulWidget {
  final Posto posto;
  final int usuarioId;

  TelaGaleriaFotos({required this.posto, required this.usuarioId});

  @override
  _TelaGaleriaFotosState createState() => _TelaGaleriaFotosState();
}

class _TelaGaleriaFotosState extends State<TelaGaleriaFotos> {
  final _fotosService = FotosService();
  final _picker = ImagePicker();
  List<FotoPosto> _fotos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarFotos();
  }

  Future<void> _carregarFotos() async {
    setState(() => _carregando = true);
    final fotos = await _fotosService.listarPorPosto(widget.posto.id);
    setState(() {
      _fotos = fotos;
      _carregando = false;
    });
  }

  Future<void> _tirarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (foto != null) {
        _mostrarDialogoDescricao(File(foto.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao acessar câmera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _escolherDaGaleria() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (foto != null) {
        _mostrarDialogoDescricao(File(foto.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao acessar galeria: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoDescricao(File foto) {
    final descricaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar descrição'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(foto, height: 200, fit: BoxFit.cover),
            SizedBox(height: 15),
            TextField(
              controller: descricaoController,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _enviarFoto(foto, descricaoController.text.trim());
            },
            child: Text('Enviar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarFoto(File foto, String? descricao) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final resultado = await _fotosService.uploadFoto(
      postoId: widget.posto.id,
      usuarioId: widget.usuarioId,
      foto: foto,
      descricao: descricao,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultado['mensagem']),
        backgroundColor: resultado['sucesso'] ? Colors.green : Colors.red,
      ),
    );

    if (resultado['sucesso']) {
      _carregarFotos();
    }
  }

  void _mostrarFotoCompleta(FotoPosto foto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(foto.usuarioNome ?? 'Foto'),
            actions: [
              if (foto.usuarioId == widget.usuarioId)
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _confirmarDeletar(foto),
                ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                _fotosService.getUrlCompleta(foto.urlFoto),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 100, color: Colors.white);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarDeletar(FotoPosto foto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deletar foto?'),
        content: Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Deletar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      Navigator.pop(context);
      
      final resultado = await _fotosService.deletar(foto.id, widget.usuarioId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['mensagem']),
          backgroundColor: resultado['sucesso'] ? Colors.green : Colors.red,
        ),
      );

      if (resultado['sucesso']) {
        _carregarFotos();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fotos do Posto'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? Center(child: CircularProgressIndicator())
          : _fotos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhuma foto ainda', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                      SizedBox(height: 8),
                      Text('Seja o primeiro a compartilhar!', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _fotos.length,
                  itemBuilder: (context, index) {
                    final foto = _fotos[index];
                    return GestureDetector(
                      onTap: () => _mostrarFotoCompleta(foto),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              _fotosService.getUrlCompleta(foto.urlFoto),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.broken_image, size: 50);
                              },
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [Colors.black87, Colors.transparent],
                                  ),
                                ),
                                child: Text(
                                  foto.usuarioNome ?? 'Usuário',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: _tirarFoto,
            child: Icon(Icons.camera_alt),
            backgroundColor: Colors.blue,
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: _escolherDaGaleria,
            child: Icon(Icons.photo_library),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }
}