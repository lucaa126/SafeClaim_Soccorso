class RichiestaIntervento {
  final int id;
  final DateTime dataRichiesta;
  final DateTime? orarioArrivo;
  final String stato;

  RichiestaIntervento({
    required this.id,
    required this.dataRichiesta,
    this.orarioArrivo,
    required this.stato,
  });

  factory RichiestaIntervento.fromJson(Map<String, dynamic> json) {
    return RichiestaIntervento(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      dataRichiesta: DateTime.parse(json['data_richiesta'] ?? json['data'] ?? DateTime.now().toString()),
      orarioArrivo: json['orario_arrivo'] != null ? DateTime.parse(json['orario_arrivo']) : null,
      stato: json['stato'] ?? 'PENDING',
    );
  }
}