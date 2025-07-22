import 'package:equatable/equatable.dart';
import '../../models/location_model.dart';

abstract class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {}

class TrackingInProgress extends TrackingState {}

class TrackingStopped extends TrackingState {}

class TrackingSuccess extends TrackingState {
  final LocationModel location;
  const TrackingSuccess(this.location);

  @override
  List<Object?> get props => [location];
}

class TrackingHistoryLoaded extends TrackingState {
  final List<LocationModel> locations;
  const TrackingHistoryLoaded(this.locations);

  @override
  List<Object?> get props => [locations];
}

class TrackingFailure extends TrackingState {
  final String error;
  const TrackingFailure(this.error);

  @override
  List<Object?> get props => [error];
}
