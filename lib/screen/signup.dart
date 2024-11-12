// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';

import '../const/color.dart';
import '../providers/authProvider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 40),
                  child: Image.asset(
                    'images/logo.png',
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                // Title
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Sign Up Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      //Name
                      // Name Input
                      Container(
                        color: kFormColor,
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Name',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: kFormBorderColor,
                                  width: 2.0), // Change to your desired color
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: kFormdefaultBorderColor,
                                  width: 1.0), // Default border color
                            ),
                          ),
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      const SizedBox(height: 16),

// Email Input
                      Container(
                        color: kFormColor,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: kFormBorderColor,
                                  width: 2.0), // Change to your desired color
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: kFormdefaultBorderColor,
                                  width: 1.0), // Default border color
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Input
                      Container(
                        color: kFormColor,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: kFormBorderColor,
                                  width: 2.0), // Change to your desired color
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: kFormdefaultBorderColor,
                                  width: 1.0), // Default border color
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      //Confirm Password Input
                      // TextFormField(
                      //   controller: _confirmPasswordController,
                      //   obscureText: true,
                      //   decoration: const InputDecoration(
                      //     border: OutlineInputBorder(),
                      //     labelText: 'Confirm Password',
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please confirm your password';
                      //     }
                      //     if (value != _passwordController.text) {
                      //       return 'Passwords do not match';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      const SizedBox(height: 30),

                      // Sign Up Button
                      ElevatedButton(
                        onPressed: () {
                          submit();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: kButtonColordark,
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            color: kTextLightColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                // Navigate to Login Page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 16,
                        color: kTextColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              kTextColor, // Use the same color for consistency
                          fontWeight: FontWeight
                              .bold, // Optional: to highlight the clickable text
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submit() async {
    final form = _formKey.currentState;

    if (!form!.validate()) {
      return;
    }

    final AuthProvider provider = AuthProvider();

    try {
      await provider.signUp(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      // Navigate to the home page or another page on successful sign-up
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SignUp failed: $error')),
      );
    }
  }
}
