import 'package:permission_handler/permission_handler.dart';

class SettingsState {
  final bool trackingEnabled;
  final int updateInterval;
  final bool darkMode;
  final PermissionStatus locationPermission;

  SettingsState({
    required this.trackingEnabled,
    required this.updateInterval,
    required this.darkMode,
    required this.locationPermission,
  });

  SettingsState copyWith({
    bool? trackingEnabled,
    int? updateInterval,
    bool? darkMode,
    PermissionStatus? locationPermission,
  }) {
    return SettingsState(
      trackingEnabled: trackingEnabled ?? this.trackingEnabled,
      updateInterval: updateInterval ?? this.updateInterval,
      darkMode: darkMode ?? this.darkMode,
      locationPermission: locationPermission ?? this.locationPermission,
    );
  }
}
