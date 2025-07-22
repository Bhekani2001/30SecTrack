import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../repositories/location_repository.dart';
import '../models/location_model.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final LocationRepository _locationRepository;
  late Future<List<LocationModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _locationRepository = LocationRepository();
    _historyFuture = _locationRepository.getLocationHistory();
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
        title: const Text('Location History'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshHistory,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear All',
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
      body: FutureBuilder<List<LocationModel>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading history: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final locations = snapshot.data ?? [];
          if (locations.isEmpty) {
            return const Center(
              child: Text(
                'No location history found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refreshHistory,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: locations.length,
              separatorBuilder: (_, __) => const Divider(),
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
    );
  }
}
