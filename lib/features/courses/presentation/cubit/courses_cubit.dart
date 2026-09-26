import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thaheen_task/features/courses/data/data_sources/lesson_progress_local_data_source.dart';
import 'package:thaheen_task/features/courses/data/models/lesson_model.dart';
import 'package:thaheen_task/features/courses/data/models/lesson_progress_model.dart';

import '../../data/models/course_model.dart';
import '../../data/repositories/courses_repository.dart';

part 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final CoursesRepository coursesRepo;
  final LessonProgressLocalDataSource progressDataSource;

  CoursesCubit({
    required this.coursesRepo,
    required this.progressDataSource,
  }) : super(CoursesInitial());

  Map<String, LessonProgressModel> _progressMap = {};
  Map<String, LessonProgressModel> get progressMap => _progressMap;
  Future<void> loadProgress() async {
    _progressMap = progressDataSource.getAllProgress();
  }

    List<CourseModel> _cachedCourses = [];

  Future<void> getCourses() async {
    emit(CoursesLoading());

   try {
      _cachedCourses = await coursesRepo.getCourses();
      final progressMap = progressDataSource.getAllProgress();
      emit(
        CoursesSuccess(
          courses: _cachedCourses,
          progressMap: progressMap,
        ),
      );
    } catch (e) {
      emit(CoursesError(message: e.toString()));
    }
  }
  void reloadProgress() {
    if (state is CoursesSuccess) {
      final progressMap = progressDataSource.getAllProgress();
      emit(
        CoursesSuccess(
          courses: _cachedCourses,
          progressMap: progressMap,
        ),
      );
    }
  }


    bool isLessonUnlocked(int lessonIndex, List<LessonModel> allLessons) {
    if (lessonIndex == 0) return true;
    final previousLesson = allLessons[lessonIndex - 1];
    final prevProgress = _progressMap[previousLesson.id];
    return prevProgress?.isCompleted ?? false;
  }
 
  Future<void> updateLessonProgress({
    required String lessonId,
    required String courseId,
    required int currentPositionSec,
    required int totalDurationSec,
  }) async {
    
    final isCompleted = totalDurationSec > 0 &&
        (currentPositionSec / totalDurationSec) >= 0.90;
    final existing = _progressMap[lessonId];
    final wasAlreadyCompleted = existing?.isCompleted ?? false;
    final progress = LessonProgressModel(
      lessonId: lessonId,
      courseId: courseId,
      lastPositionSec: currentPositionSec,
      totalDurationSec: totalDurationSec,
      isCompleted: wasAlreadyCompleted || isCompleted,
      lastWatchedAt: DateTime.now(),
    );
    _progressMap[lessonId] = progress;
    await progressDataSource.saveProgress(progress);
    emit(CoursesProgressUpdated(progressMap: Map.from(_progressMap)));
  }
  
  LessonProgressModel? getLastUnfinishedLesson() {
    return progressDataSource.getLastUnfinishedLesson();
  }

}
