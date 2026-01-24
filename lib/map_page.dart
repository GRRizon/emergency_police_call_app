import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MapPage({
    super.key,
    this.latitude = 23.8103, // Default: Dhaka
    this.longitude = 90.4125,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Location")),
      body: Center(
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 80),
                const SizedBox(height: 16),
                const Text(
                  "User Live Location",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text("Latitude: $latitude"),
                Text("Longitude: $longitude"),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text("Close"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
