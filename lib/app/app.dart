// Uses flutter_riverpod for global state.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

class KaziAppRoot extends StatelessWidget {
  final Widget child;
  const KaziAppRoot({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: child);
  }
}
