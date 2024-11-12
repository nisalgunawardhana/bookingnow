// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../component/bottomnavbar.dart';
import '../const/color.dart';
import '../providers/authProvider.dart';
import 'loginpage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';
  String _name = '';
  String _email = '';
  String _profilePhotoUrl = '';

  @override
  void initState() {
    super.initState();
    AuthProvider().init();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userDetails = await AuthProvider().fatchuser();
      setState(() {
        _name = userDetails['name'] ?? '';
        _email = userDetails['email'] ?? '';
        _profilePhotoUrl = userDetails['pro_pic'] != null
            ? 'http://127.0.0.1:8001/storage/profile/${userDetails['pro_pic']}'
            : '';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load user details';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kErrorColor,
            content: Row(
              children: [
                Icon(Icons.error, color: kPrimaryColor),
                SizedBox(width: 10),
                Text(
                  'Failed to load user details',
                  style: TextStyle(color: kPrimaryColor),
                ),
              ],
            ),
          ),
        );
      });
    }
  }

  void _showConfirmDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Confirm Password Change'),
          content: const Text('Are you sure you want to change your password?'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the alert
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the alert
                _changePassword();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _changePassword() {
    if (_currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: kErrorColor,
        content: Text(
          'Please enter your current password',
          style: TextStyle(color: kTextLightColor),
        ),
      ));
      return;
    }
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: kErrorColor,
        content: Text(
          'Please enter a new password',
          style: TextStyle(color: kTextLightColor),
        ),
      ));
      return;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: kErrorColor,
        content: Text(
          'Password must be at least 6 characters',
          style: TextStyle(color: kTextLightColor),
        ),
      ));
      return;
    }
    if (_currentPasswordController.text == _passwordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: kErrorColor,
        content: Text(
          'Current password and new password cannot be the same',
          style: TextStyle(color: kTextLightColor),
        ),
      ));
      return;
    }

    AuthProvider()
        .changePassword(
            _currentPasswordController.text, _passwordController.text)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kSuccessColor,
          content: Text(
            'Password changed successfully',
            style: TextStyle(color: kTextLightColor),
          ),
        ),
      );
      _currentPasswordController.clear();
      _passwordController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kErrorColor,
          content: Text(
            'Current password is incorrect',
            style: TextStyle(color: kTextLightColor),
          ),
        ),
      );
    });
  }

  //image pick and save to database

  // Future<void> _imagepicker() async {
  //   try {
  //     // Implement image picker functionality here
  //     final pickedFile = await AuthProvider().pickImage();
  //     if (pickedFile != null) {
  //       // Save the picked image to the database
  //       await AuthProvider().saveImage(pickedFile);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           backgroundColor: kSuccessColor,
  //           content: Text(
  //             'Image picked and saved successfully',
  //             style: TextStyle(color: kSecondaryColor),
  //           ),
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           backgroundColor: kErrorColor,
  //           content: Text(
  //             'No image selected',
  //             style: TextStyle(color: kSecondaryColor),
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: kErrorColor,
  //         content: Text(
  //           'Failed to pick and save image: $e',
  //           style: const TextStyle(color: kSecondaryColor),
  //         ),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await AuthProvider().logOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LogInpage(),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: kSuccessColor,
                    content: Text('Logout successful',
                        style: TextStyle(color: kTextLightColor)),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: kErrorColor,
                    content: Text('Logout failed: $e',
                        style: const TextStyle(color: kTextLightColor)),
                  ),
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(top: 20),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _profilePhotoUrl.isNotEmpty
                              ? NetworkImage(_profilePhotoUrl)
                              : null,
                          backgroundColor: _profilePhotoUrl.isEmpty
                              ? Colors.grey
                              : Colors.transparent,
                          child: _profilePhotoUrl.isEmpty
                              ? const Icon(Icons.person,
                                  size: 60, color: Colors.white)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: MediaQuery.of(context).size.width / 2 - 85,
                        child: IconButton(
                          icon: const Icon(
                            CupertinoIcons.pencil_circle_fill,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50),
              const Text(
                'Personal Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(text: _name),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(text: _email),
              ),
              const SizedBox(height: 10),
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: _showConfirmDialog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: kButtonColordark,
                      ),
                      child: const Text('Change Password',
                          style: TextStyle(
                            color: kTextLightColor,
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Bottomnavbar(currentIndex: 3),
    );
  }
}
