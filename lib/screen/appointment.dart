import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../component/bottomnavbar.dart';
import '../const/color.dart';
import '../providers/authProvider.dart';

class Schedule extends StatefulWidget {
  final String initialFilter;
  const Schedule({super.key, this.initialFilter = 'All'});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  late Future<List<Map<String, dynamic>>> bookings;
  List<Map<String, dynamic>> initialBookings = [];
  String selectedStatus = 'All';
  AuthProvider authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    bookings = authProvider.getAppointments().then((data) {
      initialBookings = data;
      return data;
    });
    selectedStatus = widget.initialFilter;
  }

  void updateFilter(String status) {
    setState(() {
      selectedStatus = status;
    });
  }

  Color getStatusColor(String status) {
    if (status.toLowerCase() == 'Completed') {
      return kPendingColor;
    } else if (status.toLowerCase() == 'approved') {
      return kBookingNowColor;
    } else if (status.toLowerCase() == 'pending') {
      return kDueColor;
    } else {
      return Colors.black;
    }
  }

  void refreshBookings() {
    setState(() {
      bookings = authProvider.getAppointments().then((data) {
        initialBookings = data;
        return data;
      });
    });
  }

  void deleteBooking(int appointmentId) {
    authProvider.deleteAppointment(appointmentId.toString()).then((_) {
      setState(() {
        initialBookings.removeWhere(
            (booking) => booking['appointment_id'] == appointmentId);
      });
      refreshBookings();
      //alert
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: kSuccessColor,
          content: Text('Booking deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      // Handle delete error (Optional: show a message)
      debugPrint('Delete failed');
    });
  }

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, int bookingId) async {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete Booking'),
          content: const Text('Are you sure you want to delete this booking?'),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                deleteBooking(bookingId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: const Text('Schedule'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => updateFilter('All'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selectedStatus == 'All'
                          ? kButtonColordark
                          : Colors.transparent,
                      side: const BorderSide(color: kButtonColordark),
                    ),
                    child: Text(
                      'All',
                      style: TextStyle(
                        color: selectedStatus == 'All'
                            ? kTextLightColor
                            : kButtonColordark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => updateFilter('Pending'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selectedStatus == 'Pending'
                          ? kButtonColordark
                          : Colors.transparent,
                      side: const BorderSide(color: kButtonColordark),
                    ),
                    child: Text(
                      'Pending',
                      style: TextStyle(
                        color: selectedStatus == 'Pending'
                            ? kTextLightColor
                            : kButtonColordark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => updateFilter('Approved'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selectedStatus == 'Approved'
                          ? kButtonColordark
                          : Colors.transparent,
                      side: const BorderSide(color: kButtonColordark),
                    ),
                    child: Text(
                      'Approved',
                      style: TextStyle(
                          color: selectedStatus == 'Approved'
                              ? kTextLightColor
                              : kButtonColordark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => updateFilter('Completed'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selectedStatus == 'Completed'
                          ? kButtonColordark
                          : Colors.transparent,
                      side: const BorderSide(color: kButtonColordark),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                          color: selectedStatus == 'Completed'
                              ? kTextLightColor
                              : kButtonColordark),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: bookings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Loading indicator
                  } else if (snapshot.hasError) {
                    debugPrint('Error: ${snapshot.error}');
                    return const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Something went wrong.',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    );
                  } else if (snapshot.hasData) {
                    List<Map<String, dynamic>> filteredBookings =
                        initialBookings.where((booking) {
                      if (selectedStatus == 'All') {
                        return true;
                      }
                      return booking['status'] != null &&
                          booking['status'].toString().toLowerCase() ==
                              selectedStatus.toLowerCase();
                    }).toList();

                    if (filteredBookings.isEmpty) {
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
                            Text(
                              'No $selectedStatus appointments found',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];

                        return Card(
                          color: kPropertyCardColor,
                          child: ListTile(
                            title: Text(
                                'Booking Id: ${booking['id']?.toString() ?? 'N/A'}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(booking['doctor_name']?.toString() ??
                                    'Unknown Doctor'),
                                const SizedBox(height: 5),
                                Text(
                                    'Date: ${booking['appointment_date'] ?? 'N/A'}'),
                                Text(
                                    'Time: ${booking['appointment_time'] ?? 'N/A'}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  booking['status']?.toString() ?? 'Unknown',
                                  style: TextStyle(
                                    color: getStatusColor(
                                        booking['status']?.toString() ?? ''),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (booking['status']?.toLowerCase() ==
                                    'pending')
                                  IconButton(
                                    icon: const Icon(CupertinoIcons.delete,
                                        color: Colors.black),
                                    onPressed: () =>
                                        showDeleteConfirmationDialog(
                                            context,
                                            booking['appointment_id'] is int
                                                ? booking['appointment_id']
                                                : int.parse(
                                                    booking['appointment_id']
                                                        .toString())),
                                  ),
                              ],
                            ),
                            onTap: () {
                              // Navigate to the booking detail page (if needed)
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No bookings found'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Bottomnavbar(currentIndex: 1),
    );
  }
}
