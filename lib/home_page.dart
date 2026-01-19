import 'package:flutter/material.dart';
import 'sos_page.dart';
import 'authentication.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  /// Logout safely
  Future<void> logout() async {
    setState(() => isLoading = true);

    try {
      await supabase.auth.signOut();

      // ✅ Async-safe navigation
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error logging out: $e")));
    } finally {
      // ✅ Only cleanup, no return
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Navigate to SOS page safely
  Future<void> openSosPage() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // simulate async work

    // ✅ Early return if disposed
    if (!mounted) return;

    Navigator.push(context, MaterialPageRoute(builder: (_) => const SosPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        backgroundColor: Colors.blue,
        actions: [
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.warning),
              label: const Text("Open SOS"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 40,
                ),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: openSosPage,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text("Profile / Settings"),
              onPressed: () async {
                await Future.delayed(const Duration(seconds: 1));

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile clicked")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
