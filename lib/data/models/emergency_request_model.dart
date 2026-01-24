import '../../../domain/entities/emergency_request.dart';

class EmergencyRequestModel extends EmergencyRequest {
  EmergencyRequestModel({
    required super.requestId,
    required super.userId,
    required super.latitude,
    required super.longitude,
    required super.description,
    super.status,
    required super.timestamp,
    super.assignedOfficerId,
    super.resolvedAt,
  });

  factory EmergencyRequestModel.fromJson(Map<String, dynamic> json) {
    return EmergencyRequestModel(
      requestId: json['request_id'] as String,
      userId: json['user_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String,
      status: _parseStatus(json['status'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      assignedOfficerId: json['assigned_officer_id'] as String?,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'assigned_officer_id': assignedOfficerId,
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  static EmergencyRequestStatus _parseStatus(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'accepted':
        return EmergencyRequestStatus.accepted;
      case 'enroute':
        return EmergencyRequestStatus.enRoute;
      case 'arrived':
        return EmergencyRequestStatus.arrived;
      case 'resolved':
        return EmergencyRequestStatus.resolved;
      case 'cancelled':
        return EmergencyRequestStatus.cancelled;
      default:
        return EmergencyRequestStatus.pending;
    }
  }
}
