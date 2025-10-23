class Avaliacao {
  final int id;
  final int postoId;
  final int usuarioId;
  final int nota;
  final String? comentario;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;
  final String? usuarioNome;

  Avaliacao({
    required this.id,
    required this.postoId,
    required this.usuarioId,
    required this.nota,
    this.comentario,
    required this.dataCriacao,
    required this.dataAtualizacao,
    this.usuarioNome,
  });

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      id: json['id'],
      postoId: json['posto_id'],
      usuarioId: json['usuario_id'],
      nota: json['nota'],
      comentario: json['comentario'],
      dataCriacao: DateTime.parse(json['data_criacao']),
      dataAtualizacao: DateTime.parse(json['data_atualizacao']),
      usuarioNome: json['usuario_nome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'posto_id': postoId,
      'usuario_id': usuarioId,
      'nota': nota,
      'comentario': comentario,
      'data_criacao': dataCriacao.toIso8601String(),
      'data_atualizacao': dataAtualizacao.toIso8601String(),
      'usuario_nome': usuarioNome,
    };
  }
}

class MediaAvaliacao {
  final double notaMedia;
  final int totalAvaliacoes;
  final int estrelas5;
  final int estrelas4;
  final int estrelas3;
  final int estrelas2;
  final int estrelas1;

  MediaAvaliacao({
    required this.notaMedia,
    required this.totalAvaliacoes,
    required this.estrelas5,
    required this.estrelas4,
    required this.estrelas3,
    required this.estrelas2,
    required this.estrelas1,
  });

  factory MediaAvaliacao.fromJson(Map<String, dynamic> json) {
    return MediaAvaliacao(
      notaMedia: double.parse(json['nota_media'].toString()),
      totalAvaliacoes: int.parse(json['total_avaliacoes'].toString()),
      estrelas5: int.parse(json['estrelas_5'].toString()),
      estrelas4: int.parse(json['estrelas_4'].toString()),
      estrelas3: int.parse(json['estrelas_3'].toString()),
      estrelas2: int.parse(json['estrelas_2'].toString()),
      estrelas1: int.parse(json['estrelas_1'].toString()),
    );
  }
}