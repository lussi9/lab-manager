
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
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
              backgroundColor: Color.fromRGBO(67, 160, 71, 1),
              minimumSize: const Size(180, 60),
            ),
            child: const Text('Sign in', style: TextStyle(fontSize: 22, color: Colors.white),),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RegisterScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(67, 160, 71, 1),
              minimumSize: const Size(180, 60),
            ),
            child: const Text('Register', style: TextStyle(fontSize: 22, color: Colors.white)),
          ),
        ],
      ),
      ),
    );
  }
}

