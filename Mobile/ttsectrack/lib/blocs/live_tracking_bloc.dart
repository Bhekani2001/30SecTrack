import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/live_location_model.dart';
import '../services/live_tracking_service.dart';
import 'live_tracking_event.dart';
import 'live_tracking_state.dart';

class LiveTrackingBloc extends Bloc<LiveTrackingEvent, LiveTrackingState> {
  final LiveTrackingService service;
  bool _isTracking = false;

  LiveTrackingBloc(this.service) : super(TrackingInitial()) {
    on<StartTrackingEvent>((event, emit) async {
      _isTracking = true;
      emit(TrackingStarted());
    });
    on<StopTrackingEvent>((event, emit) async {
      _isTracking = false;
      emit(TrackingStopped());
    });
    on<NewLocationEvent>((event, emit) async {
      if (_isTracking) {
        await service.saveLocation(event.location);
        final locations = await service.getLocations();
        emit(TrackingUpdated(locations));
      }
    });
    on<ClearTrackingEvent>((event, emit) async {
      await service.clearLocations();
      emit(TrackingInitial());
    });
  }
}
