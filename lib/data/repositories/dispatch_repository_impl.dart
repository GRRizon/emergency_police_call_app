import '../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/dispatch_record.dart';
import '../../domain/repositories/dispatch_repository.dart';
import '../datasources/dispatch_datasource.dart';

class DispatchRepositoryImpl implements DispatchRepository {
  final DispatchDataSource dataSource;

  DispatchRepositoryImpl({required this.dataSource});

  @override
  Future<DispatchRecord> createDispatch({
    required String requestId,
    required String policeId,
    required String dispatchLocation,
  }) async {
    try {
      return await dataSource.createDispatch(
        requestId: requestId,
        policeId: policeId,
        dispatchLocation: dispatchLocation,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<DispatchRecord?> getDispatchById(String dispatchId) async {
    try {
      return await dataSource.getDispatchById(dispatchId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<List<DispatchRecord>> getDispatchByRequestId(String requestId) async {
    try {
      return await dataSource.getDispatchByRequestId(requestId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<List<DispatchRecord>> getDispatchByOfficerId(String policeId) async {
    try {
      return await dataSource.getDispatchByOfficerId(policeId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<DispatchRecord> updateDispatchStatus({
    required String dispatchId,
    required DateTime? arrivalTime,
  }) async {
    try {
      return await dataSource.updateDispatchStatus(
        dispatchId: dispatchId,
        arrivalTime: arrivalTime,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<DispatchRecord> updateDispatchNotes({
    required String dispatchId,
    required String notes,
  }) async {
    try {
      return await dataSource.updateDispatchNotes(
        dispatchId: dispatchId,
        notes: notes,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> acceptDispatch(String dispatchId) async {
    try {
      return await dataSource.acceptDispatch(dispatchId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> rejectDispatch(String dispatchId) async {
    try {
      return await dataSource.rejectDispatch(dispatchId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Stream<DispatchRecord> watchDispatch(String dispatchId) {
    // ignore: todo
    // TODO: Implement realtime subscription
    throw UnimplementedError();
  }
}
