import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/services/api_service.dart';

class LessonPlansState {
  final List<Map<String, dynamic>> allLessonPlansWithSubjectNames;
  final bool isLoading;
  final String? error;
  
  LessonPlansState({
    this.allLessonPlansWithSubjectNames = const [],
    this.isLoading = false,
    this.error,
  });

  LessonPlansState copyWith({
    List<Map<String, dynamic>>? allLessonPlansWithSubjectNames,
    bool? isLoading,
    String? error,
  }) {
    return LessonPlansState(
      allLessonPlansWithSubjectNames: allLessonPlansWithSubjectNames ?? this.allLessonPlansWithSubjectNames,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class LessonPlansNotifier extends StateNotifier<LessonPlansState> {
  LessonPlansNotifier() : super(LessonPlansState());

  Future<void> fetchAllLessonPlansWithSubjectNames() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final lessonPlans = await ApiService().getTeacherLessonPlans();
      state = state.copyWith(
        allLessonPlansWithSubjectNames: lessonPlans,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final lessonPlansProvider = StateNotifierProvider<LessonPlansNotifier, LessonPlansState>(
  (ref) {
    return LessonPlansNotifier();
  },
);

