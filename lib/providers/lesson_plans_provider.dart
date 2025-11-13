import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/services/api_service.dart';

class LessonPlansState {
  final List<Map<String, dynamic>> allLessonPlansWithSubjectNames;
  final bool isLoading;
  final String? error;
  final Map<String, List<Map<String, dynamic>>> lessonPlansBySubjectId;
  final Map<String, bool> isLoadingBySubjectId;
  final Map<String, String?> errorBySubjectId;
  
  LessonPlansState({
    this.allLessonPlansWithSubjectNames = const [],
    this.isLoading = false,
    this.error,
    this.lessonPlansBySubjectId = const {},
    this.isLoadingBySubjectId = const {},
    this.errorBySubjectId = const {},
  });

  LessonPlansState copyWith({
    List<Map<String, dynamic>>? allLessonPlansWithSubjectNames,
    bool? isLoading,
    String? error,
    Map<String, List<Map<String, dynamic>>>? lessonPlansBySubjectId,
    Map<String, bool>? isLoadingBySubjectId,
    Map<String, String?>? errorBySubjectId,
  }) {
    return LessonPlansState(
      allLessonPlansWithSubjectNames: allLessonPlansWithSubjectNames ?? this.allLessonPlansWithSubjectNames,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lessonPlansBySubjectId: lessonPlansBySubjectId ?? this.lessonPlansBySubjectId,
      isLoadingBySubjectId: isLoadingBySubjectId ?? this.isLoadingBySubjectId,
      errorBySubjectId: errorBySubjectId ?? this.errorBySubjectId,
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

  Future<void> fetchLessonPlansForSubject(String subjectId) async {
    final loadingMap = Map<String, bool>.from(state.isLoadingBySubjectId);
    loadingMap[subjectId] = true;
    state = state.copyWith(isLoadingBySubjectId: loadingMap);
    
    try {
      final lessonPlans = await ApiService().getLessonPlansBySubject(subjectId);
      final plansMap = Map<String, List<Map<String, dynamic>>>.from(
        state.lessonPlansBySubjectId,
      );
      plansMap[subjectId] = lessonPlans;
      loadingMap[subjectId] = false;
      final errorMap = Map<String, String?>.from(state.errorBySubjectId);
      errorMap[subjectId] = null;
      state = state.copyWith(
        lessonPlansBySubjectId: plansMap,
        isLoadingBySubjectId: loadingMap,
        errorBySubjectId: errorMap,
      );
    } catch (e) {
      final errorMap = Map<String, String?>.from(state.errorBySubjectId);
      errorMap[subjectId] = e.toString();
      loadingMap[subjectId] = false;
      state = state.copyWith(
        isLoadingBySubjectId: loadingMap,
        errorBySubjectId: errorMap,
      );
    }
  }

  Future<String> createLessonPlan({
    required String classId,
    required String subjectId,
    required String topic,
    String? objective,
  }) async {
    try {
      final result = await ApiService().createLessonPlan(
        classId: classId,
        subjectId: subjectId,
        topic: topic,
        objective: objective,
      );
      // Refresh lesson plans for the subject after creation
      await fetchLessonPlansForSubject(subjectId);
      // Also refresh all lesson plans with subject names for the lesson plans page
      await fetchAllLessonPlansWithSubjectNames();
      // Return the lesson plan ID for navigation
      return result['_id']?.toString() ?? '';
    } catch (e) {
      rethrow;
    }
  }
}

final lessonPlansProvider = StateNotifierProvider<LessonPlansNotifier, LessonPlansState>(
  (ref) {
    return LessonPlansNotifier();
  },
);

