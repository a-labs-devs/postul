class Posto {
  final int id;
  final String nome;
  final String endereco;
  final double latitude;
  final double longitude;
  final String? telefone;
  final bool aberto24h;
  final List<Preco>? precos;
  final double? distancia;

  Posto({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.latitude,
    required this.longitude,
    this.telefone,
    required this.aberto24h,
    this.precos,
    this.distancia,
  });

  factory Posto.fromJson(Map<String, dynamic> json) {
    List<Preco>? precosList;
    if (json['precos'] != null && json['precos'] is List) {
      precosList = (json['precos'] as List)
          .where((p) => p != null)
          .map((p) => Preco.fromJson(p))
          .toList();
    }

    return Posto(
      id: json['id'],
      nome: json['nome'],
      endereco: json['endereco'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      telefone: json['telefone'],
      aberto24h: json['aberto_24h'] ?? false,
      precos: precosList,
      distancia: json['distancia'] != null 
          ? double.parse(json['distancia'].toString()) 
          : null,
    );
  }

  // Encontrar menor preço de um tipo de combustível
  double? getMenorPreco(String tipoCombustivel) {
    if (precos == null || precos!.isEmpty) return null;
    
    final precosDoTipo = precos!
        .where((p) => p.tipo.toLowerCase().contains(tipoCombustivel.toLowerCase()))
        .toList();
    
    if (precosDoTipo.isEmpty) return null;
    
    return precosDoTipo
        .map((p) => p.preco)
        .reduce((a, b) => a < b ? a : b);
  }
}

class Preco {
  final int? id;
  final int? postoId;
  final String tipo;
  final double preco;
  final DateTime atualizadoEm;
  final int? usuarioId;
  final String? usuarioNome;

  Preco({
    this.id,
    this.postoId,
    required this.tipo,
    required this.preco,
    required this.atualizadoEm,
    this.usuarioId,
    this.usuarioNome,
  });

  factory Preco.fromJson(Map<String, dynamic> json) {
    return Preco(
      id: json['id'],
      postoId: json['posto_id'],
      tipo: json['tipo_combustivel'] ?? json['tipo'] ?? '',
      preco: double.parse(json['preco'].toString()),
      atualizadoEm: DateTime.parse(json['data_atualizacao'] ?? json['atualizado_em']),
      usuarioId: json['usuario_id'],
      usuarioNome: json['usuario_nome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'posto_id': postoId,
      'tipo': tipo,
      'tipo_combustivel': tipo,
      'preco': preco,
      'atualizado_em': atualizadoEm.toIso8601String(),
      'data_atualizacao': atualizadoEm.toIso8601String(),
      'usuario_id': usuarioId,
      'usuario_nome': usuarioNome,
    };
  }
}