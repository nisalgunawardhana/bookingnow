import 'package:flutter/material.dart';
import '../services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool isAuthenticated = false;
  late String token;
  late ApiService apiService;

  AuthProvider() {
    // Initialize with an empty token first
    apiService = ApiService('');
    init();
  }

  Future<void> init() async {
    token = await getToken();
    // print('Token: $token');
    if (token.isNotEmpty) {
      isAuthenticated = true;
      apiService = ApiService(token);
    }
    notifyListeners();
  }

  Future<void> login(String email, String password, String deviceName) async {
    try {
      token = await apiService.login(email, password, deviceName);
      setToken(token);
      isAuthenticated = true;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logOut() async {
    try {
      token = await getToken();
      await apiService.logout(token);
      setToken('');
      isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      token = await getToken();
      await apiService.changePassword(token, oldPassword, newPassword);
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fatchuser() async {
    try {
      token = await getToken();
      final userDetails = await apiService.fatchUser(token);
      return userDetails;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    // print('Token saved: $token');
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      await apiService.signUp(name, email, password);
    } catch (error) {
      rethrow;
    }
  }

  //add user other details
  Future<void> addUserDetails(Map<String, dynamic> userDetails) async {
    try {
      token = await getToken();
      await apiService.addUserDetails(token, userDetails);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  /*------------------------------ Appointment -----------

  */
  //get all appointments
  Future<List<Map<String, dynamic>>> getAppointments() async {
    try {
      // Fetch token
      token = await getToken();
      final appointments = await apiService.getAppointments(token);
      return appointments;
    } catch (error) {
      rethrow;
    }
  }

  //delete appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      token = await getToken();
      await apiService.deleteAppointment(token, appointmentId);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  //fatch doctor
  Future<List<Map<String, dynamic>>> fatchDoctor() async {
    try {
      token = await getToken();
      final doctors = await apiService.fatchDoctors(token);
      return doctors;
    } catch (error) {
      rethrow;
    }
  }

  //fatch doctor availability
  Future<List<Map<String, dynamic>>> fatchDoctorAvailability(
      String _selectedDoctorId, String s) async {
    try {
      token = await getToken();
      final doctorAvailability =
          await apiService.fatchDoctorAvailability(token, _selectedDoctorId, s);
      return doctorAvailability;
    } catch (error) {
      rethrow;
    }
  }

  //submit appointment
  Future<void> addAppointment(String id, String date, String time,
      String remark, String paymentType, String amount, String type) async {
    try {
      token = await getToken();
      await apiService.addAppointment(
          token, id, date, time, remark, paymentType, amount, type);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
