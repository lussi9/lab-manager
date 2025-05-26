import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab_manager/account/auth_user_page.dart';

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
              onPressed: _showChangePasswordDialog,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 50),
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Text('Change Password', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showChangeEmailDialog,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 50),
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Text('Change Email', style: TextStyle(fontSize: 16)),
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

  void _showChangePasswordDialog() {
  final _formKey = GlobalKey<FormState>();
  String newPassword = '';
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          cursorColor: Colors.grey[350],
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
            labelStyle: TextStyle(color: Colors.grey),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          validator: (value) =>
              value == null || value.length < 6 ? 'Enter at least 6 characters' : null,
          onChanged: (value) => newPassword = value,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(67, 160, 71, 1),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                await _auth.currentUser!.updatePassword(newPassword);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            }
          },
          child: const Text('Change', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void _showChangeEmailDialog() {
  final _formKey = GlobalKey<FormState>();
  String newEmail = '';
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Change Email'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          cursorColor: Colors.grey[350],
          decoration: const InputDecoration(
            labelText: 'New Email',
            labelStyle: TextStyle(color: Colors.grey),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          validator: (value) =>
              value == null || !value.contains('@') ? 'Enter a valid email' : null,
          onChanged: (value) => newEmail = value,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(67, 160, 71, 1),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                await _auth.currentUser!.updateEmail(newEmail);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email changed successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            }
          },
          child: const Text('Change', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
}