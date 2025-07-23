import 'package:sqflite/sqflite.dart';
import '../models/live_location_model.dart';

class LiveTrackingRepository {
  final Database db;
  LiveTrackingRepository(this.db);

  Future<void> saveLocation(LiveLocation location) async {
    await db.insert('live_locations', location.toMap());
  }

  Future<List<LiveLocation>> getLocations() async {
    final result = await db.query('live_locations');
    return result.map((e) => LiveLocation.fromMap(e)).toList();
  }

  Future<void> clearLocations() async {
    await db.delete('live_locations');
  }
}
