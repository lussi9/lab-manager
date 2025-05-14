import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String nombre;
  final String apellidos;
  final String email;
  final String nombreUsuario;

  const EmailVerificationScreen({
    Key? key,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.nombreUsuario,
  }) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Método para guardar el usuario en Firestore
  Future<void> _saveUserData(User user) async {
    await _firestore.collection('Users').doc(user.uid).set({
      'nombre': widget.nombre,
      'apellidos': widget.apellidos,
      'email': widget.email,
      'nombreUsuario': widget.nombreUsuario,
    });
  }

  // Método para verificar el correo
  Future<void> _checkEmailVerification() async {
    User? user = _auth.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      await _saveUserData(user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered correctly.')),
      );
      Navigator.of(context)
          .popUntil((route) => route.isFirst); // Vuelve al inicio
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The email address has not been verified yet.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(67, 160, 71, 1),
        automaticallyImplyLeading: false, // Oculta el botón de retroceso
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'A verification email has been sent to your account. Please check your email and press the button below to continue.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkEmailVerification,
              style: ElevatedButton.styleFrom(
                minimumSize:
                  const Size(160, 50),
                backgroundColor: Color.fromRGBO(67, 160, 71, 1), 
                foregroundColor: Colors.white,
              ),
              child: const Text('Verify email and complete registration', 
                style: TextStyle(fontSize: 16),
              ), 
            ),
          ],
        ),
      ),
    );
  }
}
