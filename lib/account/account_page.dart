import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab_manager/main.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) { 
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(67, 160, 71, 1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user?.email ?? 'User'}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const AuthUserPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size(160, 55),
                backgroundColor: Colors.red, 
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign out',
                style: TextStyle(fontSize: 18),),
            ),
          ],
        ),
      ),
    );
  }
}