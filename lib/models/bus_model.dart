class Bus {
  final String userId;
  final String firstName;
  final String lastName;
  final String busNumber;
  final String email;
  final List<dynamic> destinations;
  final String? currentDestination;
  final String? timeArrived;
  final String? timeLeft;
  final String? lastLocation;
  final int? passengers;
  final int? maxPassengers;
  final List<String> passengerNames;

  Bus({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.busNumber,
    required this.email,
    required this.destinations,
    this.currentDestination,
    this.timeArrived,
    this.timeLeft,
    this.lastLocation,
    this.passengers,
    this.maxPassengers,
    required this.passengerNames,
  });

  factory Bus.fromMap(Map<String, dynamic> map, String id) {
    return Bus(
      userId: map['userId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      busNumber: map['busNumber'] ?? '',
      email: map['email'] ?? '',
      destinations: List<dynamic>.from(map['destinations'] ?? []),
      currentDestination: map['currentDestination'],
      timeArrived: map['timeArrived'],
      timeLeft: map['timeLeft'],
      lastLocation: map['lastLocation'],
      passengers: map['passengers'],
      maxPassengers: map['maxPassengers'],
      passengerNames: List<String>.from(map['passengerNames'] ?? []),
    );
  }

  Bus copyWith({
    List<String>? passengerNames,
    int? passengers,
  }) {
    return Bus(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      busNumber: busNumber,
      email: email,
      destinations: destinations,
      currentDestination: currentDestination,
      timeArrived: timeArrived,
      timeLeft: timeLeft,
      lastLocation: lastLocation,
      passengers: passengers ?? this.passengers,
      maxPassengers: maxPassengers,
      passengerNames: passengerNames ?? this.passengerNames,
    );
  }

  @override
  String toString() {
    return 'Bus ID: $busNumber, Driver: $firstName $lastName, Email: $email, Passengers: $passengers, Max Passengers: $maxPassengers, Current Destination: $currentDestination, Time Arrived: $timeArrived, Time Left: $timeLeft, Last Location: $lastLocation';
  }
}
