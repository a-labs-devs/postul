import 'package:flutter/material.dart';
import '../models/posto.dart';
import '../services/avaliacoes_service.dart';

class TelaAvaliarPosto extends StatefulWidget {
  final Posto posto;
  final int usuarioId;

  TelaAvaliarPosto({required this.posto, required this.usuarioId});

  @override
  _TelaAvaliarPostoState createState() => _TelaAvaliarPostoState();
}

class _TelaAvaliarPostoState extends State<TelaAvaliarPosto> {
  final _avaliacoesService = AvaliacoesService();
  final _comentarioController = TextEditingController();
  int _notaSelecionada = 0;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _carregarAvaliacaoExistente();
  }

  Future<void> _carregarAvaliacaoExistente() async {
    setState(() => _carregando = true);
    
    final avaliacao = await _avaliacoesService.obterAvaliacaoUsuario(
      widget.posto.id,
      widget.usuarioId,
    );

    if (avaliacao != null) {
      setState(() {
        _notaSelecionada = avaliacao.nota;
        _comentarioController.text = avaliacao.comentario ?? '';
      });
    }

    setState(() => _carregando = false);
  }

  Future<void> _salvarAvaliacao() async {
    if (_notaSelecionada == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Selecione uma nota'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _carregando = true);

    final resultado = await _avaliacoesService.avaliar(
      postoId: widget.posto.id,
      usuarioId: widget.usuarioId,
      nota: _notaSelecionada,
      comentario: _comentarioController.text.trim().isEmpty 
          ? null 
          : _comentarioController.text.trim(),
    );

    setState(() => _carregando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultado['mensagem']),
        backgroundColor: resultado['sucesso'] ? Colors.green : Colors.red,
      ),
    );

    if (resultado['sucesso']) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avaliar Posto'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // INFO DO POSTO
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.local_gas_station, color: Colors.blue, size: 40),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.posto.nome,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  widget.posto.endereco,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // SELEÇÃO DE NOTA
                  Text(
                    'Sua avaliação',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final nota = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _notaSelecionada = nota);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              nota <= _notaSelecionada
                                  ? Icons.star
                                  : Icons.star_border,
                              color: nota <= _notaSelecionada
                                  ? Colors.amber
                                  : Colors.grey,
                              size: 50,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  if (_notaSelecionada > 0) ...[
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        _obterTextoNota(_notaSelecionada),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _obterCorNota(_notaSelecionada),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 30),

                  // COMENTÁRIO
                  Text(
                    'Comentário (opcional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),

                  TextField(
                    controller: _comentarioController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Conte mais sobre sua experiência...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),

                  SizedBox(height: 30),

                  // BOTÃO SALVAR
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _salvarAvaliacao,
                      icon: Icon(Icons.check_circle, size: 28),
                      label: Text(
                        'Salvar Avaliação',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _obterTextoNota(int nota) {
    switch (nota) {
      case 1:
        return '😞 Muito Ruim';
      case 2:
        return '😕 Ruim';
      case 3:
        return '😐 Regular';
      case 4:
        return '😊 Bom';
      case 5:
        return '🤩 Excelente';
      default:
        return '';
    }
  }

  Color _obterCorNota(int nota) {
    if (nota <= 2) return Colors.red;
    if (nota == 3) return Colors.orange;
    return Colors.green;
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }
}