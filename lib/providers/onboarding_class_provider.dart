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
  List<Map<String, dynamic>> classes = [];

  OnboardingClassNotifier() : super(const OnboardingClassState());

  void setClasses(List<Map<String, dynamic>> newClasses) {
    classes = List<Map<String, dynamic>>.from(newClasses);
    state = state.copyWith(); // triggers listeners
  }

  List<Map<String, dynamic>> getClasses() => classes;

  Future<List<dynamic>?> submitClasses(
    List<Map<String, dynamic>> classesIn,
    BuildContext context,
  ) async {
    // At least one valid class must be present
    if (classesIn.isEmpty ||
        classesIn.every(
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
      // Split new (no id) vs. existing (has id)
      List<Map<String, dynamic>> toAdd = [];
      List<Map<String, dynamic>> toEdit = [];
      for (var c in classesIn) {
        if (c['id'] != null && "${c['id']}".isNotEmpty) {
          toEdit.add(c);
        } else {
          toAdd.add(c);
        }
      }
      // Add new classes
      List<dynamic> results = [];
      if (toAdd.isNotEmpty) {
        final resp = await ApiService().post(
          '/api/classes/add',
          body: {
            "classes": toAdd
                .map(
                  (c) => {
                    'name': c['name'],
                    'gradeLevel': c['gradeLevel'],
                    if (c['academicYear'] != null)
                      'academicYear': c['academicYear'],
                  },
                )
                .toList(),
          },
        );
        if (resp is List) {
          for (int i = 0; i < resp.length; i++) {
            // Attach backend id to new class, fallback on index alignment
            if (resp[i]['id'] != null) {
              toAdd[i]['id'] = resp[i]['id'];
            }
            results.add(resp[i]);
          }
        }
      }
      // Edit existing classes
      for (final c in toEdit) {
        // Only call edit if any value has changed. For simplicity we will always send edit for now.
        try {
          final editResp = await ApiService().editClass(
            classId: c['id'].toString(),
            name: c['name'],
            gradeLevel: c['gradeLevel'],
            academicYear: c['academicYear'],
          );
          results.add(editResp);
        } catch (e) {
          results.add({'error': e.toString(), 'id': c['id']});
        }
      }
      // Update provider state with ids
      setClasses([...toAdd, ...toEdit]);
      state = state.copyWith(isLoading: false, error: null);
      return results;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add/edit classes: $e')),
        );
      }
    }
    return null;
  }
}

final onboardingClassProvider =
    StateNotifierProvider<OnboardingClassNotifier, OnboardingClassState>((ref) {
      return OnboardingClassNotifier();
    });
