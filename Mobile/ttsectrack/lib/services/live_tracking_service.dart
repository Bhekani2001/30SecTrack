import '../models/live_location_model.dart';
import '../repositories/live_tracking_repository.dart';

class LiveTrackingService {
  final LiveTrackingRepository repository;
  LiveTrackingService(this.repository);

  Future<void> saveLocation(LiveLocation location) async {
    await repository.saveLocation(location);
  }

  Future<List<LiveLocation>> getLocations() async {
    return await repository.getLocations();
  }

  Future<void> clearLocations() async {
    await repository.clearLocations();
  }
}
