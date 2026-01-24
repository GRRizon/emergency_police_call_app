import '../../../domain/entities/police_officer.dart';

class PoliceOfficerModel extends PoliceOfficer {
  PoliceOfficerModel({
    required super.policeId,
    required super.userId,
    required super.name,
    required super.badge,
    required super.phone,
    required super.email,
    required super.precinct,
    super.isAvailable,
    super.currentLatitude,
    super.currentLongitude,
    super.acceptedRequests,
    super.completedRequests,
    super.vehicleInfo,
    required super.createdAt,
    super.updatedAt,
  });

  factory PoliceOfficerModel.fromJson(Map<String, dynamic> json) {
    return PoliceOfficerModel(
      policeId: json['police_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      badge: json['badge'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      precinct: json['precinct'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      currentLatitude: (json['current_latitude'] as num?)?.toDouble(),
      currentLongitude: (json['current_longitude'] as num?)?.toDouble(),
      acceptedRequests: json['accepted_requests'] as int? ?? 0,
      completedRequests: json['completed_requests'] as int? ?? 0,
      vehicleInfo: json['vehicle_info'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'police_id': policeId,
      'user_id': userId,
      'name': name,
      'badge': badge,
      'phone': phone,
      'email': email,
      'precinct': precinct,
      'is_available': isAvailable,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'accepted_requests': acceptedRequests,
      'completed_requests': completedRequests,
      'vehicle_info': vehicleInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
