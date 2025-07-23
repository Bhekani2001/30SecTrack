import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../repositories/location_repository.dart'; // Replace with your actual data source

class MyMovesScreen extends StatefulWidget {
  const MyMovesScreen({super.key});

  @override
  State<MyMovesScreen> createState() => _MyMovesScreenState();
}

class _MyMovesScreenState extends State<MyMovesScreen> {
  final LocationRepository _repository = LocationRepository();
  late Future<List<LocationModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _repository.getLocationHistory(); // Real data source
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Moves")),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
