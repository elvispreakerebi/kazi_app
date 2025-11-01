import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/services/api_service.dart';

class SubjectsState {
  final Map<String, List<Map<String, dynamic>>> subjectsByClassId;
  final Map<String, bool> isLoadingByClassId;
  final Map<String, String?> errorByClassId;
  const SubjectsState({
    this.subjectsByClassId = const {},
    this.isLoadingByClassId = const {},
    this.errorByClassId = const {},
  });

  SubjectsState copyWith({
    Map<String, List<Map<String, dynamic>>>? subjectsByClassId,
    Map<String, bool>? isLoadingByClassId,
    Map<String, String?>? errorByClassId,
  }) {
    return SubjectsState(
      subjectsByClassId: subjectsByClassId ?? this.subjectsByClassId,
      isLoadingByClassId: isLoadingByClassId ?? this.isLoadingByClassId,
      errorByClassId: errorByClassId ?? this.errorByClassId,
    );
  }
}

class SubjectsNotifier extends StateNotifier<SubjectsState> {
  SubjectsNotifier() : super(const SubjectsState());

  Future<void> fetchSubjectsForClass(String classId) async {
    final loadingMap = Map<String, bool>.from(state.isLoadingByClassId);
    loadingMap[classId] = true;
    state = state.copyWith(isLoadingByClassId: loadingMap);
    try {
      final subjects = await ApiService().getClassSubjects(classId);
      final subjMap = Map<String, List<Map<String, dynamic>>>.from(
        state.subjectsByClassId,
      );
      subjMap[classId] = subjects;
      loadingMap[classId] = false;
      final errorMap = Map<String, String?>.from(state.errorByClassId);
      errorMap[classId] = null;
      state = state.copyWith(
        subjectsByClassId: subjMap,
        isLoadingByClassId: loadingMap,
        errorByClassId: errorMap,
      );
    } catch (e) {
      final errorMap = Map<String, String?>.from(state.errorByClassId);
      errorMap[classId] = e.toString();
      loadingMap[classId] = false;
      state = state.copyWith(
        isLoadingByClassId: loadingMap,
        errorByClassId: errorMap,
      );
    }
  }
}

final subjectsProvider = StateNotifierProvider<SubjectsNotifier, SubjectsState>(
  (ref) {
    return SubjectsNotifier();
  },
);
