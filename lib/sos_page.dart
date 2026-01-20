import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  bool _isSending = true;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _sendEmergencyAlert();
  }

  Future<void> _sendEmergencyAlert() async {
    try {
      final user = supabase.auth.currentUser;

      // Sending data to a table named 'alerts' (Make sure this exists in Supabase!)
      await supabase.from('alerts').insert({
        'user_id': user?.id,
        'status': 'pending',
        'message': 'Emergency SOS Triggered',
        'latitude': 23.8103, // Placeholder: Use geolocator package for real GPS
        'longitude': 90.4125,
      });

      if (mounted) {
        setState(() => _isSending = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to notify police: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emergency_share, size: 100, color: Colors.white),
            const SizedBox(height: 30),
            Text(
              _isSending ? "SENDING ALERT..." : "POLICE NOTIFIED",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Your location has been sent to the nearest control room. Stay where you are.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const SizedBox(height: 50),
            if (_isSending)
              const CircularProgressIndicator(color: Colors.white)
            else
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text("CANCEL ALERT"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red[900],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
