import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  final supabase = Supabase.instance.client;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isProcessing = true;
  String _statusMessage = "INITIATING PROTOCOL...";

  @override
  void initState() {
    super.initState();
    _startEmergencyProtocol();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    Vibration.cancel();
    super.dispose();
  }

  Future<void> _startEmergencyProtocol() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
      }
      await _audioPlayer.play(AssetSource('alarm.mp3'));

      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final user = supabase.auth.currentUser;
      await supabase.from('alerts').insert({
        'user_id': user?.id,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'status': 'ACTIVE_DISTRESS',
      });

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = "POLICE ALERTED - GPS ACTIVE";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = "SYSTEM ERROR";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.red.withValues(alpha: 0.5), Colors.black],
            radius: 0.8,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_rounded, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            Text(_statusMessage,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            if (_isProcessing)
              const CircularProgressIndicator(color: Colors.red)
            else
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("STOP & DISMISS"),
              )
          ],
        ),
      ),
    );
  }
}
