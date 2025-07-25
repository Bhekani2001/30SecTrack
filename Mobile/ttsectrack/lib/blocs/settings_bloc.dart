import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;

  static const _trackingKey = 'tracking_enabled';
  static const _intervalKey = 'update_interval';
  static const _darkModeKey = 'dark_mode';

  SettingsBloc(this.prefs)
      : super(SettingsState(
          trackingEnabled: prefs.getBool(_trackingKey) ?? false,
          updateInterval: prefs.getInt(_intervalKey) ?? 10,
          darkMode: prefs.getBool(_darkModeKey) ?? false,
          locationPermission: PermissionStatus.denied,
        )) {
    on<ToggleTrackingEvent>(_onToggleTracking);
    on<UpdateIntervalEvent>(_onUpdateInterval);
    on<ToggleDarkModeEvent>(_onToggleDarkMode);
    on<RefreshPermissionStatusEvent>(_onRefreshPermissionStatus);
    on<ClearHistoryEvent>(_onClearHistory);

    add(RefreshPermissionStatusEvent());
  }

  Future<void> _onToggleTracking(
      ToggleTrackingEvent event, Emitter<SettingsState> emit) async {
    await prefs.setBool(_trackingKey, event.enabled);
    emit(state.copyWith(trackingEnabled: event.enabled));
  }

  Future<void> _onUpdateInterval(
      UpdateIntervalEvent event, Emitter<SettingsState> emit) async {
    await prefs.setInt(_intervalKey, event.seconds);
    emit(state.copyWith(updateInterval: event.seconds));
  }

  Future<void> _onToggleDarkMode(
      ToggleDarkModeEvent event, Emitter<SettingsState> emit) async {
    await prefs.setBool(_darkModeKey, event.enabled);
    emit(state.copyWith(darkMode: event.enabled));
  }

  Future<void> _onRefreshPermissionStatus(
      RefreshPermissionStatusEvent event, Emitter<SettingsState> emit) async {
    final status = await Permission.location.status;
    emit(state.copyWith(locationPermission: status));
  }

  Future<void> _onClearHistory(
      ClearHistoryEvent event, Emitter<SettingsState> emit) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
