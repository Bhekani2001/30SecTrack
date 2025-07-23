import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/settings_bloc.dart';
import '../blocs/settings_event.dart';
import '../blocs/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocProvider(
          create: (_) => SettingsBloc(snapshot.data!),
          child: Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: const SettingsView(),
          ),
        );
      },
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SettingsBloc>();

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Enable Background Tracking'),
              value: state.trackingEnabled,
              onChanged: (val) =>
                  bloc.add(ToggleTrackingEvent(val)),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Update Interval (seconds)'),
              trailing: DropdownButton<int>(
                value: state.updateInterval,
                items: [5, 10, 30, 60]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    bloc.add(UpdateIntervalEvent(val));
                  }
                },
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: state.darkMode,
              onChanged: (val) => bloc.add(ToggleDarkModeEvent(val)),
            ),
            const Divider(),
            ListTile(
              title: const Text('Location Permission'),
              subtitle: Text(state.locationPermission.toString().split('.').last),
              trailing: ElevatedButton(
                onPressed: () async {
                  final status = await Permission.location.request();
                  bloc.add(RefreshPermissionStatusEvent());
                  if (status.isDenied || status.isPermanentlyDenied) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location permission denied')),
                    );
                  }
                },
                child: const Text('Request Permission'),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Clear Location History'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Clear History'),
                      content: const Text('Are you sure you want to clear location history?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    bloc.add(ClearHistoryEvent());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location history cleared')),
                    );
                  }
                },
                child: const Text('Clear'),
              ),
            ),
          ],
        );
      },
    );
  }
}
