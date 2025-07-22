import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<Position> getCurrentPosition({LocationAccuracy accuracy = LocationAccuracy.high}) async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
  }

  Stream<Position> getPositionStream({LocationSettings? settings}) {
    return Geolocator.getPositionStream(
      locationSettings: settings ?? const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    );
  }
}
