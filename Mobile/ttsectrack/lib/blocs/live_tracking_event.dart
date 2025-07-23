import '../models/live_location_model.dart';

abstract class LiveTrackingEvent {}
class StartTrackingEvent extends LiveTrackingEvent {}
class StopTrackingEvent extends LiveTrackingEvent {}
class NewLocationEvent extends LiveTrackingEvent {
  final LiveLocation location;
  NewLocationEvent(this.location);
}
class ClearTrackingEvent extends LiveTrackingEvent {}
