class DispatchRecord {
  final String dispatchId;
  final String requestId;
  final String policeId;
  final DateTime dispatchTime;
  final DateTime? arrivalTime;
  final String dispatchLocation;
  final bool acceptedByRequest;
  final String? notes;

  DispatchRecord({
    required this.dispatchId,
    required this.requestId,
    required this.policeId,
    required this.dispatchTime,
    this.arrivalTime,
    required this.dispatchLocation,
    this.acceptedByRequest = false,
    this.notes,
  });

  DispatchRecord copyWith({
    String? dispatchId,
    String? requestId,
    String? policeId,
    DateTime? dispatchTime,
    DateTime? arrivalTime,
    String? dispatchLocation,
    bool? acceptedByRequest,
    String? notes,
  }) {
    return DispatchRecord(
      dispatchId: dispatchId ?? this.dispatchId,
      requestId: requestId ?? this.requestId,
      policeId: policeId ?? this.policeId,
      dispatchTime: dispatchTime ?? this.dispatchTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      dispatchLocation: dispatchLocation ?? this.dispatchLocation,
      acceptedByRequest: acceptedByRequest ?? this.acceptedByRequest,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'DispatchRecord(dispatchId: $dispatchId, requestId: $requestId, policeId: $policeId)';
}
