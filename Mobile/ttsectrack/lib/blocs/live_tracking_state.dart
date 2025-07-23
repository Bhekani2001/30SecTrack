import '../models/live_location_model.dart';

abstract class LiveTrackingState {}
class TrackingInitial extends LiveTrackingState {}
class TrackingStarted extends LiveTrackingState {}
class TrackingStopped extends LiveTrackingState {}
class TrackingUpdated extends LiveTrackingState {
  final List<LiveLocation> locations;
  TrackingUpdated(this.locations);
}
class TrackingError extends LiveTrackingState {
  final String error;
  TrackingError(this.error);
}
