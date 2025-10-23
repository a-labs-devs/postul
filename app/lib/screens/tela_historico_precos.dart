import 'package:flutter/material.dart';
import '../models/favorito.dart';
import '../services/favoritos_service.dart';
import 'package:intl/intl.dart';

class TelaHistoricoPrecos extends StatefulWidget {
  final int postoId;
  final String postoNome;
  final String combustivel;

  TelaHistoricoPrecos({
    required this.postoId,
    required this.postoNome,
    required this.combustivel,
  });

  @override
  _TelaHistoricoPrecosState createState() => _TelaHistoricoPrecosState();
}

class _TelaHistoricoPrecosState extends State<TelaHistoricoPrecos> {
  final FavoritosService _favoritosService = FavoritosService();
  List<HistoricoPreco> _historico = [];
  bool _carregando = true;
  int _diasSelecionados = 30;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    setState(() {
      _carregando = true;
    });

    final historico = await _favoritosService.obterHistorico(
      postoId: widget.postoId,
      tipoCombustivel: widget.combustivel,
      dias: _diasSelecionados,
    );

    setState(() {
      _historico = historico;
      _carregando = false;
    });
  }

  Widget _buildGraficoSimples() {
    if (_historico.isEmpty) return SizedBox.shrink();

    final precoMinimo = _historico.map((h) => h.preco).reduce((a, b) => a < b ? a : b);
    final precoMaximo = _historico.map((h) => h.preco).reduce((a, b) => a > b ? a : b);
    final amplitude = precoMaximo - precoMinimo;

    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variação de Preço',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _historico.reversed.take(10).map((hist) {
                final altura = amplitude > 0 
                    ? ((hist.preco - precoMinimo) / amplitude) * 100 + 20
                    : 50.0;
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: altura,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: hist.precoCaiu
                                  ? [Colors.green.shade300, Colors.green.shade600]
                                  : hist.precoSubiu
                                      ? [Colors.red.shade300, Colors.red.shade600]
                                      : [Colors.blue.shade300, Colors.blue.shade600],
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: R\$ ${precoMinimo.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Máx: R\$ ${precoMaximo.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Preços'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.postoNome,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.combustivel,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildBotaoPeriodo('7 dias', 7),
                    SizedBox(width: 8),
                    _buildBotaoPeriodo('30 dias', 30),
                    SizedBox(width: 8),
                    _buildBotaoPeriodo('90 dias', 90),
                  ],
                ),
              ],
            ),
          ),
          if (!_carregando && _historico.isNotEmpty)
            _buildGraficoSimples(),
          Expanded(
            child: _carregando
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Carregando histórico...'),
                      ],
                    ),
                  )
                : _historico.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.show_chart,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Nenhum histórico encontrado',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _historico.length,
                        itemBuilder: (context, index) {
                          final hist = _historico[index];
                          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: hist.precoCaiu
                                      ? Colors.green.shade50
                                      : hist.precoSubiu
                                          ? Colors.red.shade50
                                          : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  hist.precoCaiu
                                      ? Icons.trending_down
                                      : hist.precoSubiu
                                          ? Icons.trending_up
                                          : Icons.remove,
                                  color: hist.precoCaiu
                                      ? Colors.green
                                      : hist.precoSubiu
                                          ? Colors.red
                                          : Colors.blue,
                                  size: 30,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    'R\$ ${hist.preco.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (hist.variacao != null) ...[
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: hist.precoCaiu
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${hist.variacao! > 0 ? '+' : ''}${hist.variacao!.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    dateFormat.format(hist.registradoEm),
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  if (hist.precoAnterior != null) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      'Anterior: R\$ ${hist.precoAnterior!.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                  if (hist.variacaoPercentual != null) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      '${hist.variacaoPercentual! > 0 ? '+' : ''}${hist.variacaoPercentual!.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: hist.precoCaiu
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoPeriodo(String label, int dias) {
    final selecionado = _diasSelecionados == dias;

    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _diasSelecionados = dias;
          });
          _carregarHistorico();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selecionado ? Colors.blue : Colors.white,
          foregroundColor: selecionado ? Colors.white : Colors.blue,
          elevation: selecionado ? 4 : 1,
        ),
        child: Text(label),
      ),
    );
  }
}