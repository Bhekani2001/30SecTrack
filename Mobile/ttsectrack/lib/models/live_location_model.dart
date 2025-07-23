class LiveLocation {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LiveLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LiveLocation.fromMap(Map<String, dynamic> map) {
    return LiveLocation(
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
