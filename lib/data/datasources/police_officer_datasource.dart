import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/logger/app_logger.dart';
import '../models/police_officer_model.dart';

abstract class PoliceOfficerDataSource {
  Future<PoliceOfficerModel?> getOfficerById(String policeId);

  Future<List<PoliceOfficerModel>> getAvailableOfficers();

  Future<List<PoliceOfficerModel>> getAllOfficers();

  Future<PoliceOfficerModel> updateLocation({
    required String policeId,
    required double latitude,
    required double longitude,
  });

  Future<PoliceOfficerModel> updateAvailabilityStatus({
    required String policeId,
    required bool isAvailable,
  });

  Future<PoliceOfficerModel> updateOfficerInfo({
    required String policeId,
    String? name,
    String? phone,
    String? precinct,
    String? vehicleInfo,
  });

  Future<void> incrementAcceptedRequests(String policeId);

  Future<void> incrementCompletedRequests(String policeId);
}

class PoliceOfficerDataSourceImpl implements PoliceOfficerDataSource {
  final SupabaseClient supabaseClient;

  PoliceOfficerDataSourceImpl({required this.supabaseClient});

  @override
  Future<PoliceOfficerModel?> getOfficerById(String policeId) async {
    try {
      AppLogger.info('Fetching officer: $policeId');

      final data = await supabaseClient
          .from('police_officers')
          .select()
          .eq('police_id', policeId)
          .single();

      return PoliceOfficerModel.fromJson(data);
    } catch (e) {
      AppLogger.error('Get officer error: $e');
      return null;
    }
  }

  @override
  Future<List<PoliceOfficerModel>> getAvailableOfficers() async {
    try {
      AppLogger.info('Fetching available officers');

      final data = await supabaseClient
          .from('police_officers')
          .select()
          .eq('is_available', true);

      final officers = (data as List)
          .map((officer) => PoliceOfficerModel.fromJson(officer))
          .toList();

      AppLogger.info('Fetched ${officers.length} available officers');
      return officers;
    } catch (e) {
      AppLogger.error('Get available officers error: $e');
      return [];
    }
  }

  @override
  Future<List<PoliceOfficerModel>> getAllOfficers() async {
    try {
      AppLogger.info('Fetching all officers');

      final data = await supabaseClient
          .from('police_officers')
          .select()
          .order('is_available', ascending: false);

      final officers = (data as List)
          .map((officer) => PoliceOfficerModel.fromJson(officer))
          .toList();

      AppLogger.info('Fetched ${officers.length} officers');
      return officers;
    } catch (e) {
      AppLogger.error('Get all officers error: $e');
      return [];
    }
  }

  @override
  Future<PoliceOfficerModel> updateLocation({
    required String policeId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      AppLogger.info(
        'Updating location for officer $policeId: $latitude, $longitude',
      );

      final data = await supabaseClient
          .from('police_officers')
          .update({
            'current_latitude': latitude,
            'current_longitude': longitude,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('police_id', policeId)
          .select();

      AppLogger.info('Officer location updated');
      return PoliceOfficerModel.fromJson(data[0]);
    } catch (e) {
      AppLogger.error('Update location error: $e');
      rethrow;
    }
  }

  @override
  Future<PoliceOfficerModel> updateAvailabilityStatus({
    required String policeId,
    required bool isAvailable,
  }) async {
    try {
      AppLogger.info(
          'Updating availability for officer $policeId: $isAvailable');

      final data = await supabaseClient
          .from('police_officers')
          .update({
            'is_available': isAvailable,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('police_id', policeId)
          .select();

      AppLogger.info('Officer availability updated');
      return PoliceOfficerModel.fromJson(data[0]);
    } catch (e) {
      AppLogger.error('Update availability error: $e');
      rethrow;
    }
  }

  @override
  Future<PoliceOfficerModel> updateOfficerInfo({
    required String policeId,
    String? name,
    String? phone,
    String? precinct,
    String? vehicleInfo,
  }) async {
    try {
      AppLogger.info('Updating officer info for: $policeId');

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (precinct != null) updateData['precinct'] = precinct;
      if (vehicleInfo != null) updateData['vehicle_info'] = vehicleInfo;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final data = await supabaseClient
          .from('police_officers')
          .update(updateData)
          .eq('police_id', policeId)
          .select();

      AppLogger.info('Officer info updated');
      return PoliceOfficerModel.fromJson(data[0]);
    } catch (e) {
      AppLogger.error('Update officer info error: $e');
      rethrow;
    }
  }

  @override
  Future<void> incrementAcceptedRequests(String policeId) async {
    try {
      AppLogger.info('Incrementing accepted requests for: $policeId');

      final officer = await getOfficerById(policeId);
      if (officer == null) return;

      await supabaseClient
          .from('police_officers')
          .update({'accepted_requests': officer.acceptedRequests + 1}).eq(
              'police_id', policeId);

      AppLogger.info('Accepted requests incremented');
    } catch (e) {
      AppLogger.error('Increment accepted requests error: $e');
    }
  }

  @override
  Future<void> incrementCompletedRequests(String policeId) async {
    try {
      AppLogger.info('Incrementing completed requests for: $policeId');

      final officer = await getOfficerById(policeId);
      if (officer == null) return;

      await supabaseClient
          .from('police_officers')
          .update({'completed_requests': officer.completedRequests + 1}).eq(
              'police_id', policeId);

      AppLogger.info('Completed requests incremented');
    } catch (e) {
      AppLogger.error('Increment completed requests error: $e');
    }
  }
}
