class DashboardSummary {
  final int alertsCount;
  final int casesCount;
  final String totalSavings;

  DashboardSummary({
    required this.alertsCount,
    required this.casesCount,
    required this.totalSavings,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      alertsCount: json['alertsCount'] ?? 0,
      casesCount: json['casesCount'] ?? 0,
      totalSavings: json['totalSavings'] ?? '₦0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alertsCount': alertsCount,
      'casesCount': casesCount,
      'totalSavings': totalSavings,
    };
  }
}
