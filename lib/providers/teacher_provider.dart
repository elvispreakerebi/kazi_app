import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/services/api_service.dart';

class TeacherState {
  final String? id;
  final String? email;
  final String? name;
  final String? firstName;
  final String? language;
  final bool? verified;
  final int? classesCount;
  final int? subjectsCount;
  final int? lessonPlansCount;
  final bool isLoading;
  final String? error;

  const TeacherState({
    this.id,
    this.email,
    this.name,
    this.firstName,
    this.language,
    this.verified,
    this.classesCount,
    this.subjectsCount,
    this.lessonPlansCount,
    this.isLoading = false,
    this.error,
  });

  TeacherState copyWith({
    String? id,
    String? email,
    String? name,
    String? firstName,
    String? language,
    bool? verified,
    int? classesCount,
    int? subjectsCount,
    int? lessonPlansCount,
    bool? isLoading,
    String? error,
  }) {
    return TeacherState(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      language: language ?? this.language,
      verified: verified ?? this.verified,
      classesCount: classesCount ?? this.classesCount,
      subjectsCount: subjectsCount ?? this.subjectsCount,
      lessonPlansCount: lessonPlansCount ?? this.lessonPlansCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class TeacherNotifier extends StateNotifier<TeacherState> {
  TeacherNotifier() : super(const TeacherState());

  Future<void> fetchTeacherDetailsAndCounts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await ApiService().fetchUserProfile();
      final name = profile['name'] ?? '';
      final firstName = name.split(' ').first;
      final counts = await ApiService().fetchTeacherOverviewCounts();
      state = state.copyWith(
        id: profile['id'] ?? profile['_id'],
        email: profile['email'],
        name: name,
        firstName: firstName,
        language: profile['language'],
        verified: profile['verified'],
        classesCount: counts['classes'],
        subjectsCount: counts['subjects'],
        lessonPlansCount: counts['lessonPlans'],
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final teacherProvider = StateNotifierProvider<TeacherNotifier, TeacherState>((
  ref,
) {
  final notifier = TeacherNotifier();
  notifier.fetchTeacherDetailsAndCounts();
  return notifier;
});
