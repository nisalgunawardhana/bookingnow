import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../component/bottomnavbar.dart';
import '../const/color.dart';
import '../providers/authProvider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  AuthProvider authProvider = AuthProvider();
  late Future<List<dynamic>> _doctorListFuture;
  List<dynamic> _doctorList = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  void _fetchDoctors() {
    final authProvider = AuthProvider(); // Assuming AuthProvider instance
    _doctorListFuture = authProvider.fatchDoctor();
    _doctorListFuture.then((doctors) {
      setState(() {
        _doctorList = doctors;
      });
    }).catchError((error) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching doctors: $error'),

          backgroundColor: kErrorColor, // Define this in your color constants
        ),
      );
      //print('Error fetching doctors: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.person_circle,
                    color: kTextDarkColor,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
            const Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Home',
                      style: TextStyle(
                        color: kTextDarkColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(
                CupertinoIcons.add,
                color: kTextDarkColor,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/addappointment');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 26),
              Card(
                color: kPrimaryDarkColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ListTile(
                      title: Text(
                        'Welcome to Medix',
                        style: TextStyle(
                          color: kTextLightColor,
                          fontSize: 30,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      subtitle: Text(
                        'Make your life healthier and happier',
                        style: TextStyle(
                          color: kTextLightColor,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Image.asset(
                      'images/image1.png',
                      height: 100,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2, // 2 cards per row
                crossAxisSpacing: 10, // Horizontal spacing between cards
                mainAxisSpacing: 10, // Vertical spacing between cards
                childAspectRatio: 1, // Makes the cards square
                physics:
                    const NeverScrollableScrollPhysics(), // Prevents scrolling inside the GridView
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/addappointment');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side:
                          const BorderSide(color: kPrimaryDarkColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(CupertinoIcons.calendar,
                              color: kPrimaryDarkColor, size: 40),
                          Text(
                            'Add Appointment',
                            style: TextStyle(
                                color: kPrimaryDarkColor, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          Icon(CupertinoIcons.add,
                              color: kPrimaryDarkColor, size: 16),
                        ],
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/doctors');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side:
                          const BorderSide(color: kPrimaryDarkColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(CupertinoIcons.person_2_fill,
                              color: kPrimaryDarkColor, size: 40),
                          Text(
                            'doctors',
                            style: TextStyle(
                                color: kPrimaryDarkColor, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          Icon(CupertinoIcons.eye_fill,
                              color: kPrimaryDarkColor, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Doctors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/doctors');
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FutureBuilder(
                future: _doctorListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Colors.black,
                          size: 20,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No doctors found',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _fetchDoctors();
                          },
                          child: const Text('Refresh'),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: List.generate(
                      _doctorList.length > 3 ? 3 : _doctorList.length,
                      (index) {
                        final doctor = _doctorList[index];
                        return Card(
                          color: kPropertyCardColor,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(doctor['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle:
                                Text(doctor['specialty'] ?? 'No specialty'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/addappointment',
                                  arguments: {
                                    'doctorId': doctor['id'],
                                    'doctorName': doctor['name'],
                                    'fee': doctor['channeling_fee'],
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kButtonColordark,
                              ),
                              child: const Text('Book Appointment',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Bottomnavbar(currentIndex: 0),
    );
  }
}
