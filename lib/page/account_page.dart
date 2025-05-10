import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
        backgroundColor: Colors.green[800],
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
            /*ElevatedButton(
              onPressed: () async {
                await _authService.logout();
                setState(() {}); // Refresh the page after logout
              },
              child: const Text('Logout'),
            ),*/
          ],
        ),
      ),
    );
  }
}