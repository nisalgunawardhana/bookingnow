import 'package:bookingnow/const/color.dart';
import 'package:bookingnow/screen/appointment.dart';
import 'package:bookingnow/screen/doctors.dart';
import 'package:bookingnow/screen/homepage.dart';
import 'package:bookingnow/screen/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Bottomnavbar extends StatelessWidget {
  final int currentIndex;

  const Bottomnavbar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Schedule()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoctorListScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Profile()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: kAppBarColor,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.calendar_today),
          label: 'Booking',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_2),
          label: 'Doctors',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: kButtonColordark,
      unselectedItemColor: kUnSelectedItemColor,
      onTap: (index) => _onItemTapped(context, index),
    );
  }
}
