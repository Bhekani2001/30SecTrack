import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../models/location_model.dart';
import '../repositories/location_repository.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';

enum ConnectionStatus { unknown, connected, disconnected }

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  bool _isTracking = false;
  bool _cloudSync = true;

  Position? _position;
  String? _lastUpdated;
  ConnectionStatus _status = ConnectionStatus.unknown;
  String? _errorMessage;
  StreamSubscription<Position>? _positionSubscription;

  final LocationRepository _locationRepository = LocationRepository();
  final ApiService _apiService =
      ApiService(baseUrl: 'http://127.0.0.1:8000/tracking'); // Replace with your API URL
  final DeviceService _deviceService = DeviceService();

  String? unitId;
  Timer? _apiTimer;

  late Future<List<LocationModel>> _historyFuture; // Future for history list
  List<LocationModel> _locations = [];

  @override
  void initState() {
    super.initState();
    // Initialize the future that fetches saved locations for the list
    _historyFuture = _locationRepository.getLocationHistory();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _apiTimer?.cancel();
    super.dispose();
  }

  Future<void> _startTracking() async {
    setState(() {
      _isTracking = true;
      _errorMessage = null;
    });

    unitId = await _deviceService.getDeviceId();

    // Setup API sync timer if cloud sync enabled
    _apiTimer?.cancel();
    if (_cloudSync) {
      _apiTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
        if (_position != null && unitId != null) {
          final location = LocationModel(
            latitude: _position!.latitude,
            longitude: _position!.longitude,
            accuracy: _position!.accuracy,
            timestamp: _position!.timestamp,
          );
          await _locationRepository.saveLocation(location);
          final success = await _apiService.sendLocation(
            unitId: unitId!,
            location: location,
          );
          if (!success) {
            setState(() {
              _status = ConnectionStatus.disconnected;
              _errorMessage = 'Failed to sync with server.';
            });
          } else {
            setState(() {
              _status = ConnectionStatus.connected;
            });
          }
        }
      });
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission denied';
          _status = ConnectionStatus.disconnected;
          _isTracking = false;
        });
        return;
      }

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((pos) {
        setState(() {
          _position = pos;
          _lastUpdated = DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.now());
          _status = ConnectionStatus.connected;
        });

        final location = LocationModel(
          latitude: pos.latitude,
          longitude: pos.longitude,
          accuracy: pos.accuracy,
          timestamp: pos.timestamp,
        );
        _locationRepository.saveLocation(location);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _status = ConnectionStatus.disconnected;
        _isTracking = false;
      });
    }
  }

  void _stopTracking() async {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _apiTimer?.cancel();

    setState(() {
      _isTracking = false;
      _status = ConnectionStatus.unknown;
    });

    if (_position != null && unitId != null) {
      try {
        final location = LocationModel(
          latitude: _position!.latitude,
          longitude: _position!.longitude,
          accuracy: _position!.accuracy,
          timestamp: _position!.timestamp,
        );
        await _locationRepository.saveLocation(location);
        if (_cloudSync) {
          await _apiService.sendLocation(unitId: unitId!, location: location);
        }
        // Refresh history list after saving new location
        _refreshHistory();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Location saved successfully!',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.green.shade100,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // handle error silently or show error if needed
      }
    }
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _historyFuture = _locationRepository.getLocationHistory();
    });
  }

  Future<void> _clearHistory() async {
    await _locationRepository.clearHistory();
    await _refreshHistory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'History cleared!',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.green.shade100,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd – kk:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              Text(
                _cloudSync ? 'Cloud' : 'Local',
                style: const TextStyle(color: Colors.white),
              ),
              Switch(
                value: _cloudSync,
                onChanged: (val) {
                  setState(() {
                    _cloudSync = val;
                  });
                  if (_isTracking) {
                    _apiTimer?.cancel();
                    if (_cloudSync) {
                      _startTracking();
                    }
                  }
                },
                activeColor: Colors.white,
              ),
              IconButton(
                tooltip: 'Refresh History',
                icon: const Icon(Icons.refresh),
                onPressed: _refreshHistory,
              ),
              IconButton(
                tooltip: 'Clear History',
                icon: const Icon(Icons.delete_forever),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear History'),
                      content: const Text(
                        'Are you sure you want to clear all saved locations?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _clearHistory();
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Row(
              children: [
                Expanded(child: _buildStatusCard()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildLocationCard()),
              ],
            ),
            const SizedBox(height: 16),
            // History list with FutureBuilder (keep this part)
            Expanded(
              child: FutureBuilder<List<LocationModel>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading history: [${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  final locations = snapshot.data ?? [];
                  if (locations.isEmpty) {
                    return Center(
                      child: Text(
                        'No saved locations.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshHistory,
                    child: ListView.separated(
                      itemCount: locations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final loc = locations[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.blueAccent,
                            ),
                            title: Text(
                              'Lat: ${loc.latitude.toStringAsFixed(6)}, Lng: ${loc.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Accuracy: ${loc.accuracy.toStringAsFixed(2)} m'),
                                Text('Time: ${_formatDate(loc.timestamp)}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy, color: Colors.grey),
                              tooltip: 'Copy coordinates',
                              onPressed: () {
                                final coords = '${loc.latitude}, ${loc.longitude}';
                                Clipboard.setData(ClipboardData(text: coords));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Coordinates copied!',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    backgroundColor: Colors.blue.shade100,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Control button start/stop
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    IconData icon;
    Color color;
    String text;

    switch (_status) {
      case ConnectionStatus.connected:
        icon = Icons.check_circle;
        color = Colors.green;
        text = 'Connected';
        break;
      case ConnectionStatus.disconnected:
        icon = Icons.error;
        color = Colors.red;
        text = 'Disconnected';
        break;
      default:
        icon = Icons.sync;
        color = Colors.grey;
        text = 'Unknown';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: const Text(
          'Connection Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(text),
      ),
    );
  }

   Widget _buildLocationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Latitude: ${_position?.latitude.toStringAsFixed(6) ?? '--'}'),
            Text('Longitude: ${_position?.longitude.toStringAsFixed(6) ?? '--'}'),
            Text('Accuracy: ${_position?.accuracy.toStringAsFixed(2) ?? '--'} m'),
            const SizedBox(height: 8),
            Text(
              'Last Updated: ${_lastUpdated ?? '--'}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return ElevatedButton.icon(
      icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
      label: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        backgroundColor: _isTracking ? Colors.red : Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 16),
      ),
      onPressed: _isTracking ? _stopTracking : _startTracking,
    );
  }
}
