import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  // Emergency contacts
  final List<String> _emergencyContacts = ['+880123456789', '+880987654321'];

  @override
  void initState() {
    super.initState();
    _sendEmergencySMS();
  }

  // Function to open SMS app with prefilled message
  Future<void> _sendEmergencySMS() async {
    String message = "⚠️ Emergency! I need help. My location is XYZ.";

    try {
      // Combine multiple numbers with commas
      String numbers = _emergencyContacts.join(',');

      final Uri smsUri =
          Uri.parse("sms:$numbers?body=${Uri.encodeComponent(message)}");

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw 'Could not launch SMS app';
      }

      // Safe use of BuildContext after async
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Opened SMS app for emergency contacts!")),
      );
    } catch (error) {
      debugPrint("Failed to open SMS: $error");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to open SMS app.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Alert'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'SOS Alert Activated!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
