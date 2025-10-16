import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/postos_service.dart';
import '../models/posto.dart';
import 'tela_atualizar_preco.dart';


class TelaMapa extends StatefulWidget {
  final int usuarioId;

  TelaMapa({required this.usuarioId});

  @override
  _TelaMapaState createState() => _TelaMapaState();
}


class _TelaMapaState extends State<TelaMapa> {
  int get _usuarioId => widget.usuarioId;
  final MapController _mapController = MapController();
  final PostosService _postosService = PostosService();
  
  LatLng? _localizacaoAtual;
  List<Posto> _postos = [];
  bool _carregando = true;
  double _raioBusca = 10.0;
  bool _usarBuscaProximos =true;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _obterLocalizacao();
    await _carregarPostos();
  }
  Future<void> _obterLocalizacao() async {
    try {
      LocationPermission permissao = await Geolocator.checkPermission();
      
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
        if (permissao == LocationPermission.denied) {
          _mostrarErro('Permissão de localização negada');
          return;
        }
      }

      if (permissao == LocationPermission.deniedForever) {
        _mostrarErro('Permissão de localização negada permanentemente');
        return;
      }

      Position posicao = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _localizacaoAtual = LatLng(posicao.latitude, posicao.longitude);
      });

      _mapController.move(_localizacaoAtual!, 15.0);

    } catch (e) {
      _mostrarErro('Erro ao obter localização: $e');
    }
  }

  Future<void> _carregarPostos() async {
    try {
      final postos = await _postosService.listarTodos();
      setState(() {
        _postos = postos;
        _carregando = false;
      });
    } catch (e) {
      _mostrarErro('Erro ao carregar postos: $e');
      setState(() {
        _carregando = false;
      });
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }
 void _mostrarDetalhePosto(Posto posto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_gas_station, color: Colors.blue, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    posto.nome,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey, size: 20),
                SizedBox(width: 5),
                Expanded(child: Text(posto.endereco)),
              ],
            ),
            if (posto.telefone != null) ...[
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.grey, size: 20),
                  SizedBox(width: 5),
                  Text(posto.telefone!),
                ],
              ),
            ],
            SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  posto.aberto24h ? Icons.schedule : Icons.access_time,
                  color: posto.aberto24h ? Colors.green : Colors.orange,
                  size: 20,
                ),
                SizedBox(width: 5),
                Text(
                  posto.aberto24h ? 'Aberto 24h' : 'Horário comercial',
                  style: TextStyle(
                    color: posto.aberto24h ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (posto.precos != null && posto.precos!.isNotEmpty) ...[
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              Text(
                'Preços',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: posto.precos!.length,
                  itemBuilder: (context, index) {
                    final preco = posto.precos![index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            preco.tipo,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'R\$ ${preco.preco.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              SizedBox(height: 20),
              Text(
                'Nenhum preço cadastrado ainda',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaAtualizarPreco(
                        posto: posto,
                        usuarioId: _usuarioId,
                      ),
                    ),
                  );
                  
                  if (resultado == true) {
                    setState(() {
                      _carregando = true;
                    });
                    _carregarPostos();
                  }
                },
                icon: Icon(Icons.edit),
                label: Text('Atualizar Preço'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
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
  
  void _mostrarMenuRaio() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Raio de Busca',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_raioBusca.toStringAsFixed(0)} km',
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ),
                Switch(
                  value: _usarBuscaProximos,
                  onChanged: (valor) {
                    setState(() {
                      _usarBuscaProximos = valor;
                    });
                    Navigator.pop(context);
                    _carregarPostos();
                  },
                  activeColor: Colors.blue,
                ),
                Text('Busca por proximidade'),
              ],
            ),
            if (_usarBuscaProximos) ...[
              Slider(
                value: _raioBusca,
                min: 1,
                max: 50,
                divisions: 49,
                label: '${_raioBusca.toStringAsFixed(0)} km',
                onChanged: (valor) {
                  setState(() {
                    _raioBusca = valor;
                  });
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _raioBusca = 5;
                      });
                    },
                    child: Text('5 km'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _raioBusca = 10;
                      });
                    },
                    child: Text('10 km'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _raioBusca = 20;
                      });
                    },
                    child: Text('20 km'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _raioBusca = 50;
                      });
                    },
                    child: Text('50 km'),
                  ),
                ],
              ),
            ],
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _carregando = true;
                  });
                  _carregarPostos();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Aplicar Filtro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Postos Próximos'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () {
              if (_localizacaoAtual != null) {
                _mapController.move(_localizacaoAtual!, 15.0);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _carregando = true;
              });
              _carregarPostos();
            },
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
                  Text('Carregando postos...'),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _localizacaoAtual ?? LatLng(-23.55, -46.63),
                    initialZoom: 13.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.postul',
                    ),
                    MarkerLayer(
                      markers: [
                        if (_localizacaoAtual != null)
                          Marker(
                            point: _localizacaoAtual!,
                            width: 80,
                            height: 80,
                            child: Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 40,
                            ),
                          ),
                        ..._postos.map((posto) {
                          return Marker(
                            point: LatLng(posto.latitude, posto.longitude),
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () => _mostrarDetalhePosto(posto),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.local_gas_station,
                                    color: Colors.red,
                                    size: 35,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      posto.nome.split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      '${_postos.length} postos encontrados',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarMenuRaio,
        icon: Icon(Icons.tune),
        label: Text('${_raioBusca.toStringAsFixed(0)} km'),
        backgroundColor: Colors.blue,
      ),
    );
  } 
} 
