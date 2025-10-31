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
    try {
      print('🔍 Parsing posto JSON: $json');
      
      List<Preco>? precosList;
      if (json['precos'] != null && json['precos'] is List) {
        precosList = (json['precos'] as List)
            .where((p) => p != null)
            .map((p) => Preco.fromJson(p))
            .toList();
      }

      final posto = Posto(
        id: json['id'] ?? 0,
        nome: json['nome']?.toString() ?? 'Posto sem nome',
        endereco: json['endereco']?.toString() ?? 'Endereço não informado',
        latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
        longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
        telefone: json['telefone']?.toString().isEmpty ?? true ? null : json['telefone']?.toString(),
        aberto24h: json['aberto_24h'] == true || json['aberto_24h'] == 1,
        precos: precosList,
        distancia: json['distancia'] != null 
            ? double.tryParse(json['distancia'].toString()) 
            : null,
      );
      
      print('✅ Posto parsed: ${posto.nome}');
      return posto;
    } catch (e, stackTrace) {
      print('❌ ERRO ao fazer parse de Posto:');
      print('JSON: $json');
      print('Erro: $e');
      print('Stack: $stackTrace');
      rethrow;
    }
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
    try {
      return Preco(
        id: json['id'],
        postoId: json['posto_id'],
        tipo: (json['tipo_combustivel'] ?? json['tipo'] ?? 'Não informado').toString(),
        preco: double.tryParse(json['preco']?.toString() ?? '0') ?? 0.0,
        atualizadoEm: json['data_atualizacao'] != null || json['atualizado_em'] != null
            ? DateTime.tryParse(json['data_atualizacao'] ?? json['atualizado_em']) ?? DateTime.now()
            : DateTime.now(),
        usuarioId: json['usuario_id'],
        usuarioNome: json['usuario_nome']?.toString(),
      );
    } catch (e) {
      print('❌ Erro ao fazer parse de Preco: $json');
      print('Erro: $e');
      rethrow;
    }
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