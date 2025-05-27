import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          await user.sendEmailVerification();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(
                name: _nameController.text.trim(),
                surname: _surnameController.text.trim(),
                email: _emailController.text.trim(),
              ),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error in the register: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(67, 160, 71, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () { 
            Navigator.of(context).pop();
          }
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Introduce your name';
                              }
                              if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s-]+$')
                                  .hasMatch(value)) {
                                return 'The name can only contain letters, spaces and hyphens';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _surnameController,
                            decoration: const InputDecoration(
                              labelText: 'Surname',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Introduce your surname';
                              }
                              if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s-]+$')
                                  .hasMatch(value)) {
                                return 'The surname can only contain letters, spaces and hyphens';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Introduce your email address';
                              }
                              if (!RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                  .hasMatch(value)) {
                                return 'Introduce a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
                                  });
                                },
                              ),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Introduce a password'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Repeat your password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible; // Toggle visibility
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) return 'Repeat your password';
                              if (value != _passwordController.text) {
                                return 'The passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(67, 160, 71, 1),
                              minimumSize: const Size(
                                  double.infinity, 50), // Botón ancho
                            ),
                            child: const Text('Register', style: TextStyle(fontSize: 18, color: Colors.white),),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
