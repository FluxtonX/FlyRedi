class DashboardModule {
  final String key;
  final String name;
  final bool available;
  final String requiredPlan;

  DashboardModule({
    required this.key,
    required this.name,
    required this.available,
    required this.requiredPlan,
  });

  factory DashboardModule.fromJson(Map<String, dynamic> json) {
    return DashboardModule(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      available: json['available'] ?? false,
      requiredPlan: json['requiredPlan'] ?? 'Free',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'available': available,
      'requiredPlan': requiredPlan,
    };
  }
}
