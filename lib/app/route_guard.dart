import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Example: AuthGuard - used to wrap routes or widgets that require login
class AuthGuard extends ConsumerWidget {
  final Widget child;
  const AuthGuard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use ref.watch(authStateProvider), etc.
    return child; // Add logic later
  }
}

/// OnboardingGuard can be similarly built
class OnboardingGuard extends ConsumerWidget {
  final Widget child;
  const OnboardingGuard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use onboarding progress providers later
    return child;
  }
}
