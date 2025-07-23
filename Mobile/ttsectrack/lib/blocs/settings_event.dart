abstract class SettingsEvent {}

class ToggleTrackingEvent extends SettingsEvent {
  final bool enabled;
  ToggleTrackingEvent(this.enabled);
}

class UpdateIntervalEvent extends SettingsEvent {
  final int seconds;
  UpdateIntervalEvent(this.seconds);
}

class ToggleDarkModeEvent extends SettingsEvent {
  final bool enabled;
  ToggleDarkModeEvent(this.enabled);
}

class RefreshPermissionStatusEvent extends SettingsEvent {}

class ClearHistoryEvent extends SettingsEvent {}
