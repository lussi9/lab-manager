import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordRequestScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ResetPasswordRequestScreen({super.key});

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your email address.')),
      );
      return;
    }

    try { // Attempt to send a password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Email sent'),
          content: const Text(
              'An email has been sent to reset your password. Please check your inbox and follow the instructions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff005a4e))),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Accept'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An unexpected error occured.';
      if (e.code == 'invalid-email') {
        errorMessage = 'Email address is not valid.';
      } else if (e.code == 'user-not-found') {
        errorMessage =
            'No user found for that email address.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reset Password',
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Introduce your email address to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xff005a4e)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email address',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _sendPasswordResetEmail(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
