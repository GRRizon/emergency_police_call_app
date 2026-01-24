import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logger/app_logger.dart';
import '../../core/service_locator.dart';
import '../../domain/entities/emergency_request.dart';
import '../../domain/repositories/emergency_request_repository.dart';

final emergencyRequestRepositoryProvider =
    Provider<EmergencyRequestRepository>((ref) {
  return getIt<EmergencyRequestRepository>();
});

final emergencyRequestsProvider =
    FutureProvider.family<List<EmergencyRequest>, String>((ref, userId) async {
  final repository = ref.watch(emergencyRequestRepositoryProvider);
  try {
    AppLogger.info('Fetching emergency requests for user: $userId');
    final requests = await repository.getRequestsByUserId(userId);
    AppLogger.info('Fetched ${requests.length} emergency requests');
    return requests;
  } catch (e) {
    AppLogger.error('Fetch emergency requests error: $e');
    rethrow;
  }
});

final allActiveRequestsProvider =
    FutureProvider<List<EmergencyRequest>>((ref) async {
  final repository = ref.watch(emergencyRequestRepositoryProvider);
  try {
    AppLogger.info('Fetching all active emergency requests');
    final requests = await repository.getAllActiveRequests();
    AppLogger.info('Fetched ${requests.length} active requests');
    return requests;
  } catch (e) {
    AppLogger.error('Fetch active requests error: $e');
    rethrow;
  }
});

final emergencyRequestNotifierProvider = StateNotifierProvider<
    EmergencyRequestNotifier, AsyncValue<List<EmergencyRequest>>>((ref) {
  return EmergencyRequestNotifier(
      ref.watch(emergencyRequestRepositoryProvider));
});

class EmergencyRequestNotifier
    extends StateNotifier<AsyncValue<List<EmergencyRequest>>> {
  final EmergencyRequestRepository repository;

  EmergencyRequestNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> createRequest({
    required String userId,
    required double latitude,
    required double longitude,
    required String description,
  }) async {
    try {
      AppLogger.info('Creating emergency request');
      final newRequest = await repository.createRequest(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        description: description,
      );

      state.whenData((requests) {
        state = AsyncValue.data([newRequest, ...requests]);
      });

      AppLogger.info('Emergency request created');
    } catch (e) {
      AppLogger.error('Create request error: $e');
      rethrow;
    }
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required EmergencyRequestStatus status,
  }) async {
    try {
      AppLogger.info('Updating request $requestId status to $status');
      await repository.updateRequestStatus(
          requestId: requestId, status: status);

      state.whenData((requests) {
        final index = requests.indexWhere((r) => r.requestId == requestId);
        if (index != -1) {
          requests[index] = requests[index].copyWith(status: status);
          state = AsyncValue.data([...requests]);
        }
      });

      AppLogger.info('Request status updated');
    } catch (e) {
      AppLogger.error('Update status error: $e');
      rethrow;
    }
  }

  Future<void> assignOfficer({
    required String requestId,
    required String policeId,
  }) async {
    try {
      AppLogger.info('Assigning officer $policeId to request $requestId');
      await repository.assignOfficer(requestId: requestId, policeId: policeId);

      state.whenData((requests) {
        final index = requests.indexWhere((r) => r.requestId == requestId);
        if (index != -1) {
          requests[index] =
              requests[index].copyWith(assignedOfficerId: policeId);
          state = AsyncValue.data([...requests]);
        }
      });

      AppLogger.info('Officer assigned');
    } catch (e) {
      AppLogger.error('Assign officer error: $e');
      rethrow;
    }
  }
}
