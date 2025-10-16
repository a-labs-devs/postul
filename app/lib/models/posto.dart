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
}

class Preco {
  final String tipo;
  final double preco;
  final DateTime atualizadoEm;

  Preco({
    required this.tipo,
    required this.preco,
    required this.atualizadoEm,
  });

  factory Preco.fromJson(Map<String, dynamic> json) {
    return Preco(
      tipo: json['tipo'],
      preco: double.parse(json['preco'].toString()),
      atualizadoEm: DateTime.parse(json['atualizado_em']),
    );
  }
}