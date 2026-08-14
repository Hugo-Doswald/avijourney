import '../models/airport.dart';

abstract interface class AirportSearchProvider {
  List<Airport> search(String query);
}
