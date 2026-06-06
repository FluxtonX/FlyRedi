class TripTimelineItem {
  final bool isFlight;
  final String? duration;
  final String? riskLevel;
  final String? riskColor;
  final String? info;
  final String? airlineCode;
  final String? from;
  final String? to;
  final String? fromTime;
  final String? toTime;
  final String? date;
  final String? delayProb;
  final int? activeAlerts;

  TripTimelineItem({
    required this.isFlight,
    this.duration,
    this.riskLevel,
    this.riskColor,
    this.info,
    this.airlineCode,
    this.from,
    this.to,
    this.fromTime,
    this.toTime,
    this.date,
    this.delayProb,
    this.activeAlerts,
  });

  factory TripTimelineItem.fromJson(Map<String, dynamic> json) {
    return TripTimelineItem(
      isFlight: json['isFlight'] ?? false,
      duration: json['duration'],
      riskLevel: json['riskLevel'],
      riskColor: json['riskColor'],
      info: json['info'],
      airlineCode: json['airlineCode'],
      from: json['from'],
      to: json['to'],
      fromTime: json['fromTime'],
      toTime: json['toTime'],
      date: json['date'],
      delayProb: json['delayProb'],
      activeAlerts: json['activeAlerts'],
    );
  }
}

class TripModel {
  final String id;
  final String userId;
  final String tripName;
  final String origin;
  final String destination;
  final String? totalDuration;
  final int stops;
  final List<TripTimelineItem> timeline;
  final bool trackingEnabled;
  final String status;
  final String? lastTrackedAt;
  final String? shareToken;
  final bool isShared;

  TripModel({
    required this.id,
    required this.userId,
    required this.tripName,
    required this.origin,
    required this.destination,
    this.totalDuration,
    required this.stops,
    required this.timeline,
    required this.trackingEnabled,
    required this.status,
    this.lastTrackedAt,
    this.shareToken,
    required this.isShared,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    var timelineList = json['timeline'] as List? ?? [];
    List<TripTimelineItem> timelineItems =
        timelineList.map((item) => TripTimelineItem.fromJson(item)).toList();

    return TripModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      tripName: json['tripName'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      totalDuration: json['totalDuration'],
      stops: json['stops'] ?? 0,
      timeline: timelineItems,
      trackingEnabled: json['trackingEnabled'] ?? false,
      status: json['status'] ?? 'planned',
      lastTrackedAt: json['lastTrackedAt'],
      shareToken: json['shareToken'],
      isShared: json['isShared'] ?? false,
    );
  }
}
