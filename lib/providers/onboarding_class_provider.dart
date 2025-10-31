import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../shared/services/api_service.dart';

class OnboardingClassState {
  final bool isLoading;
  final String? error;
  const OnboardingClassState({this.isLoading = false, this.error});
  OnboardingClassState copyWith({bool? isLoading, String? error}) =>
      OnboardingClassState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

class OnboardingClassNotifier extends StateNotifier<OnboardingClassState> {
  OnboardingClassNotifier() : super(const OnboardingClassState());

  Future<List<dynamic>?> submitClasses(
    List<Map<String, String>> classes,
    BuildContext context,
  ) async {
    // UI/UX: must add at least one class
    if (classes.isEmpty ||
        classes.every(
          (c) =>
              (c['name']?.isEmpty ?? true) &&
              (c['gradeLevel']?.isEmpty ?? true),
        )) {
      state = state.copyWith(error: 'Please add at least one class.');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one class.')),
        );
      }
      return null;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resp = await ApiService().post(
        '/api/classes/add',
        body: {"classes": classes},
      );
      if (resp is List) {
        state = state.copyWith(isLoading: false, error: null);
        return resp;
      }
      // Fallback: treat any other response (including Map/error) as error
      final msg = (resp is Map && resp['error'] != null)
          ? resp['error'].toString()
          : 'Failed to add classes';
      state = state.copyWith(isLoading: false, error: msg);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add classes: $e')));
      }
    }
    return null;
  }
}

final onboardingClassProvider =
    StateNotifierProvider<OnboardingClassNotifier, OnboardingClassState>((ref) {
      return OnboardingClassNotifier();
    });
