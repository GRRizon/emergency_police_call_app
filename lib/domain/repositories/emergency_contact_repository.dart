import '../../domain/entities/emergency_contact.dart';

abstract class EmergencyContactRepository {
  Future<List<EmergencyContact>> getContactsByUserId(String userId);

  Future<EmergencyContact?> getContactById(String contactId);

  Future<EmergencyContact> addContact({
    required String userId,
    required String name,
    required String phone,
    required String email,
    required String relationship,
    required bool isPrimary,
  });

  Future<EmergencyContact> updateContact({
    required String contactId,
    String? name,
    String? phone,
    String? email,
    String? relationship,
    bool? isPrimary,
  });

  Future<void> deleteContact(String contactId);

  Future<void> notifyContacts({
    required String userId,
    required String message,
    required double latitude,
    required double longitude,
  });
}
