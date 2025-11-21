import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  // Update this to your backend URL
  static const String baseUrl = 'http://10.0.2.2:3000/api/admin';
  // For Android emulator use: 'http://10.0.2.2:3000/api/admin'
  // For real device use your computer's IP: 'http://192.168.x.x:3000/api/admin'

  // Get network overview statistics
  Future<Map<String, dynamic>> getNetworkOverview() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/overview'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data'];
        }
      }
      throw Exception('Failed to load network overview');
    } catch (e) {
      print('Error fetching network overview: $e');
      rethrow;
    }
  }

  // Get all anganwadi centers with statistics
  Future<List<Map<String, dynamic>>> getAnganwadiCenters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/centers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['centers']);
        }
      }
      throw Exception('Failed to load centers');
    } catch (e) {
      print('Error fetching centers: $e');
      rethrow;
    }
  }

  // Get detailed report for a specific center
  Future<Map<String, dynamic>> getCenterReport(String anganwadiId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/centers/$anganwadiId/report'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['report'];
        }
      }
      throw Exception('Failed to load center report');
    } catch (e) {
      print('Error fetching center report: $e');
      rethrow;
    }
  }
}