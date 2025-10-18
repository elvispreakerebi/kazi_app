// Uses flutter_riverpod for global state.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../shared/services/api_service.dart';

/// Auth/user state: null if not signed in
final authStateProvider = StateProvider<String?>(
  (ref) => null,
); // Holds JWT or user ID
/// User profile state (name, email, etc.)
final userProfileProvider = StateProvider<UserProfile?>((ref) => null);

/// Language state (for localization)
final languageProvider = StateProvider<String>((ref) => 'english');

/// Example UserProfile model (adjust fields as needed)
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String language;
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.language,
  });
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    language: json['language'] ?? 'english',
  );
}

// Login state for async login process
class LoginState {
  final bool loading;
  final String? error;
  LoginState({this.loading = false, this.error});
}

class LoginNotifier extends AsyncNotifier<LoginState> {
  @override
  FutureOr<LoginState> build() => LoginState();

  Future<void> login(String email, String password) async {
    state = AsyncValue.loading();
    try {
      final response = await ApiService().login(email, password);
      final token = response['token'] as String?;
      if (token == null) throw Exception('No token received');
      ref.read(authStateProvider.notifier).state = token;
      ApiService().setToken(token);
      final profileData = await ApiService().fetchUserProfile();
      ref.read(userProfileProvider.notifier).state = UserProfile.fromJson(
        profileData,
      );
      state = AsyncValue.data(LoginState(loading: false));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final loginProvider = AsyncNotifierProvider<LoginNotifier, LoginState>(
  () => LoginNotifier(),
);

class KaziAppRoot extends StatelessWidget {
  final Widget child;
  const KaziAppRoot({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: child);
  }
}
