import '../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../domain/repositories/emergency_contact_repository.dart';
import '../datasources/emergency_contact_datasource.dart';

class EmergencyContactRepositoryImpl implements EmergencyContactRepository {
  final EmergencyContactDataSource dataSource;

  EmergencyContactRepositoryImpl({required this.dataSource});

  @override
  Future<List<EmergencyContact>> getContactsByUserId(String userId) async {
    try {
      return await dataSource.getContactsByUserId(userId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<EmergencyContact?> getContactById(String contactId) async {
    try {
      return await dataSource.getContactById(contactId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<EmergencyContact> addContact({
    required String userId,
    required String name,
    required String phone,
    required String email,
    required String relationship,
    required bool isPrimary,
  }) async {
    try {
      return await dataSource.addContact(
        userId: userId,
        name: name,
        phone: phone,
        email: email,
        relationship: relationship,
        isPrimary: isPrimary,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<EmergencyContact> updateContact({
    required String contactId,
    String? name,
    String? phone,
    String? email,
    String? relationship,
    bool? isPrimary,
  }) async {
    try {
      return await dataSource.updateContact(
        contactId: contactId,
        name: name,
        phone: phone,
        email: email,
        relationship: relationship,
        isPrimary: isPrimary,
      );
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> deleteContact(String contactId) async {
    try {
      return await dataSource.deleteContact(contactId);
    } on AppException {
      rethrow;
    }
  }

  @override
  Future<void> notifyContacts({
    required String userId,
    required String message,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await getContactsByUserId(userId);

      // ignore: todo
      // TODO: Implement notification logic via SMS/Email to all contacts
      // for (final contact in contacts) {
      //   // Send SMS/Email with location and message
      // }
    } on AppException {
      rethrow;
    }
  }
}
