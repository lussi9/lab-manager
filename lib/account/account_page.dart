import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab_manager/account/auth_user_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String name = '';
  
  @override
  void initState() {
    super.initState();
    _fetchUserData(); // fetches the user data from firestore
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    setState(() {
      name = '${userDoc.data()?['name']} ${userDoc.data()?['surname']}' ;
    });
  }
  
   Widget build(BuildContext context) {
    final user = _auth.currentUser;// Retrieve the username field

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
        child: ListView(
          children: [
            Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
            Text(user?.email ?? '', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: [
                  buildMenuItem(Icons.password, "Change Password", _showChangePasswordDialog),
                  const Divider(height: 0, indent: 15 , endIndent: 15,),
                  buildMenuItem(Icons.exit_to_app, "Sign out", _showSignOut),
                  const Divider(height: 0, indent: 15 , endIndent: 15,),
                  buildMenuItem(Icons.delete, "Delete Account", _showDeleteAccountDialog),
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(IconData icon, String title, GestureTapCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
            title: Text(title, style: Theme.of(context).textTheme.titleMedium),
            onTap: onTap,
          ),
        ],
      )
    );
  }

  void _showSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: Text('Are you sure you want to sign out?', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Sign out confirmation
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _auth.signOut();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthUserPage()), // Navigates to initial page
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final _formKey = GlobalKey<FormState>();
    String oldPassword = '';
    String newPassword = '';
    bool isOldPassVisible = false;
    bool isNewPassVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    obscureText: !isOldPassVisible,
                    decoration: InputDecoration(
                      hintText: 'Old Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isOldPassVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isOldPassVisible = !isOldPassVisible; // Toggle visibility
                          });
                        },
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your old password' : null,
                    onChanged: (value) => oldPassword = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: !isNewPassVisible,
                    decoration: InputDecoration(
                      hintText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isNewPassVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isNewPassVisible = !isNewPassVisible; // Toggle visibility
                          });
                        },
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.length < 6 ? 'Enter at least 6 characters' : null,
                    onChanged: (value) => newPassword = value,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  // User reauthentication with old password
                  final user = _auth.currentUser!;
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: oldPassword,
                  );
                  await user.reauthenticateWithCredential(credential);

                  // Update the password
                  await user.updatePassword(newPassword);
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
            child: const Text('Change'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showDeleteAccountDialog() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Account'),
      content: Text(
        'Are you sure you want to delete your account? This action cannot be undone.',
        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    try {
      final user = FirebaseAuth.instance.currentUser;
      // Prompt user for password
      final passwordController = TextEditingController();
      final reauth = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Re-authenticate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your password to continue.', style: TextStyle(color: Color(0xFF005a4e), fontSize: 16)),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (reauth != true) return;

      final email = user?.email;
      final password = passwordController.text;
      final userId = user?.uid;
      final credential = EmailAuthProvider.credential(email: email!, password: password);

      // User reauthentication
      await user!.reauthenticateWithCredential(credential);

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

      // Delete entries
      final entries = await userDocRef.collection('entries').get();
      for (var doc in entries.docs) {
        await doc.reference.delete();
      }

      // Delete events
      final events = await userDocRef.collection('events').get();
      for (var doc in events.docs) {
        await doc.reference.delete();
      }

      // Delete folders and their fungibles
      final folders = await userDocRef.collection('folders').get();
      for (var folder in folders.docs) {
        final fungibles = await folder.reference.collection('fungibles').get();
        for (var f in fungibles.docs) {
          await f.reference.delete();
        }
        await folder.reference.delete();
      }

      // Delete user document
      await userDocRef.delete();

      // Delete account
      await user.delete();

      // Navigate to initial page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthUserPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}

}