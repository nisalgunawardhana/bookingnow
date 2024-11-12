import 'package:bookingnow/screen/addappointment.dart';
import 'package:bookingnow/screen/appointment.dart';
import 'package:bookingnow/screen/doctors.dart';
import 'package:bookingnow/screen/homepage.dart';
import 'package:bookingnow/screen/loginpage.dart';
import 'package:bookingnow/screen/onboarding.dart';
import 'package:bookingnow/screen/profile.dart';
import 'package:bookingnow/screen/signup.dart';
import 'package:flutter/material.dart';
import '/providers/AuthProvider.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: Consumer<AuthProvider>(
        // Use Consumer to access AuthProvider
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'Welcome to Flutter',
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) {
                return authProvider.isAuthenticated
                    ? const Homepage()
                    : const Onboarding();
              },
              '/login': (context) => const LogInpage(),
              '/home': (context) => const Homepage(),
              '/signup': (context) => const SignUpPage(),
              '/profile': (context) => const Profile(),
              '/addappointment': (context) => AddAppointmentPage(),
              '/appointment': (context) => const Schedule(),
              '/doctors': (context) => DoctorListScreen(),
            },
          );
        },
      ),
    );
  }
}
