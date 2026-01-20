import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.indigo,
                child: Icon(Icons.person, size: 60, color: Colors.white)),
            const SizedBox(height: 30),
            Text(user?.email ?? 'Unknown User',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Authenticated via Supabase",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            const Divider(indent: 50, endIndent: 50),
          ],
        ),
      ),
    );
  }
}
