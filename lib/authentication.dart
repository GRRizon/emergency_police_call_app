import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'navigation_service.dart';

final supabase = Supabase.instance.client;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String selectedRole = 'citizen';

  // Credentials for different roles
  final Map<String, Map<String, String>> credentials = {
    'citizen': {
      'emails': '75golamrabbani@gmail.com or 75citizen@gmail.com',
      'primaryEmail': '75golamrabbani@gmail.com or 75citizen@gmail.com',
      'password': '12345678',
    },
    'police': {
      'emails': '75police@gmail.com',
      'primaryEmail': '75police@gmail.com',
      'password': '123456',
    },
    'admin': {
      'emails': '75admin@gmail.com',
      'primaryEmail': '75admin@gmail.com',
      'password': '1234',
    },
  };

  @override
  void initState() {
    super.initState();
    _updateCredentials('citizen');
  }

  void _updateCredentials(String role) {
    setState(() {
      selectedRole = role;
      final creds = credentials[role]!;
      emailController.text = creds['primaryEmail']!;
      passwordController.text = creds['password']!;
    });
  }

  Widget _buildRoleButton(String roleValue, String roleLabel, IconData icon) {
    final isSelected = selectedRole == roleValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => _updateCredentials(roleValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.red,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                roleLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      NavigationService.navigateTo(const HomePage(), replace: true);
    } on AuthException catch (e) {
      NavigationService.showSnackBar(e.message, isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> signUp() async {
    setState(() => isLoading = true);
    try {
      await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      NavigationService.showSnackBar("Success! Check email or try logging in.");
    } on AuthException catch (e) {
      NavigationService.showSnackBar(e.message, isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Colors.red[800]!, Colors.red[400]!],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.security, size: 80, color: Colors.white),
            const Text(
              "EMERGENCY APP",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  const Text(
                    "Select User Role",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRoleButton('citizen', 'Citizen', Icons.person),
                        _buildRoleButton(
                            'police', 'Police', Icons.local_police),
                        _buildRoleButton(
                            'admin', 'Admin', Icons.admin_panel_settings),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Available Credentials:",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          credentials[selectedRole]!['emails']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        labelText: "Email", prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: "Password", prefixIcon: Icon(Icons.lock)),
                  ),
                  const SizedBox(height: 30),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(16),
                                ),
                                child: const Text("LOGIN"),
                              ),
                            ),
                            TextButton(
                                onPressed: signUp,
                                child: const Text("Create Account")),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
