import '../../domain/entities/emergency_request.dart';

abstract class EmergencyRequestRepository {
  Future<EmergencyRequest> createRequest({
    required String userId,
    required double latitude,
    required double longitude,
    required String description,
  });

  Future<EmergencyRequest?> getRequestById(String requestId);

  Future<List<EmergencyRequest>> getRequestsByUserId(String userId);

  Future<List<EmergencyRequest>> getAllActiveRequests();

  Future<EmergencyRequest> updateRequestStatus({
    required String requestId,
    required EmergencyRequestStatus status,
  });

  Future<EmergencyRequest> assignOfficer({
    required String requestId,
    required String policeId,
  });

  Future<void> cancelRequest(String requestId);

  Future<void> resolveRequest({
    required String requestId,
    String? notes,
  });

  Stream<EmergencyRequest> watchRequest(String requestId);

  Stream<List<EmergencyRequest>> watchAllActiveRequests();
}
