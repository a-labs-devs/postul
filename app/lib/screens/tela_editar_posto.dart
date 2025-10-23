import 'package:flutter/material.dart';
import '../models/posto.dart';
import '../services/postos_service.dart';

class TelaEditarPosto extends StatefulWidget {
  final Posto posto;

  TelaEditarPosto({required this.posto});

  @override
  _TelaEditarPostoState createState() => _TelaEditarPostoState();
}

class _TelaEditarPostoState extends State<TelaEditarPosto> {
  final _formKey = GlobalKey<FormState>();
  final _postosService = PostosService();
  
  late TextEditingController _nomeController;
  late TextEditingController _enderecoController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _telefoneController;
  late bool _aberto24h;
  
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.posto.nome);
    _enderecoController = TextEditingController(text: widget.posto.endereco);
    _latitudeController = TextEditingController(text: widget.posto.latitude.toString());
    _longitudeController = TextEditingController(text: widget.posto.longitude.toString());
    _telefoneController = TextEditingController(text: widget.posto.telefone ?? '');
    _aberto24h = widget.posto.aberto24h;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _enderecoController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvarEdicao() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    final sucesso = await _postosService.editarPosto(
      id: widget.posto.id,
      nome: _nomeController.text.trim(),
      endereco: _enderecoController.text.trim(),
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      telefone: _telefoneController.text.trim().isEmpty 
          ? null 
          : _telefoneController.text.trim(),
      aberto24h: _aberto24h,
    );

    setState(() {
      _salvando = false;
    });

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Posto atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Retorna true para atualizar a lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao atualizar posto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Posto'),
        backgroundColor: Colors.blue,
      ),
      body: _salvando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Salvando alterações...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome
                    Text(
                      'Nome do Posto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Posto Ipiranga Centro',
                        prefixIcon: Icon(Icons.local_gas_station),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nome é obrigatório';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Endereço
                    Text(
                      'Endereço',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _enderecoController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Av. Paulista, 1000',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Endereço é obrigatório';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Coordenadas
                    Text(
                      'Coordenadas GPS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latitudeController,
                            decoration: InputDecoration(
                              labelText: 'Latitude',
                              prefixIcon: Icon(Icons.pin_drop),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Obrigatório';
                              }
                              final lat = double.tryParse(value.trim());
                              if (lat == null || lat < -90 || lat > 90) {
                                return 'Inválida';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _longitudeController,
                            decoration: InputDecoration(
                              labelText: 'Longitude',
                              prefixIcon: Icon(Icons.pin_drop),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Obrigatório';
                              }
                              final lng = double.tryParse(value.trim());
                              if (lng == null || lng < -180 || lng > 180) {
                                return 'Inválida';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Telefone
                    Text(
                      'Telefone (opcional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _telefoneController,
                      decoration: InputDecoration(
                        hintText: 'Ex: (11) 98765-4321',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Aberto 24h
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.schedule, color: Colors.blue),
                              SizedBox(width: 10),
                              Text(
                                'Aberto 24 horas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _aberto24h,
                            onChanged: (valor) {
                              setState(() {
                                _aberto24h = valor;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Botão Salvar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _salvarEdicao,
                        icon: Icon(Icons.save),
                        label: Text('Salvar Alterações'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 10),
                    
                    // Dica
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber.shade800),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Dica: Use o Google Maps para obter coordenadas precisas',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}