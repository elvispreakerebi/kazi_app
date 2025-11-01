import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/services/api_service.dart';

class SubjectsState {
  final Map<String, List<Map<String, dynamic>>> subjectsByClassId;
  final Map<String, bool> isLoadingByClassId;
  final Map<String, String?> errorByClassId;
  final Set<String> deletingSubjectIds;
  const SubjectsState({
    this.subjectsByClassId = const {},
    this.isLoadingByClassId = const {},
    this.errorByClassId = const {},
    this.deletingSubjectIds = const <String>{},
  });

  SubjectsState copyWith({
    Map<String, List<Map<String, dynamic>>>? subjectsByClassId,
    Map<String, bool>? isLoadingByClassId,
    Map<String, String?>? errorByClassId,
    Set<String>? deletingSubjectIds,
  }) {
    return SubjectsState(
      subjectsByClassId: subjectsByClassId ?? this.subjectsByClassId,
      isLoadingByClassId: isLoadingByClassId ?? this.isLoadingByClassId,
      errorByClassId: errorByClassId ?? this.errorByClassId,
      deletingSubjectIds: deletingSubjectIds ?? this.deletingSubjectIds,
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

  Future<List<Map<String, dynamic>>> addSubjects(
    String classId,
    List<Map<String, dynamic>> subjects,
  ) async {
    final loadingMap = {...state.isLoadingByClassId};
    loadingMap[classId] = true;
    state = state.copyWith(isLoadingByClassId: loadingMap);
    try {
      final result = await ApiService().addSubjects(
        classId: classId,
        subjects: subjects,
      );
      // Merge new subjects into existing
      final subjMap = Map<String, List<Map<String, dynamic>>>.from(
        state.subjectsByClassId,
      );
      final newSubjects = List<Map<String, dynamic>>.from(
        subjMap[classId] ?? [],
      );
      for (final s in result) {
        if (!(newSubjects.any(
          (n) => (n['id'] ?? n['_id']) == (s['id'] ?? s['_id']),
        ))) {
          newSubjects.add(s);
        }
      }
      subjMap[classId] = newSubjects;
      loadingMap[classId] = false;
      state = state.copyWith(
        subjectsByClassId: subjMap,
        isLoadingByClassId: loadingMap,
      );
      return result;
    } catch (e) {
      loadingMap[classId] = false;
      state = state.copyWith(isLoadingByClassId: loadingMap);
      rethrow;
    }
  }

  Future<void> deleteSubject(String classId, String subjectId) async {
    final deleting = Set<String>.from(state.deletingSubjectIds);
    deleting.add(subjectId);
    state = state.copyWith(deletingSubjectIds: deleting);
    try {
      await ApiService().deleteSubject(subjectId: subjectId);
      // Remove from state
      final subjMap = Map<String, List<Map<String, dynamic>>>.from(
        state.subjectsByClassId,
      );
      final actualList = List<Map<String, dynamic>>.from(
        subjMap[classId] ?? [],
      );
      actualList.removeWhere((s) => (s['id'] ?? s['_id']) == subjectId);
      subjMap[classId] = actualList;
      deleting.remove(subjectId);
      state = state.copyWith(
        subjectsByClassId: subjMap,
        deletingSubjectIds: deleting,
      );
    } catch (e) {
      deleting.remove(subjectId);
      state = state.copyWith(deletingSubjectIds: deleting);
      rethrow;
    }
  }

  Future<void> updateSubject(
    String classId,
    String subjectId,
    String name,
  ) async {
    final deleting = Set<String>.from(state.deletingSubjectIds);
    deleting.add(subjectId); // reuse the set for edit loading UI
    state = state.copyWith(deletingSubjectIds: deleting);
    try {
      await ApiService().editSubject(subjectId: subjectId, name: name);
      // Update the name in local state
      final subjMap = Map<String, List<Map<String, dynamic>>>.from(
        state.subjectsByClassId,
      );
      final actualList = List<Map<String, dynamic>>.from(
        subjMap[classId] ?? [],
      );
      for (final subj in actualList) {
        if ((subj['id'] ?? subj['_id']) == subjectId) {
          subj['name'] = name;
        }
      }
      subjMap[classId] = actualList;
      deleting.remove(subjectId);
      state = state.copyWith(
        subjectsByClassId: subjMap,
        deletingSubjectIds: deleting,
      );
    } catch (e) {
      deleting.remove(subjectId);
      state = state.copyWith(deletingSubjectIds: deleting);
      rethrow;
    }
  }
}

final subjectsProvider = StateNotifierProvider<SubjectsNotifier, SubjectsState>(
  (ref) {
    return SubjectsNotifier();
  },
);
