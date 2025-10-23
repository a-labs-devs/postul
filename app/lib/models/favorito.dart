import 'posto.dart';

class Favorito {
  final int id;
  final int usuarioId;
  final int postoId;
  final String combustivelPreferido;
  final double? precoAlvo;
  final bool notificarSempre;
  final DateTime criadoEm;
  
  // Dados do posto (quando vem da API com JOIN)
  final String? postoNome;
  final String? postoEndereco;
  final double? latitude;
  final double? longitude;
  final String? telefone;
  final bool? aberto24h;
  final List<Preco>? precos;

  Favorito({
    required this.id,
    required this.usuarioId,
    required this.postoId,
    required this.combustivelPreferido,
    this.precoAlvo,
    required this.notificarSempre,
    required this.criadoEm,
    this.postoNome,
    this.postoEndereco,
    this.latitude,
    this.longitude,
    this.telefone,
    this.aberto24h,
    this.precos,
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    List<Preco>? precosList;
    if (json['precos'] != null && json['precos'] is List) {
      precosList = (json['precos'] as List)
          .where((p) => p != null)
          .map((p) => Preco.fromJson(p))
          .toList();
    }

    return Favorito(
      id: json['id'],
      usuarioId: json['usuario_id'],
      postoId: json['posto_id'],
      combustivelPreferido: json['combustivel_preferido'] ?? 'Gasolina Comum',
      precoAlvo: json['preco_alvo'] != null 
          ? double.parse(json['preco_alvo'].toString())
          : null,
      notificarSempre: json['notificar_sempre'] ?? true,
      criadoEm: DateTime.parse(json['criado_em']),
      postoNome: json['posto_nome'],
      postoEndereco: json['posto_endereco'],
      latitude: json['latitude'] != null 
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      telefone: json['telefone'],
      aberto24h: json['aberto_24h'],
      precos: precosList,
    );
  }

  // Converter para Posto (para reutilizar widgets)
  Posto? toPosto() {
    if (postoNome == null || postoEndereco == null || 
        latitude == null || longitude == null) {
      return null;
    }

    return Posto(
      id: postoId,
      nome: postoNome!,
      endereco: postoEndereco!,
      latitude: latitude!,
      longitude: longitude!,
      telefone: telefone,
      aberto24h: aberto24h ?? false,
      precos: precos,
    );
  }

  // Obter preço atual do combustível preferido
  double? getPrecoAtual() {
    if (precos == null || precos!.isEmpty) return null;
    
    final precosDoTipo = precos!
        .where((p) => p.tipo.toLowerCase().contains(combustivelPreferido.toLowerCase()))
        .toList();
    
    if (precosDoTipo.isEmpty) return null;
    
    return precosDoTipo.first.preco;
  }

  // Verificar se atingiu o preço alvo
  bool atingiuPrecoAlvo() {
    if (precoAlvo == null) return false;
    final precoAtual = getPrecoAtual();
    if (precoAtual == null) return false;
    return precoAtual <= precoAlvo!;
  }
}

class HistoricoPreco {
  final int id;
  final int postoId;
  final String tipoCombustivel;
  final double preco;
  final double? precoAnterior;
  final double? variacao;
  final double? variacaoPercentual;
  final DateTime registradoEm;

  HistoricoPreco({
    required this.id,
    required this.postoId,
    required this.tipoCombustivel,
    required this.preco,
    this.precoAnterior,
    this.variacao,
    this.variacaoPercentual,
    required this.registradoEm,
  });

  factory HistoricoPreco.fromJson(Map<String, dynamic> json) {
    return HistoricoPreco(
      id: json['id'],
      postoId: json['posto_id'],
      tipoCombustivel: json['tipo_combustivel'],
      preco: double.parse(json['preco'].toString()),
      precoAnterior: json['preco_anterior'] != null
          ? double.parse(json['preco_anterior'].toString())
          : null,
      variacao: json['variacao'] != null
          ? double.parse(json['variacao'].toString())
          : null,
      variacaoPercentual: json['variacao_percentual'] != null
          ? double.parse(json['variacao_percentual'].toString())
          : null,
      registradoEm: DateTime.parse(json['registrado_em']),
    );
  }

  // Verificar se preço subiu ou caiu
  bool get precoSubiu => variacao != null && variacao! > 0;
  bool get precoCaiu => variacao != null && variacao! < 0;
}