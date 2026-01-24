import '../../../domain/entities/emergency_contact.dart';

class EmergencyContactModel extends EmergencyContact {
  EmergencyContactModel({
    required super.contactId,
    required super.userId,
    required super.name,
    required super.phone,
    required super.email,
    required super.relationship,
    super.isPrimary,
    required super.createdAt,
    super.updatedAt,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      contactId: json['contact_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      relationship: json['relationship'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact_id': contactId,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
      'is_primary': isPrimary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
