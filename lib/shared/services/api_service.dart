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

  Future<dynamic> post(
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
    if (response.statusCode >= 400) {
      throw Exception('API error: ${response.body}');
    }
    // PATCH: handle List or Map JSON response
    final bodyRaw = response.body;
    final firstNonspace = bodyRaw.trimLeft().isNotEmpty
        ? bodyRaw.trimLeft()[0]
        : '{';
    if (firstNonspace == '[') {
      return jsonDecode(bodyRaw) as List<dynamic>;
    } else {
      return jsonDecode(bodyRaw) as Map<String, dynamic>;
    }
  }

  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$convexBackend$path'),
      headers: {
        'Content-Type': 'application/json',
        if (_jwt != null) 'Authorization': 'Bearer $_jwt',
        ...?headers,
      },
    );
    if (response.statusCode >= 400) {
      throw Exception('API error: ${response.body}');
    }
    final bodyRaw = response.body;
    final firstNonspace = bodyRaw.trimLeft().isNotEmpty
        ? bodyRaw.trimLeft()[0]
        : '{';
    if (firstNonspace == '[') {
      return jsonDecode(bodyRaw) as List<dynamic>;
    } else {
      return jsonDecode(bodyRaw) as Map<String, dynamic>;
    }
  }

  // Auth/login convenience method
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await post(
      '/api/auth/login-account',
      body: {'email': email, 'password': password},
    );
    if (res is Map<String, dynamic>) return res;
    throw Exception('Expected Map from login endpoint');
  }

  // Fetch current profile (GET -- adjust endpoint as needed)
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final res = await get('/api/teacher/details');
    if (res is Map<String, dynamic>) return res;
    throw Exception('Expected Map from fetchUserProfile endpoint');
  }

  // Logout just clears the jwt
  void logout() => setToken(null);

  Future<Map<String, dynamic>> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$convexBackend/api/auth/create-account'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      data['statusCode'] = response.statusCode;
      return data;
    } catch (e) {
      return {'error': 'error_network', 'statusCode': -1};
    }
  }

  Future<Map<String, dynamic>> googleIdTokenLogin({
    required String idToken,
    required String? name,
  }) async {
    final res = await post(
      '/api/auth/google-idtoken-login',
      body: {'idToken': idToken, if (name != null) 'name': name},
    );
    if (res is Map<String, dynamic>) return res;
    throw Exception('Expected Map from googleIdTokenLogin endpoint');
  }

  Future<Map<String, dynamic>> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$convexBackend/api/auth/verify-email-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );
      final data = jsonDecode(response.body);
      data['statusCode'] = response.statusCode;
      return data;
    } catch (e) {
      return {'error': 'error_network', 'statusCode': -1};
    }
  }

  Future<Map<String, dynamic>> resendVerification({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$convexBackend/api/auth/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      data['statusCode'] = response.statusCode;
      return data;
    } catch (e) {
      return {'error': 'error_network', 'statusCode': -1};
    }
  }
}
