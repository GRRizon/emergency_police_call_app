import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'authentication.dart';
import 'home_page.dart';
import 'navigation_service.dart';
import 'services/police_dashboard.dart';
import 'services/admin_dashboard.dart';

const String supabaseUrl = 'https://xvpwnzxlczjyhzbomcxk.supabase.co';
const String supabaseAnonKey = 'sb_publishable_IkgkR72tiPInVP8I2XOd_A_ZA6rQQF6';

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const EmergencyApp());
}

class EmergencyApp extends StatelessWidget {
  const EmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Emergency Police Call App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;
    if (session == null) return const AuthPage();

    return FutureBuilder<Map<String, dynamic>>(
      future: supabase
          .from('profiles')
          .select('role')
          .eq('id', session.user.id)
          .single(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final role = snapshot.data?['role'] ?? 'citizen';

        // Return different Dashboards based on role
        if (role == 'police') return const PoliceDashboard();
        if (role == 'admin') return const AdminDashboard();
        return const HomePage(); // Default Citizen Page
      },
    );
  }
}
