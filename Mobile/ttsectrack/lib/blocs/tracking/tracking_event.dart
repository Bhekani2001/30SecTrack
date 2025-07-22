import 'package:equatable/equatable.dart';
import '../../models/location_model.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

class StartTracking extends TrackingEvent {}

class StopTracking extends TrackingEvent {}

class LocationUpdated extends TrackingEvent {
  final LocationModel location;
  const LocationUpdated(this.location);

  @override
  List<Object?> get props => [location];
}

class TrackingErrorOccurred extends TrackingEvent {
  final String message;
  const TrackingErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}
