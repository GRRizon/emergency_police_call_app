import '../../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.userId,
    required super.name,
    required super.phone,
    required super.email,
    required super.password,
    required super.address,
    required super.role,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      address: json['address'] as String,
      role: _parseRole(json['role'] as String),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'address': address,
      'role': role.toString().split('.').last,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static UserRole _parseRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'police':
        return UserRole.police;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.citizen;
    }
  }
}
