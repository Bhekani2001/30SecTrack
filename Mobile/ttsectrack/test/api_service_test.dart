import 'package:flutter_test/flutter_test.dart';
import 'package:ttsectrack/services/api_service.dart';
import 'package:ttsectrack/models/location_model.dart';

void main() {
  group('ApiService', () {
    final api = ApiService(baseUrl: 'http://127.0.0.1:8000/tracking');

    test('should send location', () async {
      final location = LocationModel(
        latitude: 1.0,
        longitude: 2.0,
        accuracy: 3.0,
        timestamp: DateTime.now(),
      );
      final result = await api.sendLocation(unitId: 'test', location: location);
      expect(result, isA<bool>());
    });
  });
}