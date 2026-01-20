import 'package:flutter/material.dart';
import 'sos_page.dart';
import 'authentication.dart';
import 'navigation_service.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  Future<void> logout() async {
    setState(() => isLoading = true);
    try {
      await supabase.auth.signOut();
      NavigationService.navigateTo(const AuthPage(), replace: true);
    } catch (e) {
      NavigationService.showSnackBar("Error logging out: $e", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Emergency Police Call App",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  onPressed: logout, icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Are you in an emergency?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Press and hold the button for 3 seconds"),
            const Spacer(),

            // Massive SOS Button with "Pulse" Shadow
            GestureDetector(
              onLongPress: () => NavigationService.navigateTo(const SosPage()),
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withAlpha(80),
                      spreadRadius: 20,
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_rounded, size: 100, color: Colors.white),
                    Text(
                      "SOS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Navigation Cards
            Row(
              children: [
                Expanded(
                  child: _buildNavCard(
                    icon: Icons.account_circle_rounded,
                    label: "Profile",
                    color: Colors.indigo,
                    onTap: () =>
                        NavigationService.navigateTo(const ProfilePage()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNavCard(
                    icon: Icons.settings_suggest_rounded,
                    label: "Settings",
                    color: Colors.blueGrey,
                    onTap: () =>
                        NavigationService.navigateTo(const SettingsPage()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 10),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
