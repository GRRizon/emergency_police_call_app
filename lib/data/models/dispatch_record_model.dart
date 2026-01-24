import '../../../domain/entities/dispatch_record.dart';

class DispatchRecordModel extends DispatchRecord {
  DispatchRecordModel({
    required super.dispatchId,
    required super.requestId,
    required super.policeId,
    required super.dispatchTime,
    super.arrivalTime,
    required super.dispatchLocation,
    super.acceptedByRequest,
    super.notes,
  });

  factory DispatchRecordModel.fromJson(Map<String, dynamic> json) {
    return DispatchRecordModel(
      dispatchId: json['dispatch_id'] as String,
      requestId: json['request_id'] as String,
      policeId: json['police_id'] as String,
      dispatchTime: DateTime.parse(json['dispatch_time'] as String),
      arrivalTime: json['arrival_time'] != null
          ? DateTime.parse(json['arrival_time'] as String)
          : null,
      dispatchLocation: json['dispatch_location'] as String,
      acceptedByRequest: json['accepted_by_request'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dispatch_id': dispatchId,
      'request_id': requestId,
      'police_id': policeId,
      'dispatch_time': dispatchTime.toIso8601String(),
      'arrival_time': arrivalTime?.toIso8601String(),
      'dispatch_location': dispatchLocation,
      'accepted_by_request': acceptedByRequest,
      'notes': notes,
    };
  }
}
