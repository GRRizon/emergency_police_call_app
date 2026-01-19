import 'package:flutter/material.dart';
import 'services/emergency_service.dart';
import 'services/location_service.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  bool _sending = false;

  Future<void> _sendSOS() async {
    if (!mounted) return;

    setState(() => _sending = true);

    try {
      final location = await LocationService().getCurrentLocation();
      await EmergencyService()
          .sendEmergency(location.latitude, location.longitude);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() => _sending = false);
      return;
    }

    if (!mounted) return;
    setState(() => _sending = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚨 SOS Sent Successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          ClipPath(
            clipper: SemiCircleClipper(),
            child: GestureDetector(
              onLongPress: _sendSOS,
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.red,
                alignment: Alignment.center,
                child: _sending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'HOLD FOR SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SemiCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
