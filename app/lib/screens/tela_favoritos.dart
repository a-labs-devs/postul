import 'package:flutter/material.dart';
import '../models/favorito.dart';
import '../services/favoritos_service.dart';
import 'tela_atualizar_preco.dart';
import 'tela_historico_precos.dart';

class TelaFavoritos extends StatefulWidget {
  final int usuarioId;

  TelaFavoritos({required this.usuarioId});

  @override
  _TelaFavoritosState createState() => _TelaFavoritosState();
}

class _TelaFavoritosState extends State<TelaFavoritos> {
  final FavoritosService _favoritosService = FavoritosService();
  List<Favorito> _favoritos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    setState(() {
      _carregando = true;
    });

    final favoritos = await _favoritosService.listar(widget.usuarioId);
    
    setState(() {
      _favoritos = favoritos;
      _carregando = false;
    });
  }

  Future<void> _removerFavorito(Favorito favorito) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Favorito'),
        content: Text('Deseja remover "${favorito.postoNome}" dos favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final sucesso = await _favoritosService.remover(favorito.id);
      
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❤️ Favorito removido'),
            backgroundColor: Colors.orange,
          ),
        );
        _carregarFavoritos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao remover favorito'),
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
        title: Text('Meus Favoritos'),
        backgroundColor: Colors.red,
      ),
      body: _carregando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Carregando favoritos...'),
                ],
              ),
            )
          : _favoritos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Nenhum favorito ainda',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Adicione postos aos favoritos\npara receber notificações',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregarFavoritos,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _favoritos.length,
                    itemBuilder: (context, index) {
                      final favorito = _favoritos[index];
                      final precoAtual = favorito.getPrecoAtual();
                      final atingiuAlvo = favorito.atingiuPrecoAlvo();

                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: atingiuAlvo
                              ? BorderSide(color: Colors.green, width: 2)
                              : BorderSide.none,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Abrir detalhes
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        favorito.postoNome ?? '',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removerFavorito(favorito),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        favorito.postoEndereco ?? '',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Divider(),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          favorito.combustivelPreferido,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        if (precoAtual != null)
                                          Text(
                                            'R\$ ${precoAtual.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: atingiuAlvo ? Colors.green : Colors.black,
                                            ),
                                          )
                                        else
                                          Text(
                                            'Sem preço',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (favorito.precoAlvo != null)
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: atingiuAlvo
                                              ? Colors.green.shade50
                                              : Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: atingiuAlvo
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Alvo',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: atingiuAlvo
                                                    ? Colors.green.shade700
                                                    : Colors.orange.shade700,
                                              ),
                                            ),
                                            Text(
                                              'R\$ ${favorito.precoAlvo!.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: atingiuAlvo
                                                    ? Colors.green.shade700
                                                    : Colors.orange.shade700,
                                              ),
                                            ),
                                            if (atingiuAlvo)
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 16,
                                              ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                if (atingiuAlvo) ...[
                                  SizedBox(height: 12),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.celebration, color: Colors.green, size: 20),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Preço alvo atingido! 🎉',
                                            style: TextStyle(
                                              color: Colors.green.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final posto = favorito.toPosto();
                                          if (posto != null) {
                                            final resultado = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => TelaAtualizarPreco(
                                                  posto: posto,
                                                  usuarioId: widget.usuarioId,
                                                ),
                                              ),
                                            );
                                            if (resultado == true) {
                                              _carregarFavoritos();
                                            }
                                          }
                                        },
                                        icon: Icon(Icons.edit, size: 18),
                                        label: Text('Atualizar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TelaHistoricoPrecos(
                                                postoId: favorito.postoId,
                                                postoNome: favorito.postoNome ?? '',
                                                combustivel: favorito.combustivelPreferido,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.show_chart, size: 18),
                                        label: Text('Histórico'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}