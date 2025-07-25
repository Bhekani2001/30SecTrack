import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/location_model.dart';
import '../repositories/location_repository.dart';

class MyMovesScreen extends StatefulWidget {
  const MyMovesScreen({super.key});

  @override
  State<MyMovesScreen> createState() => _MyMovesScreenState();
}

class _MyMovesScreenState extends State<MyMovesScreen> {
  final LocationRepository _repository = LocationRepository();
  late Future<List<LocationModel>> _historyFuture;
  int _movesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHistoryAndCount();
  }

  void _loadHistoryAndCount() {
    setState(() {
      _historyFuture = _repository.getLocationHistory();
    });
    _loadCount();
  }

  Future<void> _loadCount() async {
    final count = await _repository.getLocationHistoryCount();
    if (mounted) {
      setState(() {
        _movesCount = count;
      });
    }
  }

  Future<void> _clearHistory() async {
    await _repository.clearHistory();
    _loadHistoryAndCount();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'All moves history cleared!',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.green.shade100,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmClear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Moves History'),
        content: const Text('Are you sure you want to clear all saved moves?'),
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
  }

  void _copyCoordinates(double lat, double lng) {
    final coords = '$lat, $lng';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$_movesCount Of My Moves"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadHistoryAndCount,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear All Moves',
            onPressed: _confirmClear,
          ),
        ],
      ),
      body: FutureBuilder<List<LocationModel>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No movement history found"));
          }

          final locations = snapshot.data!;

          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final current = locations[index];
              final next = index < locations.length - 1 ? locations[index + 1] : null;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: Text(
                    "At ${TimeOfDay.fromDateTime(current.timestamp).format(context)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Location: (${current.latitude}, ${current.longitude})"),
                      if (next != null)
                        Text(
                          "→ Moved to (${next.latitude}, ${next.longitude})",
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, color: Colors.grey),
                    tooltip: 'Copy coordinates',
                    onPressed: () => _copyCoordinates(current.latitude, current.longitude),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
