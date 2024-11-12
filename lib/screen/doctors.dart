import 'package:bookingnow/const/color.dart';
import 'package:bookingnow/providers/authProvider.dart';
import 'package:flutter/material.dart';

import '../component/bottomnavbar.dart';

class DoctorListScreen extends StatefulWidget {
  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late Future<List<Map<String, dynamic>>> _doctorListFuture;
  List<Map<String, dynamic>> _doctorList = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _searchController.addListener(_filterDoctors);
  }

  void _fetchDoctors() {
    final authProvider = AuthProvider(); // Assuming AuthProvider instance
    _doctorListFuture = authProvider.fatchDoctor();
    _doctorListFuture.then((doctors) {
      setState(() {
        _doctorList = doctors;
        _filteredDoctors = doctors;
      });
    }).catchError((error) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching doctors: $error'),
          backgroundColor: kErrorColor, // Define this in your color constants
        ),
      );
    });
  }

  void _filterDoctors() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors = _doctorList.where((doctor) {
        final doctorName = doctor['name'].toLowerCase();
        return doctorName.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDoctors);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: const Text('Doctor List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search doctors',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  hintStyle: TextStyle(color: kTextColor),
                ),
                style: const TextStyle(color: kTextColor),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _doctorListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
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
                          onPressed: _fetchDoctors,
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: _filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _filteredDoctors[index];
                    return Card(
                      color: kPropertyCardColor,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(doctor['name'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(doctor['specialty'] ?? 'No specialty'),
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
                          child: const Text('Book Appointment',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kButtonColordark,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Bottomnavbar(currentIndex: 2),
    );
  }
}
