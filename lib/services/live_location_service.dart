import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'emergency_service.dart';

class LiveLocationService {
  Timer? _timer;

  /// Start sending live GPS updates every 10 seconds
  void startLiveTracking() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      await EmergencyService().updateLocation(pos.latitude, pos.longitude);
    });
  }

  /// Stop live tracking
  void stopLiveTracking() {
    _timer?.cancel();
  }
}
