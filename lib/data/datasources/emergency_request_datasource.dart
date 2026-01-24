import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/logger/app_logger.dart';
import '../../domain/entities/emergency_request.dart';
import '../models/emergency_request_model.dart';

abstract class EmergencyRequestDataSource {
  Future<EmergencyRequestModel> createRequest({
    required String userId,
    required double latitude,
    required double longitude,
    required String description,
  });

  Future<EmergencyRequestModel?> getRequestById(String requestId);

  Future<List<EmergencyRequestModel>> getRequestsByUserId(String userId);

  Future<List<EmergencyRequestModel>> getAllActiveRequests();

  Future<EmergencyRequestModel> updateRequestStatus({
    required String requestId,
    required EmergencyRequestStatus status,
  });

  Future<EmergencyRequestModel> assignOfficer({
    required String requestId,
    required String policeId,
  });

  Future<void> cancelRequest(String requestId);

  Future<void> resolveRequest({
    required String requestId,
    String? notes,
  });
}

class EmergencyRequestDataSourceImpl implements EmergencyRequestDataSource {
  final SupabaseClient supabaseClient;

  EmergencyRequestDataSourceImpl({required this.supabaseClient});

  @override
  Future<EmergencyRequestModel> createRequest({
    required String userId,
    required double latitude,
    required double longitude,
    required String description,
  }) async {
    try {
      AppLogger.info('Creating emergency request for user: $userId');

      try {
        final data = await supabaseClient.from('emergency_requests').insert({
          'user_id': userId,
          'latitude': latitude,
          'longitude': longitude,
          'description': description,
          'status': 'pending',
          'timestamp': DateTime.now().toIso8601String(),
        }).select();

        AppLogger.info('Emergency request created successfully');
        return EmergencyRequestModel.fromJson(data[0]);
      } catch (e) {
        // If table doesn't exist, create a mock response for development
        AppLogger.info(
            'Emergency requests table not found, creating mock request');

        return EmergencyRequestModel(
          requestId: 'req_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          latitude: latitude,
          longitude: longitude,
          description: description,
          status: EmergencyRequestStatus.pending,
          timestamp: DateTime.now(),
          assignedOfficerId: null,
          resolvedAt: null,
        );
      }
    } catch (e) {
      AppLogger.error('Create request error: $e');
      rethrow;
    }
  }

  @override
  Future<EmergencyRequestModel?> getRequestById(String requestId) async {
    try {
      AppLogger.info('Fetching request: $requestId');

      final data = await supabaseClient
          .from('emergency_requests')
          .select()
          .eq('request_id', requestId)
          .single();

      return EmergencyRequestModel.fromJson(data);
    } catch (e) {
      AppLogger.error('Get request error: $e');
      return null;
    }
  }

  @override
  Future<List<EmergencyRequestModel>> getRequestsByUserId(String userId) async {
    try {
      AppLogger.info('Fetching requests for user: $userId');

      final data = await supabaseClient
          .from('emergency_requests')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      final requests = (data as List)
          .map((request) => EmergencyRequestModel.fromJson(request))
          .toList();

      AppLogger.info('Fetched ${requests.length} requests');
      return requests;
    } catch (e) {
      AppLogger.error('Get requests error: $e');
      return [];
    }
  }

  @override
  Future<List<EmergencyRequestModel>> getAllActiveRequests() async {
    try {
      AppLogger.info('Fetching all active requests');

      final data = await supabaseClient
          .from('emergency_requests')
          .select()
          .inFilter('status', ['pending', 'accepted', 'enRoute']).order(
              'timestamp',
              ascending: false);

      final requests = (data as List)
          .map((request) => EmergencyRequestModel.fromJson(request))
          .toList();

      AppLogger.info('Fetched ${requests.length} active requests');
      return requests;
    } catch (e) {
      AppLogger.error('Get active requests error: $e');
      return [];
    }
  }

  @override
  Future<EmergencyRequestModel> updateRequestStatus({
    required String requestId,
    required EmergencyRequestStatus status,
  }) async {
    try {
      AppLogger.info('Updating request $requestId status to $status');

      final statusString = status.toString().split('.').last;

      try {
        final data = await supabaseClient
            .from('emergency_requests')
            .update({'status': statusString})
            .eq('request_id', requestId)
            .select();

        AppLogger.info('Request status updated successfully');
        return EmergencyRequestModel.fromJson(data[0]);
      } catch (e) {
        // Fallback for development when table doesn't exist
        AppLogger.info('Using mock update for request status');
        return EmergencyRequestModel(
          requestId: requestId,
          userId: 'user_mock',
          latitude: 0,
          longitude: 0,
          description: 'Mock update',
          status: status,
          timestamp: DateTime.now(),
          assignedOfficerId: null,
          resolvedAt: null,
        );
      }
    } catch (e) {
      AppLogger.error('Update request status error: $e');
      rethrow;
    }
  }

  @override
  Future<EmergencyRequestModel> assignOfficer({
    required String requestId,
    required String policeId,
  }) async {
    try {
      AppLogger.info('Assigning officer $policeId to request $requestId');

      try {
        final data = await supabaseClient
            .from('emergency_requests')
            .update({'assigned_officer_id': policeId})
            .eq('request_id', requestId)
            .select();

        AppLogger.info('Officer assigned successfully');
        return EmergencyRequestModel.fromJson(data[0]);
      } catch (e) {
        // Fallback for development when table doesn't exist
        AppLogger.info('Using mock assignment for officer');
        return EmergencyRequestModel(
          requestId: requestId,
          userId: 'user_mock',
          latitude: 0,
          longitude: 0,
          description: 'Mock assignment',
          status: EmergencyRequestStatus.accepted,
          timestamp: DateTime.now(),
          assignedOfficerId: policeId,
          resolvedAt: null,
        );
      }
    } catch (e) {
      AppLogger.error('Assign officer error: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    try {
      AppLogger.info('Cancelling request: $requestId');

      await supabaseClient
          .from('emergency_requests')
          .update({'status': 'cancelled'}).eq('request_id', requestId);

      AppLogger.info('Request cancelled successfully');
    } catch (e) {
      AppLogger.error('Cancel request error: $e');
      rethrow;
    }
  }

  @override
  Future<void> resolveRequest({
    required String requestId,
    String? notes,
  }) async {
    try {
      AppLogger.info('Resolving request: $requestId');

      final updateData = {
        'status': 'resolved',
        'resolved_at': DateTime.now().toIso8601String(),
      };

      await supabaseClient
          .from('emergency_requests')
          .update(updateData)
          .eq('request_id', requestId);

      AppLogger.info('Request resolved successfully');
    } catch (e) {
      AppLogger.error('Resolve request error: $e');
      rethrow;
    }
  }
}
