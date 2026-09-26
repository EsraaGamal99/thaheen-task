import '../data_sources/courses_local_data_source.dart';
import '../models/course_model.dart';

class CoursesRepository {
  final CoursesLocalDataSource localDataSource;

  CoursesRepository({
    required this.localDataSource,
  });

  Future<List<CourseModel>> getCourses() {
    return localDataSource.getCourses();
  }
}