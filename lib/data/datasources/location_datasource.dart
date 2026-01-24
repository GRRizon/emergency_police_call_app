import 'package:geolocator/geolocator.dart';

import '../../core/exceptions/app_exceptions.dart';
import '../../core/logger/app_logger.dart';

abstract class LocationDataSource {
  Future<Position> getCurrentLocation();

  Future<bool> isLocationServiceEnabled();

  Future<LocationPermission> checkLocationPermission();

  Future<LocationPermission> requestLocationPermission();

  Stream<Position> getLocationUpdates({
    Duration updateInterval = const Duration(seconds: 5),
    int distanceFilter = 10,
  });
}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<Position> getCurrentLocation() async {
    try {
      AppLogger.info('Getting current location');

      final hasPermission = await _checkAndRequestPermission();
      if (!hasPermission) {
        throw PermissionException(message: 'Location permission denied');
      }

      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        throw LocationException(message: 'Location service is disabled');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

      AppLogger.info(
        'Current location: ${position.latitude}, ${position.longitude}',
      );

      return position;
    } on PermissionException {
      rethrow;
    } on LocationException {
      rethrow;
    } catch (e) {
      AppLogger.error('Get current location error: $e');
      throw LocationException(message: 'Failed to get current location');
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      AppLogger.error('Check location service error: $e');
      return false;
    }
  }

  @override
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  @override
  Stream<Position> getLocationUpdates({
    Duration updateInterval = const Duration(seconds: 5),
    int distanceFilter = 10,
  }) {
    AppLogger.info('Starting location updates');

    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        timeLimit: updateInterval,
      ),
    );
  }

  Future<bool> _checkAndRequestPermission() async {
    final permission = await checkLocationPermission();

    if (permission == LocationPermission.denied) {
      final newPermission = await requestLocationPermission();
      return newPermission == LocationPermission.whileInUse ||
          newPermission == LocationPermission.always;
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
