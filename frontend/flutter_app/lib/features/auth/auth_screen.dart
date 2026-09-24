import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController(text: "shivam@fitsync.ai");
  final _passwordController = TextEditingController(text: "secretPassword123!");
  final _nameController = TextEditingController(text: "Shivam Patel");
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    // Simulate secure network/local authentication
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navigate to Home Dashboard
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.fitness_center_rounded, size: 54, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  "FitSync AI",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _isLogin ? "Welcome back! Ready for today's session?" : "Join the privacy-first fitness platform",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                // Form Cards
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),

                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isLogin ? "Sign In" : "Create Account", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: const Text("Continue with Google"),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
                const SizedBox(height: 24),

                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin ? "Don't have an account? Sign up" : "Already have an account? Sign in"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

