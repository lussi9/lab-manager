
import 'package:flutter/material.dart';
import 'package:lab_manager/account/login_screen.dart';
import 'package:lab_manager/account/register_screen.dart';

class AuthUserPage extends StatefulWidget {
  const AuthUserPage({super.key});

  @override
  State<AuthUserPage> createState() => _AuthUserPageState();
}

class _AuthUserPageState extends State<AuthUserPage> {
  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF005a4e), Color(0xFF92e086)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/logoNoBG400.png', // Path to the logo image
              height: 360,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:  () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(), // Navigate to login screen
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(180, 70),
                backgroundColor: Color(0xFFEDEDED),
              ),
              child: Text('Sign in', style: TextStyle(color: Color(0xFF005a4e))),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(), // Navigate to register screen
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(180, 70),
                backgroundColor: Color(0xFFEDEDED),
              ),
              child: Text('Register', style: TextStyle(color: Color(0xFF005a4e))),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

