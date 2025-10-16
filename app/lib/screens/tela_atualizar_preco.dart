import 'package:flutter/material.dart';
import '../models/posto.dart';
import '../services/precos_service.dart';

class TelaAtualizarPreco extends StatefulWidget {
  final Posto posto;
  final int usuarioId;

  TelaAtualizarPreco({required this.posto, required this.usuarioId});

  @override
  _TelaAtualizarPrecoState createState() => _TelaAtualizarPrecoState();
}

class _TelaAtualizarPrecoState extends State<TelaAtualizarPreco> {
  final _formKey = GlobalKey<FormState>();
  final _precoController = TextEditingController();
  final _precosService = PrecosService();
  
  String _tipoCombustivelSelecionado = 'Gasolina Comum';
  bool _carregando = false;

  final List<String> _tiposCombustivel = [
    'Gasolina Comum',
    'Gasolina Aditivada',
    'Etanol',
    'Diesel',
    'Diesel S10',
    'GNV',
  ];

  @override
  void dispose() {
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _atualizarPreco() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _carregando = true;
      });

      final preco = double.parse(_precoController.text.replaceAll(',', '.'));

      final resultado = await _precosService.atualizarPreco(
        postoId: widget.posto.id,
        tipoCombustivel: _tipoCombustivelSelecionado,
        preco: preco,
        usuarioId: widget.usuarioId,
      );

      setState(() {
        _carregando = false;
      });

      if (resultado['sucesso']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['mensagem']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retorna true para recarregar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['mensagem']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atualizar Preço'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_gas_station, color: Colors.blue, size: 30),
                    SizedBox(width: 12),
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
                          SizedBox(height: 4),
                          Text(
                            widget.posto.endereco,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Tipo de Combustível',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _tipoCombustivelSelecionado,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: Icon(Icons.local_gas_station),
                ),
                items: _tiposCombustivel.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _tipoCombustivelSelecionado = valor!;
                  });
                },
              ),
              SizedBox(height: 20),
              Text(
                'Preço (R\$)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _precoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Ex: 5.89',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço';
                  }
                  final preco = double.tryParse(value.replaceAll(',', '.'));
                  if (preco == null || preco <= 0) {
                    return 'Preço inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _atualizarPreco,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: _carregando
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Atualizar Preço',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}