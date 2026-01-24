import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/logger/app_logger.dart';
import '../models/dispatch_record_model.dart';

abstract class DispatchDataSource {
  Future<DispatchRecordModel> createDispatch({
    required String requestId,
    required String policeId,
    required String dispatchLocation,
  });

  Future<DispatchRecordModel?> getDispatchById(String dispatchId);

  Future<List<DispatchRecordModel>> getDispatchByRequestId(String requestId);

  Future<List<DispatchRecordModel>> getDispatchByOfficerId(String policeId);

  Future<DispatchRecordModel> updateDispatchStatus({
    required String dispatchId,
    required DateTime? arrivalTime,
  });

  Future<DispatchRecordModel> updateDispatchNotes({
    required String dispatchId,
    required String notes,
  });

  Future<void> acceptDispatch(String dispatchId);

  Future<void> rejectDispatch(String dispatchId);
}

class DispatchDataSourceImpl implements DispatchDataSource {
  final SupabaseClient supabaseClient;

  DispatchDataSourceImpl({required this.supabaseClient});

  @override
  Future<DispatchRecordModel> createDispatch({
    required String requestId,
    required String policeId,
    required String dispatchLocation,
  }) async {
    try {
      AppLogger.info('Creating dispatch for request: $requestId');

      final data = await supabaseClient.from('dispatch_records').insert({
        'request_id': requestId,
        'police_id': policeId,
        'dispatch_location': dispatchLocation,
        'dispatch_time': DateTime.now().toIso8601String(),
        'accepted_by_request': false,
      }).select();

      AppLogger.info('Dispatch created successfully');
      return DispatchRecordModel.fromJson(data[0]);
    } catch (e) {
      AppLogger.error('Create dispatch error: $e');
      rethrow;
    }
  }

  @override
  Future<DispatchRecordModel?> getDispatchById(String dispatchId) async {
    try {
      AppLogger.info('Fetching dispatch: $dispatchId');

      final data = await supabaseClient
          .from('dispatch_records')
          .select()
          .eq('dispatch_id', dispatchId)
          .single();

      return DispatchRecordModel.fromJson(data);
    } catch (e) {
      AppLogger.error('Get dispatch error: $e');
      return null;
    }
  }

  @override
  Future<List<DispatchRecordModel>> getDispatchByRequestId(
    String requestId,
  ) async {
    try {
      AppLogger.info('Fetching dispatch for request: $requestId');

      final data = await supabaseClient
          .from('dispatch_records')
          .select()
          .eq('request_id', requestId);

      final records = (data as List)
          .map((record) => DispatchRecordModel.fromJson(record))
          .toList();

      AppLogger.info('Fetched ${records.length} dispatch records');
      return records;
    } catch (e) {
      AppLogger.error('Get dispatch by request error: $e');
      return [];
    }
  }

  @override
  Future<List<DispatchRecordModel>> getDispatchByOfficerId(
    String policeId,
  ) async {
    try {
      AppLogger.info('Fetching dispatch for officer: $policeId');

      final data = await supabaseClient
          .from('dispatch_records')
          .select()
          .eq('police_id', policeId)
          .order('dispatch_time', ascending: false);

      final records = (data as List)
          .map((record) => DispatchRecordModel.fromJson(record))
          .toList();

      AppLogger.info('Fetched ${records.length} dispatch records');
      return records;
    } catch (e) {
      AppLogger.error('Get dispatch by officer error: $e');
      return [];
    }
  }

  @override
  Future<DispatchRecordModel> updateDispatchStatus({
    required String dispatchId,
    required DateTime? arrivalTime,
  }) async {
    try {
      AppLogger.info('Updating dispatch $dispatchId status');

      final updateData = <String, dynamic>{};
      if (arrivalTime != null) {
        updateData['arrival_time'] = arrivalTime.toIso8601String();
      }

      final data = await supabaseClient
          .from('dispatch_records')
          .update(updateData)
          .eq('dispatch_id', dispatchId)
          .select();

      AppLogger.info('Dispatch status updated');
      return DispatchRecordModel.fromJson(data[0]);
    } catch (e) {
      AppLogger.error('Update dispatch status error: $e');
      rethrow;
    }
  }

  @override
  Future<DispatchRecordModel> updateDispatchNotes({
    required String dispatchId,
    required String notes,
  }) async {
    try {
      AppLogger.info('Updating dispatch notes: $dispatchId');

      final data = await supabaseClient
          .from('dispatch_records')
          .update({'notes': notes})
          .eq('dispatch_id', dispatchId)
          .select();

      AppLogger.info('Dispatch notes updated');
      return DispatchRecordModel.fromJson(data[0]);
    } catch (e) {
      AppLogger.error('Update dispatch notes error: $e');
      rethrow;
    }
  }

  @override
  Future<void> acceptDispatch(String dispatchId) async {
    try {
      AppLogger.info('Accepting dispatch: $dispatchId');

      await supabaseClient
          .from('dispatch_records')
          .update({'accepted_by_request': true}).eq('dispatch_id', dispatchId);

      AppLogger.info('Dispatch accepted');
    } catch (e) {
      AppLogger.error('Accept dispatch error: $e');
      rethrow;
    }
  }

  @override
  Future<void> rejectDispatch(String dispatchId) async {
    try {
      AppLogger.info('Rejecting dispatch: $dispatchId');

      await supabaseClient
          .from('dispatch_records')
          .delete()
          .eq('dispatch_id', dispatchId);

      AppLogger.info('Dispatch rejected');
    } catch (e) {
      AppLogger.error('Reject dispatch error: $e');
      rethrow;
    }
  }
}
