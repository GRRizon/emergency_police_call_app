class User {
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String password;
  final String address;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.address,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? password,
    String? address,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      address: address ?? this.address,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'User(userId: $userId, name: $name, email: $email)';
}

enum UserRole { citizen, police, admin }
