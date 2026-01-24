class PoliceOfficer {
  final String policeId;
  final String userId;
  final String name;
  final String badge;
  final String phone;
  final String email;
  final String precinct;
  final bool isAvailable;
  final double? currentLatitude;
  final double? currentLongitude;
  final int acceptedRequests;
  final int completedRequests;
  final String? vehicleInfo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PoliceOfficer({
    required this.policeId,
    required this.userId,
    required this.name,
    required this.badge,
    required this.phone,
    required this.email,
    required this.precinct,
    this.isAvailable = true,
    this.currentLatitude,
    this.currentLongitude,
    this.acceptedRequests = 0,
    this.completedRequests = 0,
    this.vehicleInfo,
    required this.createdAt,
    this.updatedAt,
  });

  PoliceOfficer copyWith({
    String? policeId,
    String? userId,
    String? name,
    String? badge,
    String? phone,
    String? email,
    String? precinct,
    bool? isAvailable,
    double? currentLatitude,
    double? currentLongitude,
    int? acceptedRequests,
    int? completedRequests,
    String? vehicleInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PoliceOfficer(
      policeId: policeId ?? this.policeId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      badge: badge ?? this.badge,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      precinct: precinct ?? this.precinct,
      isAvailable: isAvailable ?? this.isAvailable,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      acceptedRequests: acceptedRequests ?? this.acceptedRequests,
      completedRequests: completedRequests ?? this.completedRequests,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'PoliceOfficer(policeId: $policeId, name: $name, badge: $badge)';
}
