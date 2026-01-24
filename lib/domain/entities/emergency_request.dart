class EmergencyRequest {
  final String requestId;
  final String userId;
  final double latitude;
  final double longitude;
  final String description;
  final EmergencyRequestStatus status;
  final DateTime timestamp;
  final String? assignedOfficerId;
  final DateTime? resolvedAt;

  EmergencyRequest({
    required this.requestId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.status = EmergencyRequestStatus.pending,
    required this.timestamp,
    this.assignedOfficerId,
    this.resolvedAt,
  });

  EmergencyRequest copyWith({
    String? requestId,
    String? userId,
    double? latitude,
    double? longitude,
    String? description,
    EmergencyRequestStatus? status,
    DateTime? timestamp,
    String? assignedOfficerId,
    DateTime? resolvedAt,
  }) {
    return EmergencyRequest(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      assignedOfficerId: assignedOfficerId ?? this.assignedOfficerId,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  String toString() =>
      'EmergencyRequest(requestId: $requestId, userId: $userId, status: $status)';
}

enum EmergencyRequestStatus {
  pending,
  accepted,
  enRoute,
  arrived,
  resolved,
  cancelled
}
