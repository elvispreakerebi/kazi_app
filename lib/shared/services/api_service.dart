import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/backend.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _jwt;

  void setToken(String? token) {
    _jwt = token;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await http.post(
      Uri.parse('$convexBackend$path'),
      headers: {
        'Content-Type': 'application/json',
        if (_jwt != null) 'Authorization': 'Bearer $_jwt',
        ...?headers,
      },
      body: jsonEncode(body),
    );
    if (response.statusCode >= 400)
      throw Exception('API error: ${response.body}');
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await http.get(
      Uri.parse('$convexBackend$path'),
      headers: {
        'Content-Type': 'application/json',
        if (_jwt != null) 'Authorization': 'Bearer $_jwt',
        ...?headers,
      },
    );
    if (response.statusCode >= 400)
      throw Exception('API error: ${response.body}');
    return jsonDecode(response.body);
  }

  // Auth/login convenience method
  Future<Map<String, dynamic>> login(String email, String password) async {
    return post(
      '/api/auth/login-account',
      body: {'email': email, 'password': password},
    );
  }

  // Fetch current profile (GET -- adjust endpoint as needed)
  Future<Map<String, dynamic>> fetchUserProfile() async {
    return get('/api/teacher/details');
  }

  // Logout just clears the jwt
  void logout() => setToken(null);
}
