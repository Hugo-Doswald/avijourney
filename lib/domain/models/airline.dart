class Airline {
  const Airline({required this.name, this.iataCode, this.icaoCode});

  final String name;
  final String? iataCode;
  final String? icaoCode;

  String get identifier => icaoCode ?? iataCode ?? name;
}
