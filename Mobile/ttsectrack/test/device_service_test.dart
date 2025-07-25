import 'package:flutter_test/flutter_test.dart';
import 'package:ttsectrack/services/device_service.dart';

void main() {
  group('DeviceService', () {
    final service = DeviceService();

    test('should get device id', () async {
      final id = await service.getDeviceId();
      expect(id, isNotNull);
      expect(id, isNotEmpty);
    });
  });
}