import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

import '../models/location_model.dart';
import '../repositories/location_repository.dart';

enum ConnectionStatus { unknown, connected, disconnected }

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool _isTracking = false;
  Position? _position;
  String? _lastUpdated;
  ConnectionStatus _status = ConnectionStatus.unknown;
  String? _errorMessage;
  StreamSubscription<Position>? _positionSubscription;

  final LocationRepository _locationRepository = LocationRepository();

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startTracking() async {
    setState(() {
      _isTracking = true;
      _errorMessage = null;
    });

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

      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((pos) {
            setState(() {
              _position = pos;
              _lastUpdated = DateFormat(
                'yyyy-MM-dd – kk:mm:ss',
              ).format(DateTime.now());
              _status = ConnectionStatus.connected;
            });
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
    setState(() {
      _isTracking = false;
      _status = ConnectionStatus.unknown;
    });

    // Save the last position to SQLite if available
    if (_position != null) {
      try {
        await _locationRepository.saveLocation(
          LocationModel(
            latitude: _position!.latitude,
            longitude: _position!.longitude,
            accuracy: _position!.accuracy,
            timestamp: _position!.timestamp,
          ),
        );
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
        // Optionally handle save error here
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [Expanded(child: _buildStatusCard())]),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: _buildLocationCard())]),
            const Spacer(),
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
    return Column(
      children: [
        ElevatedButton.icon(
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
        ),
      ],
    );
  }
}
