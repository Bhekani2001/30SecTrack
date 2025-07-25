import 'package:flutter_test/flutter_test.dart';
import 'package:ttsectrack/models/location_model.dart';

void main() {
  group('LocationModel', () {
    test('should create a valid instance', () {
      final now = DateTime.now();
      final location = LocationModel(
        latitude: 1.0,
        longitude: 2.0,
        accuracy: 3.0,
        timestamp: now,
      );
      expect(location.latitude, 1.0);
      expect(location.longitude, 2.0);
      expect(location.accuracy, 3.0);
      expect(location.timestamp, now);
    });

    test('should convert to/from Map', () {
      final now = DateTime.now();
      final location = LocationModel(
        latitude: 1.0,
        longitude: 2.0,
        accuracy: 3.0,
        timestamp: now,
      );
      final map = location.toMap();
      final fromMap = LocationModel.fromMap(map);
      expect(fromMap.latitude, location.latitude);
      expect(fromMap.longitude, location.longitude);
      expect(fromMap.accuracy, location.accuracy);
      expect(fromMap.timestamp, location.timestamp);
    });
  });
}