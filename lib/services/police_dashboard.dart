import 'package:flutter/material.dart'; // <--- THIS IS REQUIRED

class PoliceDashboard extends StatelessWidget {
  const PoliceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Police Control Room"),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: const Center(
          child: Text("Active Emergency Alerts will appear here.")),
    );
  }
}
