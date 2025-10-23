class FotoPosto {
  final int id;
  final int postoId;
  final int usuarioId;
  final String urlFoto;
  final String? descricao;
  final DateTime dataUpload;
  final String? usuarioNome;

  FotoPosto({
    required this.id,
    required this.postoId,
    required this.usuarioId,
    required this.urlFoto,
    this.descricao,
    required this.dataUpload,
    this.usuarioNome,
  });

  factory FotoPosto.fromJson(Map<String, dynamic> json) {
    return FotoPosto(
      id: json['id'],
      postoId: json['posto_id'],
      usuarioId: json['usuario_id'],
      urlFoto: json['url_foto'],
      descricao: json['descricao'],
      dataUpload: DateTime.parse(json['data_upload']),
      usuarioNome: json['usuario_nome'],
    );
  }
}