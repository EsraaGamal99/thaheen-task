part of 'courses_cubit.dart';

abstract class CoursesState {}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesSuccess extends CoursesState {
  final List<CourseModel> courses;
  final Map<String, LessonProgressModel> progressMap;

  CoursesSuccess({
    required this.courses,
    required this.progressMap,
  });
}

class CoursesError extends CoursesState {
  final String message;
  CoursesError({required this.message});
}

class CoursesProgressUpdated extends CoursesState {
  final Map<String, LessonProgressModel> progressMap;

  CoursesProgressUpdated({required this.progressMap});
}
