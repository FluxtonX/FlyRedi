class FlightLookupResult {
  final String flightNumber;
  final String flightDate;
  final String status;
  final String origin;
  final String originAirport;
  final String destination;
  final String destinationAirport;
  final String airline;
  final String departureScheduled;
  final String arrivalScheduled;
  final int departureDelay;
  final int arrivalDelay;

  FlightLookupResult({
    required this.flightNumber,
    required this.flightDate,
    required this.status,
    required this.origin,
    required this.originAirport,
    required this.destination,
    required this.destinationAirport,
    required this.airline,
    required this.departureScheduled,
    required this.arrivalScheduled,
    required this.departureDelay,
    required this.arrivalDelay,
  });

  factory FlightLookupResult.fromJson(Map<String, dynamic> json) {
    return FlightLookupResult(
      flightNumber: json['flightNumber'] ?? '',
      flightDate: json['flightDate'] ?? '',
      status: json['status'] ?? 'planned',
      origin: json['origin'] ?? '',
      originAirport: json['originAirport'] ?? '',
      destination: json['destination'] ?? '',
      destinationAirport: json['destinationAirport'] ?? '',
      airline: json['airline'] ?? '',
      departureScheduled: json['departureScheduled'] ?? '',
      arrivalScheduled: json['arrivalScheduled'] ?? '',
      departureDelay: json['departureDelay'] ?? 0,
      arrivalDelay: json['arrivalDelay'] ?? 0,
    );
  }
}
