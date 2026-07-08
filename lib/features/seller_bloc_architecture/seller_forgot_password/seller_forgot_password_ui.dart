import 'package:flutter/material.dart';

class SellerForgotPasswordPageUI extends StatelessWidget {
  const SellerForgotPasswordPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}
