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
    _fetchUserData();
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
        backgroundColor: Color.fromRGBO(67, 160, 71, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
        child: ListView(
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4, // Add elevation for shadow effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
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
            leading: Icon(icon, color: title == ("Delete Account")? Colors.red : Color.fromRGBO(67, 160, 71, 1)),
            title: Text(title, style: TextStyle(fontSize: 18),),
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
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(67, 160, 71, 1),
            ),
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: const Text('Sign out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _auth.signOut();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthUserPage()),
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
                  cursorColor: Colors.grey[350],
                  obscureText: !isOldPassVisible,
                  decoration: InputDecoration(
                    labelText: 'Old Password',
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
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
                  cursorColor: Colors.grey[350],
                  obscureText: !isNewPassVisible,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
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
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(67, 160, 71, 1),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                // Re-authenticate the user with the old password
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
          child: const Text('Change', style: TextStyle(color: Colors.white)),
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
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Delete the user's account
        await _auth.currentUser!.delete();

        // Navigate to the login page after account deletion
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthUserPage()),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
      } catch (e) {
        // Handle errors (e.g., re-authentication required)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}