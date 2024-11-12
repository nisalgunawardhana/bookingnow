import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class LoginResult {
  final String? token;
  final String? error;

  LoginResult({this.token, this.error});
}

class ApiService {
  String? token;

  ApiService(String s, {this.token});
//add ur backend url
  final String baseUrl = 'http://192.168.1.17:8000/api';

/*-----------------User Actions -----------------
  *login
  *logout
  *changePassword
  *fatchUser
  */

//login api
  Future<String> login(String email, String password, String deviceName) async {
    String uri = '$baseUrl/login';

    final response = await http.post(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_name': deviceName,
      }),
    );

    if (response.statusCode == 422) {
      final body = jsonDecode(response.body);
      if (body.containsKey('errors')) {
        final errors = body['errors'];
        String errorMessage = '';

        if (errors.containsKey('password')) {
          errorMessage = errors['password'][0];
        } else if (errors.containsKey('email')) {
          errorMessage = errors['email'][0];
        }
        throw Exception(errorMessage);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } else if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      token = body;
      // print('Token: $token');
      return token!;
    } else {
      throw Exception(
          'Login failed: ${response.statusCode} - ${response.body}');
    }
  }

//logout api
  Future<void> logout(String token) async {
    if (token.isEmpty) {
      throw Exception('No active token. Cannot logout.');
    }

    String uri = '$baseUrl/logout';

    final response = await http.post(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    // print(
    //     'Logout response: ${response.statusCode} - ${response.body}-{$token}');

    if (response.statusCode != 200) {
      throw Exception('Logout failed');
    }
  }

  //change password api

  Future<void> changePassword(
      String token, String oldPassword, String newPassword) async {
    String uri = '$baseUrl/changepassword';

    final response = await http.post(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 422) {
      final body = jsonDecode(response.body);
      if (body.containsKey('errors')) {
        final errors = body['errors'];
        String errorMessage = '';

        if (errors.containsKey('old_password')) {
          errorMessage = errors['old_password'][0];
        } else if (errors.containsKey('new_password')) {
          errorMessage = errors['new_password'][0];
        }
        throw Exception(errorMessage);
      } else {
        throw Exception('Change password failed: ${response.body}');
      }
    } else if (response.statusCode != 200) {
      throw Exception(
          'Change password failed: ${response.statusCode} - ${response.body}');
    }
  }

//user api
  Future<Map<String, dynamic>> fatchUser(String token) async {
    String uri = '$baseUrl/user';

    final response = await http.get(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Return as map
    } else {
      throw Exception(
          'Failed to fetch user: ${response.statusCode} - ${response.body}');
    }
  }

//signup api
  Future<void> signUp(String name, String email, String password) async {
    String uri = '$baseUrl/signup';

    final response = await http.post(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body.containsKey('message')) {
        // print(body['message']);
      }
      return;
    } else if (response.statusCode == 409) {
      throw Exception('Account already exists');
    } else if (response.statusCode == 422) {
      throw Exception('invalid email');
    } else if (response.statusCode == 500) {
      throw Exception('Account creation failed: ${response.body}');
    } else {
      throw Exception(
          'Sign Up failed: ${response.statusCode} - ${response.body}');
    }
  }

  //add user details
  Future<void> addUserDetails(
      String token, Map<String, dynamic> userDetails) async {
    String uri = '$baseUrl/addUserDetails';

    final response = await http.post(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode(userDetails),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body.containsKey('message')) {
        // print(body['message']);
      }
      return;
    } else if (response.statusCode == 422) {
      throw Exception('Invalid user details');
    } else if (response.statusCode == 500) {
      throw Exception('Failed to add user details: ${response.body}');
    } else {
      throw Exception(
          'Add User Details failed: ${response.statusCode} - ${response.body}');
    }
  }

  /* -------------Appointment ---------------------- 
  *fetch Appointments
  *add Appointment
  *fetchAppointment
  *update Appointment
  *delete Appointment
  */

  Future<List<Map<String, dynamic>>> getAppointments(String token) async {
    String uri = '$baseUrl/bookings';

    try {
      final response = await http.get(
        Uri.parse(uri),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      // Log the raw response body for debugging

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            // Parse the JSON response
            Map<String, dynamic> jsonResponse = jsonDecode(response.body);

            // Extract the 'data' field, which contains the list of bookings
            List bookings = jsonResponse['data'];

            // Ensure all elements in bookings are maps
            List<Map<String, dynamic>> bookingsList = bookings.map((booking) {
              if (booking is Map<String, dynamic>) {
                return booking;
              } else {
                throw const FormatException('Invalid booking format');
              }
            }).toList();

            // Return the list as a List<Map<String, dynamic>>
            return bookingsList;
          } catch (jsonError) {
            throw FormatException(
                'Error parsing JSON: ${jsonError.toString()}');
          }
        } else {
          throw Exception('API returned an empty response');
        }
      } else {
        throw Exception(
            'Failed to fetch bookings: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Error fetching appointments: $error');
    }
  }

  Future<void> createAppointment(
      String token, Map<String, dynamic> appointment) async {
    String uri = '$baseUrl/bookings';

    final response = await http.post(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode(appointment),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body.containsKey('message')) {
        // print(body['message']);
      }
      return;
    } else if (response.statusCode == 422) {
      throw Exception('Invalid appointment details');
    } else if (response.statusCode == 500) {
      throw Exception('Failed to add appointment: ${response.body}');
    } else {
      throw Exception(
          'Add Appointment failed: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchAppointment(
      String token, String appointmentId) async {
    String uri = '$baseUrl/bookings/$appointmentId';

    final response = await http.get(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Return as map
    } else {
      throw Exception(
          'Failed to fetch appointment: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> updateAppointment(String token, String appointmentId,
      Map<String, dynamic> appointment) async {
    String uri = '$baseUrl/bookings/$appointmentId';

    final response = await http.put(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode(appointment),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body.containsKey('message')) {
        // print(body['message']);
      }
      return;
    } else if (response.statusCode == 422) {
      throw Exception('Invalid appointment details');
    } else if (response.statusCode == 500) {
      throw Exception('Failed to update appointment: ${response.body}');
    } else {
      throw Exception(
          'Update Appointment failed: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteAppointment(String token, String appointmentId) async {
    String uri = '$baseUrl/bookings/$appointmentId';

    final response = await http.delete(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body.containsKey('message')) {
        // print(body['message']);
      }
      return;
    } else if (response.statusCode == 422) {
      throw Exception('Invalid appointment details');
    } else if (response.statusCode == 500) {
      throw Exception('Failed to delete appointment: ${response.body}');
    } else {
      throw Exception(
          'Delete Appointment failed: ${response.statusCode} - ${response.body}');
    }
  }

  //fatch all doctors
  Future<List<Map<String, dynamic>>> fatchDoctors(String token) async {
    String uri = '$baseUrl/doctors';

    final response = await http.get(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          // Parse the JSON response
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          // Extract the 'data' field, which contains the list of doctors
          List doctors = jsonResponse['data'];

          // Ensure all elements in doctors are maps
          List<Map<String, dynamic>> doctorsList = doctors.map((doctor) {
            if (doctor is Map<String, dynamic>) {
              return doctor;
            } else {
              throw const FormatException('Invalid doctor format');
            }
          }).toList();

          // Return the list as a List<Map<String, dynamic>>
          return doctorsList;
        } catch (jsonError) {
          throw FormatException('Error parsing JSON: ${jsonError.toString()}');
        }
      } else {
        throw Exception('API returned an empty response');
      }
    } else {
      throw Exception(
          'Failed to fetch doctors: ${response.statusCode} - ${response.body}');
    }
  }

  //fatch doctor availability
  Future<List<Map<String, dynamic>>> fatchDoctorAvailability(
      String token, String _selectedDoctorId, String date) async {
    String uri = '$baseUrl/doctor-availability';

    final response = await http.post(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode({
        'doctor_id': _selectedDoctorId,
        'date': date,
      }),
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          // Parse the JSON response
          Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          // Extract the 'data' field, which contains the list of availability
          List availability = jsonResponse['data'];

          // Ensure all elements in availability are maps
          List<Map<String, dynamic>> availabilityList =
              availability.map((availability) {
            if (availability is Map<String, dynamic>) {
              return availability;
            } else {
              throw const FormatException('Invalid availability format');
            }
          }).toList();

          // Return the list as a List<Map<String, dynamic>>
          return availabilityList;
        } catch (jsonError) {
          throw FormatException('Error parsing JSON: ${jsonError.toString()}');
        }
      } else {
        throw Exception('API returned an empty response');
      }
    } else {
      throw Exception(
          'Failed to fetch availability: ${response.statusCode} - ${response.body}');
    }
  }

  //addAppointment
  Future addAppointment(String token, String id, String date, String time,
      String remark, String paymentType, String amount, String type) async {
    String uri = '$baseUrl/bookings';

    final response = await http.post(
      Uri.parse(uri),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode({
        'doctor_id': id,
        'date': date,
        'time': time,
        'remarks': remark,
        'payment_type': paymentType,
        'amount': amount,
        'type': type,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ignore: unused_local_variable
      final body = jsonDecode(response.body);

      return;
    } else if (response.statusCode == 422) {
      throw Exception('Invalid appointment details');
    } else if (response.statusCode == 500) {
      throw Exception('Failed to add appointment: ${response.body}');
    } else {
      throw Exception(
          'Add Appointment failed: ${response.statusCode} - ${response.body}');
    }
  }
}
