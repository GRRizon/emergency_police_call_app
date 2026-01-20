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
  final TextEditingController emailController =
      TextEditingController(text: '75golamrabbani@gmail.com');
  final TextEditingController passwordController =
      TextEditingController(text: '12345678');
  bool isLoading = false;

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
