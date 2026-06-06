class AlertModel {
  final String id;
  final String userId;
  final String flightCode;
  final String airline;
  final String priority; // CRITICAL, HIGH, MEDIUM, LOW, INFO
  final String eventType;
  final String message;
  final bool isRead;
  final String source;
  final String? guardId;
  final String createdAt;

  AlertModel({
    required this.id,
    required this.userId,
    required this.flightCode,
    required this.airline,
    required this.priority,
    required this.eventType,
    required this.message,
    required this.isRead,
    required this.source,
    this.guardId,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      flightCode: json['flightCode'] ?? '',
      airline: json['airline'] ?? '',
      priority: json['priority'] ?? 'INFO',
      eventType: json['eventType'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      source: json['source'] ?? '',
      guardId: json['guardId'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  String get severityLabel {
    switch (priority.toUpperCase()) {
      case 'CRITICAL':
        return 'CRITICAL';
      case 'HIGH':
        return 'HIGH';
      case 'MEDIUM':
        return 'MEDIUM';
      case 'LOW':
        return 'LOW';
      default:
        return 'INFO';
    }
  }
}

class AlertListResponse {
  final List<AlertModel> alerts;
  final int page;
  final int pages;
  final int total;

  AlertListResponse({
    required this.alerts,
    required this.page,
    required this.pages,
    required this.total,
  });

  factory AlertListResponse.fromJson(Map<String, dynamic> json) {
    var alertList = json['alerts'] as List? ?? [];
    return AlertListResponse(
      alerts: alertList.map((a) => AlertModel.fromJson(a)).toList(),
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}
