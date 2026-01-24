import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/logger/app_logger.dart';
import '../../core/service_locator.dart';
import '../../data/datasources/location_datasource.dart';

final locationDataSourceProvider = Provider<LocationDataSource>((ref) {
  return getIt<LocationDataSource>();
});

final currentLocationProvider = FutureProvider<Position?>((ref) async {
  final locationDataSource = ref.watch(locationDataSourceProvider);
  try {
    AppLogger.info('Fetching current location');
    final position = await locationDataSource.getCurrentLocation();
    AppLogger.info(
        'Current location: ${position.latitude}, ${position.longitude}');
    return position;
  } catch (e) {
    AppLogger.error('Get current location error: $e');
    return null;
  }
});

final locationUpdatesProvider = StreamProvider<Position>((ref) {
  final locationDataSource = ref.watch(locationDataSourceProvider);
  return locationDataSource.getLocationUpdates();
});

final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, Position?>((ref) {
  return LocationNotifier(ref.watch(locationDataSourceProvider));
});

class LocationNotifier extends StateNotifier<Position?> {
  final LocationDataSource locationDataSource;

  LocationNotifier(this.locationDataSource) : super(null);

  Future<void> getCurrentLocation() async {
    try {
      AppLogger.info('Getting current location');
      final position = await locationDataSource.getCurrentLocation();
      state = position;
      AppLogger.info(
          'Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      AppLogger.error('Get location error: $e');
      rethrow;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await locationDataSource.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkLocationPermission() async {
    return await locationDataSource.checkLocationPermission();
  }

  Future<LocationPermission> requestLocationPermission() async {
    return await locationDataSource.requestLocationPermission();
  }
}
