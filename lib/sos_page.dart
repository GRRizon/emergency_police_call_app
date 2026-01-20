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
<<<<<<< HEAD
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
=======
      // FIX: Removed quotes to pass doubles instead of Strings
      // In a real app, replace these with actual GPS coordinates
      double mockLat = 12.9716;
      double mockLng = 77.5946;
>>>>>>> 12923ca (Your descriptive message here)

      await EmergencyService().sendEmergency(mockLat, mockLng);

<<<<<<< HEAD
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚨 SOS Sent Successfully')),
    );
=======
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚨 SOS Sent Successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to send SOS: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
>>>>>>> 12923ca (Your descriptive message here)
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
              onLongPress:
                  _sending ? null : _sendSOS, // Disable if already sending
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
