class ClaimModel {
  final String id;
  final String flightCode;
  final String airline;
  final String disruptionType;
  final String status;
  final double progress;
  final String? compensationAmount;

  ClaimModel({
    required this.id,
    required this.flightCode,
    required this.airline,
    required this.disruptionType,
    required this.status,
    required this.progress,
    this.compensationAmount,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    return ClaimModel(
      id: json['_id'] ?? json['id'] ?? '',
      flightCode: json['flightCode'] ?? '',
      airline: json['airline'] ?? '',
      disruptionType: json['disruptionType'] ?? '',
      status: json['status'] ?? 'PENDING',
      progress: (json['progress'] ?? 0.0).toDouble(),
      compensationAmount: json['compensationAmount'],
    );
  }
}
