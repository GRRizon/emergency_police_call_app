import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ContactService {
  Future<List> getContacts() async {
    return await supabase
        .from('emergency_contacts')
        .select()
        .eq('user_id', supabase.auth.currentUser!.id);
  }

  Future<void> addContact(String name, String phone) async {
    await supabase.from('emergency_contacts').insert({
      'user_id': supabase.auth.currentUser!.id,
      'name': name,
      'phone': phone,
    });
  }

  Future<void> deleteContact(int id) async {
    await supabase.from('emergency_contacts').delete().eq('id', id);
  }
}
