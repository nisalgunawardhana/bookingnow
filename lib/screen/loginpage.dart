// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../const/color.dart';

import '../providers/AuthProvider.dart';

import 'package:provider/provider.dart';

class LogInpage extends StatefulWidget {
  const LogInpage({super.key});

  @override
  _LogInpageState createState() => _LogInpageState();
}

class _LogInpageState extends State<LogInpage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';
  bool _isObscure = true;
  late String deviceName;

  @override
  void initState() {
    super.initState();
    getdeviceName();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var children = [
      // Email Input
      Container(
        color: kFormColor,
        // Your desired background color
        child: TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Email',
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kFormBorderColor, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: kFormdefaultBorderColor, width: 1.0),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
      ),
      const SizedBox(height: 16),

      // Password Input
      Container(
        color: kFormColor,
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return TextFormField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Password',
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: kFormBorderColor, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: kFormdefaultBorderColor, width: 1.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
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
            );
          },
        ),
      ),

      const SizedBox(height: 30),

      // Login Button
      ElevatedButton(
        onPressed: () {
          submit();
        },
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: kButtonColordark),
        child: const Text(
          'Login',
          style: TextStyle(
            fontSize: 16,
            color: kTextLightColor,
          ),
        ),
      ),
      const SizedBox(height: 30),

      //Forgot Password Button

      TextButton(
        onPressed: () {
          // Navigate to Forgot Password page
          Navigator.of(context).pushNamed('/forgot-password');
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 16,
            color: kTextColor,
          ),
        ),
      ),

      // Switch to Sign Up
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Don\'t have an account? ',
            style: TextStyle(
              fontSize: 16,
              color: kTextColor,
            ),
          ),
          const SizedBox(width: 1),
          TextButton(
            onPressed: () {
              // Navigate to Sign Up page
              Navigator.of(context).pushNamed('/signup');
            },
            child: const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 16,
                color: kTextColor, // Use the same color for consistency
                fontWeight: FontWeight
                    .bold, // Optional: to highlight the clickable text
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 3),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                // Image section
                Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 40),
                  child: Image.asset(
                    'images/logo.png',
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 30),
                // Title
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: children,
                  ),
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

    final AuthProvider provider =
        Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await provider.login(
        _emailController.text,
        _passwordController.text,
        deviceName,
      );

      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (error) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: kErrorColor,
            content: Text('Incorrect email or password')),
      );
    }
  }

  Future<void> getdeviceName() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        setState(() {
          deviceName = build.model;
        });
      } else if (Platform.isIOS) {
        var build = await deviceInfoPlugin.iosInfo;
        setState(() {
          deviceName = build.name;
        });
      }
    } on PlatformException {
      setState(() {
        deviceName = 'Failed to get device name';
      });
    }
  }
}
