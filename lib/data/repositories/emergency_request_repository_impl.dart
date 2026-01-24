import '../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/emergency_request.dart';
import '../../domain/repositories/emergency_request_repository.dart';
import '../datasources/emergency_request_datasource.dart';

class EmergencyRequestRepositoryImpl implements EmergencyRequestRepository {
  final EmergencyRequestDataSource dataSource;

  EmergencyRequestRepositoryImpl({required this.dataSource});

  @override
  Future<EmergencyRequest> createRequest({
    required String userId,
    required double latitude,
    required double longitude,
    required String description,
  }) async {
    try {
      return await dataSource.createRequest(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        description: description,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<EmergencyRequest?> getRequestById(String requestId) async {
    try {
      return await dataSource.getRequestById(requestId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<List<EmergencyRequest>> getRequestsByUserId(String userId) async {
    try {
      return await dataSource.getRequestsByUserId(userId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<List<EmergencyRequest>> getAllActiveRequests() async {
    try {
      return await dataSource.getAllActiveRequests();
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<EmergencyRequest> updateRequestStatus({
    required String requestId,
    required EmergencyRequestStatus status,
  }) async {
    try {
      return await dataSource.updateRequestStatus(
        requestId: requestId,
        status: status,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<EmergencyRequest> assignOfficer({
    required String requestId,
    required String policeId,
  }) async {
    try {
      return await dataSource.assignOfficer(
        requestId: requestId,
        policeId: policeId,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    try {
      return await dataSource.cancelRequest(requestId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> resolveRequest({
    required String requestId,
    String? notes,
  }) async {
    try {
      return await dataSource.resolveRequest(
          requestId: requestId, notes: notes);
    } on AppException {
      rethrow;
    }
  }

  @override
  Stream<EmergencyRequest> watchRequest(String requestId) {
    // ignore: todo
    // TODO: Implement realtime subscription
    throw UnimplementedError();
  }

  @override
  Stream<List<EmergencyRequest>> watchAllActiveRequests() {
    // ignore: todo
    // TODO: Implement realtime subscription
    throw UnimplementedError();
  }
}
