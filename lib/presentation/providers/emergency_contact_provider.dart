import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logger/app_logger.dart';
import '../../core/service_locator.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../domain/repositories/emergency_contact_repository.dart';

final emergencyContactRepositoryProvider =
    Provider<EmergencyContactRepository>((ref) {
  return getIt<EmergencyContactRepository>();
});

final emergencyContactsProvider =
    FutureProvider.family<List<EmergencyContact>, String>((ref, userId) async {
  final repository = ref.watch(emergencyContactRepositoryProvider);
  try {
    AppLogger.info('Fetching emergency contacts for user: $userId');
    final contacts = await repository.getContactsByUserId(userId);
    AppLogger.info('Fetched ${contacts.length} emergency contacts');
    return contacts;
  } catch (e) {
    AppLogger.error('Fetch emergency contacts error: $e');
    rethrow;
  }
});

final emergencyContactNotifierProvider = StateNotifierProvider<
    EmergencyContactNotifier, AsyncValue<List<EmergencyContact>>>(
  (ref) {
    return EmergencyContactNotifier(
        ref.watch(emergencyContactRepositoryProvider));
  },
);

class EmergencyContactNotifier
    extends StateNotifier<AsyncValue<List<EmergencyContact>>> {
  final EmergencyContactRepository repository;

  EmergencyContactNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> loadContacts(String userId) async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() => repository.getContactsByUserId(userId));
  }

  Future<void> addContact({
    required String userId,
    required String name,
    required String phone,
    required String email,
    required String relationship,
    required bool isPrimary,
  }) async {
    try {
      AppLogger.info('Adding emergency contact');
      final newContact = await repository.addContact(
        userId: userId,
        name: name,
        phone: phone,
        email: email,
        relationship: relationship,
        isPrimary: isPrimary,
      );

      state.whenData((contacts) {
        state = AsyncValue.data([...contacts, newContact]);
      });

      AppLogger.info('Emergency contact added');
    } catch (e) {
      AppLogger.error('Add contact error: $e');
      rethrow;
    }
  }

  Future<void> updateContact({
    required String contactId,
    String? name,
    String? phone,
    String? email,
    String? relationship,
    bool? isPrimary,
  }) async {
    try {
      AppLogger.info('Updating emergency contact: $contactId');
      final updatedContact = await repository.updateContact(
        contactId: contactId,
        name: name,
        phone: phone,
        email: email,
        relationship: relationship,
        isPrimary: isPrimary,
      );

      state.whenData((contacts) {
        final index = contacts.indexWhere((c) => c.contactId == contactId);
        if (index != -1) {
          contacts[index] = updatedContact;
          state = AsyncValue.data([...contacts]);
        }
      });

      AppLogger.info('Emergency contact updated');
    } catch (e) {
      AppLogger.error('Update contact error: $e');
      rethrow;
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      AppLogger.info('Deleting emergency contact: $contactId');
      await repository.deleteContact(contactId);

      state.whenData((contacts) {
        state = AsyncValue.data(
          contacts.where((c) => c.contactId != contactId).toList(),
        );
      });

      AppLogger.info('Emergency contact deleted');
    } catch (e) {
      AppLogger.error('Delete contact error: $e');
      rethrow;
    }
  }
}
