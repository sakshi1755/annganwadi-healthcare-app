// lib/services/api_service.dart - REPLACE THE ENTIRE FILE
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static const String baseUrl = 'http://your-backend-url.com/api'; // Replace with your backend URL
  
  // Flag to enable/disable dummy mode
  static const bool isDummyMode = true; // Set to false when using real backend
  
  // Get current user's access token
  static Future<String?> _getAccessToken() async {
    if (isDummyMode) {
      // Return dummy token for testing
      return 'dummy_access_token';
    }
    
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken;
  }

  // Make authenticated HTTP request
  static Future<http.Response> _makeAuthenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    if (isDummyMode) {
      // Return dummy responses for testing without hitting backend
      return _getDummyResponse(method, endpoint, body);
    }

    final token = await _getAccessToken();
    if (token == null) {
      throw Exception('No access token found');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final url = Uri.parse('$baseUrl$endpoint');

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'POST':
        return await http.post(
          url,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
      case 'PUT':
        return await http.put(
          url,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
      case 'DELETE':
        return await http.delete(url, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // Generate dummy responses for testing
  static http.Response _getDummyResponse(String method, String endpoint, Map<String, dynamic>? body) {
    String responseBody = '';
    int statusCode = 200;

    if (endpoint.contains('/children') && method == 'GET') {
      responseBody = json.encode([
        {
          'id': 'dummy_child_1',
          '_id': 'dummy_child_1',
          'name': 'Test Child 1',
          'dob': '2020-01-15',
          'gender': 'Male',
          'guardian': 'Test Guardian 1',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'dummy_child_2',
          '_id': 'dummy_child_2',
          'name': 'Test Child 2',
          'dob': '2019-06-20',
          'gender': 'Female',
          'guardian': 'Test Guardian 2',
          'created_at': DateTime.now().toIso8601String(),
        }
      ]);
    } else if (endpoint.contains('/children') && method == 'POST') {
      responseBody = json.encode({
        'success': true,
        'message': 'Child created successfully',
        'child': {
          'id': 'dummy_child_${DateTime.now().millisecondsSinceEpoch}',
          '_id': 'dummy_child_${DateTime.now().millisecondsSinceEpoch}',
          'name': body?['name'] ?? 'New Child',
          'dob': body?['dob'] ?? '2020-01-01',
          'gender': body?['gender'] ?? 'Male',
          'guardian': body?['guardian'] ?? 'Guardian',
          'created_at': DateTime.now().toIso8601String(),
        }
      });
    } else if (endpoint.contains('/dashboard/stats')) {
      responseBody = json.encode({
        'totalChildren': 25,
        'healthyChildren': 20,
        'atRiskChildren': 3,
        'severelyMalnourishedChildren': 2,
        'recentMeasurements': 15
      });
    } else if (endpoint.contains('/centers') && method == 'GET') {
      responseBody = json.encode([
        {
          'id': 'center_1',
          'name': 'Main Anganwadi Center',
          'location': 'Central District',
          'created_at': DateTime.now().toIso8601String(),
        }
      ]);
    } else if (endpoint.contains('/auth/me')) {
      responseBody = json.encode({
        'id': 'dummy_user_id',
        'email': 'dummy@example.com',
        'name': 'Dummy User',
        'role': 'Anganwadi Worker',
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      // Default success response
      responseBody = json.encode({
        'success': true,
        'message': 'Operation completed successfully',
        'data': body ?? {}
      });
    }

    return http.Response(responseBody, statusCode);
  }

  // Auth APIs
  static Future<Map<String, dynamic>> login({
    required String supabaseUserId,
    required String email,
    required String name,
    required String role,
  }) async {
    if (isDummyMode) {
      // Return dummy login response
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return {
        'success': true,
        'user': {
          'id': 'dummy_user_${DateTime.now().millisecondsSinceEpoch}',
          'supabaseUserId': supabaseUserId,
          'email': email,
          'name': name,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
        }
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'supabaseUserId': supabaseUserId,
        'email': email,
        'name': name,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _makeAuthenticatedRequest('GET', '/auth/me');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get user: ${response.body}');
    }
  }

  // Child APIs
  static Future<Map<String, dynamic>> createChild({
    required String name,
    required String dob,
    required String gender,
    required String guardian,
  }) async {
    final response = await _makeAuthenticatedRequest('POST', '/children', body: {
      'name': name,
      'dob': dob,
      'gender': gender,
      'guardian': guardian,
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create child: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getChildren() async {
    final response = await _makeAuthenticatedRequest('GET', '/children');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to get children: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getChild(String childId) async {
    final response = await _makeAuthenticatedRequest('GET', '/children/$childId');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get child: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateChild({
    required String childId,
    required String name,
    required String dob,
    required String gender,
    required String guardian,
  }) async {
    final response = await _makeAuthenticatedRequest('PUT', '/children/$childId', body: {
      'name': name,
      'dob': dob,
      'gender': gender,
      'guardian': guardian,
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update child: ${response.body}');
    }
  }

  // Measurement APIs
  static Future<Map<String, dynamic>> addMeasurement({
    required String childId,
    required double height,
    required double weight,
    int? aiPrediction,
    String? photoUrl,
    String? notes,
  }) async {
    final response = await _makeAuthenticatedRequest(
      'POST', 
      '/children/$childId/measurements', 
      body: {
        'height': height,
        'weight': weight,
        'aiPrediction': aiPrediction,
        'photoUrl': photoUrl,
        'notes': notes,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add measurement: ${response.body}');
    }
  }

  // Dashboard APIs
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _makeAuthenticatedRequest('GET', '/dashboard/stats');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get dashboard stats: ${response.body}');
    }
  }

  // Centers APIs (for Admin)
  static Future<Map<String, dynamic>> createCenter({
    required String name,
    required String location,
  }) async {
    final response = await _makeAuthenticatedRequest('POST', '/centers', body: {
      'name': name,
      'location': location,
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create center: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getCenters() async {
    final response = await _makeAuthenticatedRequest('GET', '/centers');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to get centers: ${response.body}');
    }
  }
}