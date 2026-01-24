import '../../domain/entities/dispatch_record.dart';

abstract class DispatchRepository {
  Future<DispatchRecord> createDispatch({
    required String requestId,
    required String policeId,
    required String dispatchLocation,
  });

  Future<DispatchRecord?> getDispatchById(String dispatchId);

  Future<List<DispatchRecord>> getDispatchByRequestId(String requestId);

  Future<List<DispatchRecord>> getDispatchByOfficerId(String policeId);

  Future<DispatchRecord> updateDispatchStatus({
    required String dispatchId,
    required DateTime? arrivalTime,
  });

  Future<DispatchRecord> updateDispatchNotes({
    required String dispatchId,
    required String notes,
  });

  Future<void> acceptDispatch(String dispatchId);

  Future<void> rejectDispatch(String dispatchId);

  Stream<DispatchRecord> watchDispatch(String dispatchId);
}
