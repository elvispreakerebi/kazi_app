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

  Future<Map<String, dynamic>> editClass({
    required String classId,
    required String? name,
    required String? gradeLevel,
    String? academicYear,
  }) async {
    final res = await post(
      '/api/classes/edit',
      body: {
        'classId': classId,
        if (name != null) 'name': name,
        if (gradeLevel != null) 'gradeLevel': gradeLevel,
        if (academicYear != null) 'academicYear': academicYear,
      },
    );
    if (res is Map<String, dynamic>) return res;
    throw Exception('Expected Map from editClass endpoint');
  }

  Future<List<Map<String, dynamic>>> getClasses() async {
    final res = await get('/api/classes/list');
    if (res is List) return res.cast<Map<String, dynamic>>();
    throw Exception('Expected List from getClasses endpoint');
  }

  Future<Map<String, dynamic>> getClassById(String classId) async {
    final res = await get('/api/classes/get?classId=$classId');
    if (res is Map<String, dynamic>) return res;
    throw Exception('Expected Map from getClass endpoint');
  }

  Future<Map<String, dynamic>> deleteClass(String classId) async {
    final res = await post('/api/classes/delete', body: {'classId': classId});
    if (res is Map<String, dynamic>) return res;
    throw Exception('Expected Map from deleteClass endpoint');
  }

  Future<List<Map<String, dynamic>>> getClassSubjects(String classId) async {
    final res = await get('/api/subjects/list?classId=$classId');
    if (res is List) return res.cast<Map<String, dynamic>>();
    throw Exception('Expected List from getClassSubjects endpoint');
  }

  Future<List<Map<String, dynamic>>> addSubjects({
    required String classId,
    required List<Map<String, dynamic>> subjects,
  }) async {
    final res = await post(
      '/api/subjects/add',
      body: {'classId': classId, 'subjects': subjects},
    );
    if (res is List) return res.cast<Map<String, dynamic>>();
    throw Exception('Expected List from addSubjects endpoint');
  }

  Future<Map<String, dynamic>> deleteSubject({
    required String subjectId,
  }) async {
    final res = await post(
      '/api/subjects/delete',
      body: {'subjectId': subjectId},
    );
    if (res is Map<String, dynamic>) return res;
    throw Exception('Expected Map from deleteSubject endpoint');
  }

  Future<Map<String, dynamic>> editSubject({
    required String subjectId,
    required String name,
  }) async {
    final res = await post(
      '/api/subjects/edit',
      body: {'subjectId': subjectId, 'name': name},
    );
    if (res is Map<String, dynamic>) return res;
    throw Exception('Expected Map from editSubject endpoint');
  }

  Future<Map<String, dynamic>> fetchTeacherOverviewCounts() async {
    final res = await get('/api/teacher/overview-counts');
    if (res is Map<String, dynamic>) return res;
    throw Exception('Expected Map from fetchTeacherOverviewCounts endpoint');
  }

  Future<Map<String, dynamic>> getClassSubjectsCount(String classId) async {
    try {
      final res = await get('/api/classes/subjects-count?classId=$classId');
      if (res is Map<String, dynamic>) return res;
      throw Exception('Expected Map from getClassSubjectsCount endpoint, got: ${res.runtimeType}');
    } catch (e) {
      // Re-throw with more context
      throw Exception('Failed to fetch subject count for class $classId: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTeacherLessonPlans() async {
    final res = await get('/api/lessonPlans/list');
    if (res is List) return res.cast<Map<String, dynamic>>();
    throw Exception('Expected List from getTeacherLessonPlans endpoint');
  }
}
