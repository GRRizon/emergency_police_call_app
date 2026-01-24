class EmergencyContact {
  final String contactId;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String relationship;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EmergencyContact({
    required this.contactId,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.relationship,
    this.isPrimary = false,
    required this.createdAt,
    this.updatedAt,
  });

  EmergencyContact copyWith({
    String? contactId,
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? relationship,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyContact(
      contactId: contactId ?? this.contactId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'EmergencyContact(contactId: $contactId, name: $name, phone: $phone)';
}
