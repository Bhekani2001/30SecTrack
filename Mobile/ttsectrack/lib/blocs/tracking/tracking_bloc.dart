import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/location_model.dart';
import 'tracking_event.dart';
import 'tracking_state.dart';

abstract class ILocationService {
  Stream<Position> getPositionStream({LocationSettings? settings});
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
}

class GeolocatorService implements ILocationService {
  @override
  Stream<Position> getPositionStream({LocationSettings? settings}) =>
      Geolocator.getPositionStream(
        locationSettings: settings ?? const LocationSettings(),
      );

  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();
}

abstract class ILocationRepository {
  Future<void> saveLocation(LocationModel location);
  Future<List<LocationModel>> getLocationHistory();
  Future<void> clearHistory();
}

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final ILocationService locationService;
  final ILocationRepository? locationRepository;
  StreamSubscription<Position>? _positionSubscription;

  TrackingBloc({required this.locationService, this.locationRepository})
    : super(TrackingInitial()) {
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<LocationUpdated>(_onLocationUpdated);
    on<TrackingErrorOccurred>(_onTrackingErrorOccurred);
    on<LoadTrackingHistory>(_onLoadTrackingHistory);
    on<ClearTrackingHistory>(_onClearTrackingHistory);
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<TrackingState> emit,
  ) async {
    emit(TrackingInProgress());

    try {
      LocationPermission permission = await locationService.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await locationService.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(const TrackingFailure('Location permission denied'));
        return;
      }

      _positionSubscription?.cancel();
      _positionSubscription = locationService
          .getPositionStream(
            settings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          )
          .listen(
            (pos) {
              add(
                LocationUpdated(
                  LocationModel(
                    latitude: pos.latitude,
                    longitude: pos.longitude,
                    accuracy: pos.accuracy,
                    timestamp: pos.timestamp ?? DateTime.now(),
                  ),
                ),
              );
            },
            onError: (error) {
              add(TrackingErrorOccurred(error.toString()));
            },
          );
    } catch (e) {
      emit(TrackingFailure(e.toString()));
    }
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<TrackingState> emit,
  ) async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    emit(TrackingStopped());
  }

  Future<void> _onLocationUpdated(
    LocationUpdated event,
    Emitter<TrackingState> emit,
  ) async {
    emit(TrackingSuccess(event.location));
    if (locationRepository != null) {
      await locationRepository!.saveLocation(event.location);
    }
  }

  void _onTrackingErrorOccurred(
    TrackingErrorOccurred event,
    Emitter<TrackingState> emit,
  ) {
    emit(TrackingFailure(event.message));
  }

  Future<void> _onLoadTrackingHistory(
    LoadTrackingHistory event,
    Emitter<TrackingState> emit,
  ) async {
    if (locationRepository == null) {
      emit(const TrackingFailure('No location repository provided'));
      return;
    }
    try {
      final history = await locationRepository!.getLocationHistory();
      emit(TrackingHistoryLoaded(history));
    } catch (e) {
      emit(TrackingFailure('Failed to load history: $e'));
    }
  }

  Future<void> _onClearTrackingHistory(
    ClearTrackingHistory event,
    Emitter<TrackingState> emit,
  ) async {
    if (locationRepository == null) {
      emit(const TrackingFailure('No location repository provided'));
      return;
    }
    try {
      await locationRepository!.clearHistory();
      emit(const TrackingHistoryLoaded([]));
    } catch (e) {
      emit(TrackingFailure('Failed to clear history: $e'));
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}


class LoadTrackingHistory extends TrackingEvent {}

class ClearTrackingHistory extends TrackingEvent {}
