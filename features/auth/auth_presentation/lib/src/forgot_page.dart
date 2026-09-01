import 'package:flutter/material.dart';

class ForgotPage extends StatelessWidget {
  const ForgotPage({required this.onBackToLogin, super.key});

  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Public route — no session required.'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onBackToLogin,
                child: const Text('Back to login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
