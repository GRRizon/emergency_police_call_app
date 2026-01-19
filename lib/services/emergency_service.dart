import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class EmergencyService {
  /// Send SOS with initial location
  Future<void> sendEmergency(double lat, double lng) async {
    await supabase.from('emergencies').insert({
      'user_id': supabase.auth.currentUser!.id,
      'latitude': lat,
      'longitude': lng,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Update live location
  Future<void> updateLocation(double lat, double lng) async {
    await supabase
        .from('emergencies')
        .update({'latitude': lat, 'longitude': lng})
        .eq('user_id', supabase.auth.currentUser!.id);
  }
}
