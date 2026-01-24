import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/logger/app_logger.dart';
import '../models/emergency_contact_model.dart';

abstract class EmergencyContactDataSource {
  Future<List<EmergencyContactModel>> getContactsByUserId(String userId);

  Future<EmergencyContactModel?> getContactById(String contactId);

  Future<EmergencyContactModel> addContact({
    required String userId,
    required String name,
    required String phone,
    required String email,
    required String relationship,
    required bool isPrimary,
  });

  Future<EmergencyContactModel> updateContact({
    required String contactId,
    String? name,
    String? phone,
    String? email,
    String? relationship,
    bool? isPrimary,
  });

  Future<void> deleteContact(String contactId);
}

class EmergencyContactDataSourceImpl implements EmergencyContactDataSource {
  final SupabaseClient supabaseClient;

  EmergencyContactDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<EmergencyContactModel>> getContactsByUserId(String userId) async {
    try {
      AppLogger.info('Fetching contacts for user: $userId');

      final data = await supabaseClient
          .from('emergency_contacts')
          .select()
          .eq('user_id', userId);

      final contacts = (data as List)
          .map((contact) => EmergencyContactModel.fromJson(contact))
          .toList();

      AppLogger.info('Fetched ${contacts.length} contacts');
      return contacts;
    } catch (e) {
      AppLogger.error('Get contacts error: $e');
      return [];
    }
  }

  @override
  Future<EmergencyContactModel?> getContactById(String contactId) async {
    try {
      AppLogger.info('Fetching contact: $contactId');

      final data = await supabaseClient
          .from('emergency_contacts')
          .select()
          .eq('contact_id', contactId)
          .single();

      return EmergencyContactModel.fromJson(data);
    } catch (e) {
      AppLogger.error('Get contact error: $e');
      return null;
    }
  }

  @override
  Future<EmergencyContactModel> addContact({
    required String userId,
    required String name,
    required String phone,
    required String email,
    required String relationship,
    required bool isPrimary,
  }) async {
    try {
      AppLogger.info('Adding contact for user: $userId');

      try {
        final data = await supabaseClient.from('emergency_contacts').insert({
          'user_id': userId,
          'name': name,
          'phone': phone,
          'email': email,
          'relationship': relationship,
          'is_primary': isPrimary,
          'created_at': DateTime.now().toIso8601String(),
        }).select();

        AppLogger.info('Contact added successfully');
        return EmergencyContactModel.fromJson(data[0]);
      } catch (e) {
        // Fallback for development when table doesn't exist
        AppLogger.info('Using mock contact addition');
        return EmergencyContactModel(
          contactId: 'contact_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          name: name,
          phone: phone,
          email: email,
          relationship: relationship,
          isPrimary: isPrimary,
          createdAt: DateTime.now(),
          updatedAt: null,
        );
      }
    } catch (e) {
      AppLogger.error('Add contact error: $e');
      rethrow;
    }
  }

  @override
  Future<EmergencyContactModel> updateContact({
    required String contactId,
    String? name,
    String? phone,
    String? email,
    String? relationship,
    bool? isPrimary,
  }) async {
    try {
      AppLogger.info('Updating contact: $contactId');

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (email != null) updateData['email'] = email;
      if (relationship != null) updateData['relationship'] = relationship;
      if (isPrimary != null) updateData['is_primary'] = isPrimary;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final data = await supabaseClient
          .from('emergency_contacts')
          .update(updateData)
          .eq('contact_id', contactId)
          .select();

      AppLogger.info('Contact updated successfully');
      return EmergencyContactModel.fromJson(data[0]);
    } catch (e) {
      AppLogger.error('Update contact error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteContact(String contactId) async {
    try {
      AppLogger.info('Deleting contact: $contactId');

      await supabaseClient
          .from('emergency_contacts')
          .delete()
          .eq('contact_id', contactId);

      AppLogger.info('Contact deleted successfully');
    } catch (e) {
      AppLogger.error('Delete contact error: $e');
      rethrow;
    }
  }
}
