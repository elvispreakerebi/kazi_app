import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../shared/services/api_service.dart';

class ClassState {
  final List<Map<String, dynamic>> classes;
  final bool isLoading;
  final String? error;
  const ClassState({
    this.classes = const [],
    this.isLoading = false,
    this.error,
  });

  ClassState copyWith({
    List<Map<String, dynamic>>? classes,
    bool? isLoading,
    String? error,
  }) => ClassState(
    classes: classes ?? this.classes,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}

class ClassNotifier extends StateNotifier<ClassState> {
  ClassNotifier() : super(const ClassState());

  Future<void> fetchClasses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final classes = await ApiService().getClasses();
      state = state.copyWith(classes: classes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addClasses(
    List<Map<String, dynamic>> newClasses,
    BuildContext context,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ApiService().post(
        '/api/classes/add',
        body: {
          "classes": newClasses
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
      await fetchClasses();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add classes: $e')));
      }
    }
  }

  Future<void> editClass(Map<String, dynamic> cls, BuildContext context) async {
    if (cls['id'] == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ApiService().editClass(
        classId: cls['id'].toString(),
        name: cls['name'],
        gradeLevel: cls['gradeLevel'],
        academicYear: cls['academicYear'],
      );
      await fetchClasses();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to edit class: $e')));
      }
    }
  }

  Future<void> deleteClass(String id, BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ApiService().deleteClass(id);
      await fetchClasses();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete class: $e')));
      }
    }
  }
}

final classProvider = StateNotifierProvider<ClassNotifier, ClassState>((ref) {
  return ClassNotifier();
});
