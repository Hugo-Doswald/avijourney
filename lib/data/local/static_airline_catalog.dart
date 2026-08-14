import '../../domain/models/airline.dart';

class StaticAirlineCatalog {
  const StaticAirlineCatalog();

  static const airlines = <Airline>[
    Airline(name: 'British Airways', iataCode: 'BA', icaoCode: 'BAW'),
    Airline(name: 'easyJet UK', iataCode: 'U2', icaoCode: 'EZY'),
    Airline(name: 'Emirates', iataCode: 'EK', icaoCode: 'UAE'),
    Airline(name: 'Virgin Atlantic', iataCode: 'VS', icaoCode: 'VIR'),
    Airline(name: 'Ryanair', iataCode: 'FR', icaoCode: 'RYR'),
    Airline(name: 'KLM', iataCode: 'KL', icaoCode: 'KLM'),
    Airline(name: 'Lufthansa', iataCode: 'LH', icaoCode: 'DLH'),
    Airline(name: 'Air France', iataCode: 'AF', icaoCode: 'AFR'),
    Airline(name: 'American Airlines', iataCode: 'AA', icaoCode: 'AAL'),
    Airline(name: 'United Airlines', iataCode: 'UA', icaoCode: 'UAL'),
  ];
}
