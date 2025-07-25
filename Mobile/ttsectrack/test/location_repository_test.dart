import 'package:flutter_test/flutter_test.dart';
import 'package:ttsectrack/models/location_model.dart';
import 'package:ttsectrack/repositories/location_repository.dart';

void main() {
  group('LocationRepository', () {
    final repo = LocationRepository();

    test('should save and retrieve location', () async {
      final location = LocationModel(
        latitude: 10.0,
        longitude: 20.0,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );

      await repo.saveLocation(location);
      final history = await repo.getLocationHistory();

      expect(history.isNotEmpty, true);
      expect(history.last.latitude, location.latitude);
      expect(history.last.longitude, location.longitude);
    });

    test('should clear location history', () async {
      await repo.clearHistory();
      final history = await repo.getLocationHistory();

      expect(history.isEmpty, true);
    });
  });
}