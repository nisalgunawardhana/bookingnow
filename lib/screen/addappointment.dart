import 'package:flutter/material.dart';
import '../component/bottomnavbar.dart';
import '../component/custom_picker.dart';
import '../const/color.dart';
import '../providers/authProvider.dart';

class AddAppointmentPage extends StatefulWidget {
  @override
  _AddAppointmentPageState createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  String? _selectedDoctor;
  String? selectedPropertyName;
  final AuthProvider _authProvider = AuthProvider();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _doctorFeesController = TextEditingController();
  List<Map<String, dynamic>> fatchDoctor = [];
  List<String> doctors = [];
  String? _selectedDoctorId = '';
  bool _isSubmitting = false;
  String? _selectedPaymentType;
  String? type;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && mounted) {
        setState(() {
          _selectedDoctorId = args['doctorId'].toString();
          _selectedDoctor = args['doctorName'];
          _doctorFeesController.text = args['fee'].toString();
          _doctorController.text = args['doctorName'];
        });
      }
    });
  }

  void _fetchDoctors() async {
    List<Map<String, dynamic>> doctorMaps = await _authProvider.fatchDoctor();
    setState(() {
      fatchDoctor = doctorMaps;
      doctors =
          doctorMaps.map((doctorMap) => doctorMap['name'] as String).toList();
      _selectedDoctor = doctors.isNotEmpty ? doctors.first : null;
    });
  }

  Future<List<Map<String, dynamic>>> fatchDoctorAvailability(
      String _selectedDoctorId, String date) async {
    try {
      return await _authProvider.fatchDoctorAvailability(
          _selectedDoctorId, _dateController.text);
    } catch (error) {
      rethrow;
    }
  }

  void validation() {
    if (_selectedDoctorId == null) {
      _showError('Please select a doctor.');
      return;
    }
    if (_dateController.text.isEmpty) {
      _showError('Please select a date.');
      return;
    }
    if (_timeController.text.isEmpty) {
      _showError('No Available time.');
      return;
    }

    _submitForm();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kErrorColor,
        content: Text(message),
      ),
    );
  }

  Future<void> _submitForm() async {
    try {
      await _authProvider.addAppointment(
        _selectedDoctorId!,
        _dateController.text,
        _timeController.text,
        _remarkController.text,
        _selectedPaymentType!,
        _doctorFeesController.text,
        type!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kSuccessColor,
          content: Text('Appointment booked successfully.'),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      _showError('Error booking appointment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: const Text('Add Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => CustomPicker.show(context, doctors, (value) {
                final selectedDoctor =
                    fatchDoctor.firstWhere((doctor) => doctor['name'] == value);
                setState(() {
                  _selectedDoctor = selectedDoctor['name'];
                  _selectedDoctorId = selectedDoctor['id'].toString();
                  _doctorFeesController.text =
                      selectedDoctor['channeling_fee'].toString();
                  _dateController.clear();
                  _timeController.clear();

                  // Update the doctor's name in the controller
                  _doctorController.text = _selectedDoctor ?? 'Select a doctor';
                });
              }),
              child: AbsorbPointer(
                child: TextField(
                  controller: _doctorController, // Use the single controller
                  decoration: InputDecoration(
                    labelText: 'Select Doctor',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Fetch available dates for the selected doctor
            GestureDetector(
              onTap: () async {
                if (_selectedDoctorId != null &&
                    _selectedDoctorId!.isNotEmpty) {
                  final availableDates = await fatchDoctorAvailability(
                      _selectedDoctorId!, _dateController.text);
                  if (availableDates.isNotEmpty) {
                    final uniqueDates = availableDates
                        .map((date) => date['available_date'].toString())
                        .toSet()
                        .toList();
                    showDatePicker(
                      context: context,
                      initialDate: uniqueDates.contains(
                              "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}")
                          ? DateTime.now()
                          : DateTime.parse(uniqueDates.first),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                      selectableDayPredicate: (DateTime date) {
                        return uniqueDates
                            .contains("${date.year}-${date.month}-${date.day}");
                      },
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            primaryColor: kPrimaryColor, // Set primary color
                            hintColor: kAppBarColor,
                            colorScheme: const ColorScheme.light(
                                primary: kPrimaryDarkColor),
                            buttonTheme: const ButtonThemeData(
                                textTheme: ButtonTextTheme.primary),
                          ),
                          child: child!,
                        );
                      },
                    ).then((pickedDate) async {
                      if (pickedDate != null) {
                        setState(() {
                          _dateController.text =
                              "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                          _timeController.clear();
                        });
                        final availableTimes = availableDates
                            .where((time) =>
                                time['available_date'] == _dateController.text)
                            .map((time) => time['available_time'].toString())
                            .toList();
                        if (availableTimes.isNotEmpty) {
                          CustomPicker.show(context, availableTimes, (value) {
                            setState(() {
                              _timeController.text = value;
                            });
                          });
                        } else {
                          _showError('No available times found.');
                        }
                      }
                    });
                  } else {
                    _showError('No available dates found.');
                  }
                } else {
                  _showError('Please select a doctor first.');
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fetch available times for the selected doctor and date
            GestureDetector(
              onTap: () async {
                if (_selectedDoctorId != null &&
                    _dateController.text.isNotEmpty) {
                  final availableTimes = await fatchDoctorAvailability(
                      _selectedDoctorId!, _dateController.text);
                  if (availableTimes.isNotEmpty) {
                    final selectedDateTimes = availableTimes
                        .where((time) =>
                            time['available_date'] == _dateController.text)
                        .map((time) => time['available_time'].toString())
                        .toList();
                    if (selectedDateTimes.isNotEmpty) {
                      CustomPicker.show(context, selectedDateTimes, (value) {
                        setState(() {
                          _timeController.text = value;
                        });
                      });
                    } else {
                      _showError(
                          'No available times found for the selected date.');
                    }
                  } else {
                    _showError('No available times found.');
                  }
                } else {
                  _showError('Please select a doctor and date first.');
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: 'Select Time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  readOnly: true,
                ),
              ),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _doctorFeesController,
              decoration: InputDecoration(
                labelText: 'Doctor Fees',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                filled: true,
                fillColor: Colors.white,
              ),
              readOnly: true,
            ),
            const Text(
              'Hint: Total amount is Doctor Fee + Channel Fee',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _remarkController,
              decoration: InputDecoration(
                labelText: 'Remark',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Type',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: kTextColor),
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Cash'),
                    leading: Radio(
                      value: 'Cash',
                      groupValue: _selectedPaymentType,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentType = value.toString();
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Card'),
                    leading: Radio(
                      value: 'Card',
                      groupValue: _selectedPaymentType,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentType = value.toString();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: kButtonColordark,
                ),
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        setState(() {
                          _isSubmitting = true;
                        });
                        type = 'pending';
                        validation();
                        setState(() {
                          _isSubmitting = false;
                        });
                      },
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(kTextLightColor))
                    : const Text('Book Now',
                        style: TextStyle(fontSize: 16, color: kTextLightColor)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Bottomnavbar(currentIndex: 1),
    );
  }
}
