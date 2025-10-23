import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/posto.dart';
import '../services/rotas_service.dart';

class TelaPostosMapeados extends StatefulWidget {
  final LatLng localizacaoAtual;
  final List<Posto> postos;
  final String combustivelFiltro;

  TelaPostosMapeados({
    required this.localizacaoAtual,
    required this.postos,
    required this.combustivelFiltro,
  });

  @override
  _TelaPostosMapeadosState createState() => _TelaPostosMapeadosState();
}

class _TelaPostosMapeadosState extends State<TelaPostosMapeados> {
  final RotasService _rotasService = RotasService();
  List<PostoComRota>? _postosComRota;
  bool _carregando = true;
  String _ordenacao = 'distancia'; // distancia, tempo, custo

  @override
  void initState() {
    super.initState();
    _calcularRotas();
  }

  Future<void> _calcularRotas() async {
    setState(() {
      _carregando = true;
    });

    final postosComRota = await _rotasService.calcularRotasParaPostos(
      origem: widget.localizacaoAtual,
      postos: widget.postos,
      limite: 20, // Calcular rotas para os 20 postos mais próximos
    );

    setState(() {
      _postosComRota = postosComRota;
      _carregando = false;
      _aplicarOrdenacao();
    });
  }

  void _aplicarOrdenacao() {
    if (_postosComRota == null) return;

    setState(() {
      switch (_ordenacao) {
        case 'distancia':
          _postosComRota = _rotasService.ordenarPorDistancia(_postosComRota!);
          break;
        case 'tempo':
          _postosComRota = _rotasService.ordenarPorTempo(_postosComRota!);
          break;
        case 'custo':
          _postosComRota = _rotasService.ordenarPorCustoBeneficio(
            _postosComRota!,
            widget.combustivelFiltro,
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Postos Mapeados'),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _ordenacao = value;
                _aplicarOrdenacao();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'distancia',
                child: Row(
                  children: [
                    Icon(Icons.straighten, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Ordenar por Distância'),
                    if (_ordenacao == 'distancia')
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.check, color: Colors.blue),
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'tempo',
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.orange),
                    SizedBox(width: 10),
                    Text('Ordenar por Tempo'),
                    if (_ordenacao == 'tempo')
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.check, color: Colors.orange),
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'custo',
                child: Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Melhor Custo-Benefício'),
                    if (_ordenacao == 'custo')
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.check, color: Colors.green),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _carregando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Calculando rotas reais...'),
                  SizedBox(height: 10),
                  Text(
                    'Isso pode levar alguns segundos',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _postosComRota == null || _postosComRota!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Nenhum posto encontrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header com informações
                    Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.blue.shade50,
                      child: Row(
                        children: [
                          Icon(Icons.map, color: Colors.blue),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_postosComRota!.length} postos mapeados',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Combustível: ${widget.combustivelFiltro}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _ordenacao == 'distancia'
                                  ? Colors.blue
                                  : _ordenacao == 'tempo'
                                      ? Colors.orange
                                      : Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _ordenacao == 'distancia'
                                  ? 'Distância'
                                  : _ordenacao == 'tempo'
                                      ? 'Tempo'
                                      : 'Custo-Benefício',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lista de postos
                    Expanded(
                      child: ListView.builder(
                        itemCount: _postosComRota!.length,
                        padding: EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final postoComRota = _postosComRota![index];
                          final posto = postoComRota.posto;
                          final preco = posto.getMenorPreco(widget.combustivelFiltro);
                          final ehMelhor = index == 0;

                          return Card(
                            elevation: ehMelhor ? 8 : 2,
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: ehMelhor
                                  ? BorderSide(color: Colors.green, width: 2)
                                  : BorderSide.none,
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context, posto);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: ehMelhor
                                                ? Colors.green.shade100
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.local_gas_station,
                                            color: ehMelhor ? Colors.green : Colors.grey.shade700,
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      posto.nome,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  if (ehMelhor)
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.star, color: Colors.white, size: 14),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            'MELHOR',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              SizedBox(height: 4),
                                              if (preco != null)
                                                Text(
                                                  'R\$ ${preco.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoChip(
                                            icon: Icons.straighten,
                                            label: postoComRota.distanciaTexto,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: _buildInfoChip(
                                            icon: Icons.access_time,
                                            label: postoComRota.duracaoTexto,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_ordenacao == 'custo' && preco != null) ...[
                                      SizedBox(height: 8),
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.calculate, size: 16, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text(
                                              'Custo total: R\$ ${postoComRota.calcularCustoTotal(widget.combustivelFiltro).toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '(${widget.combustivelFiltro} + trajeto)',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}