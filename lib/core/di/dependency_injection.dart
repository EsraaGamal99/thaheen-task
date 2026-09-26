import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/features/courses/data/data_sources/courses_local_data_source.dart';
import 'package:thaheen_task/features/courses/data/data_sources/lesson_progress_local_data_source.dart';
import 'package:thaheen_task/features/courses/data/repositories/courses_repository.dart';

final sl = GetIt.instance;

Future<void> setUp({required SharedPreferences sharedPreferences}) async {
  // Registering SharedPreferences
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Registering CoursesRepository
  sl.registerLazySingleton<CoursesRepository>(
    () => CoursesRepository(
      localDataSource: sl(),
    ),
  );

  // Registering CoursesLocalDataSource
  sl.registerLazySingleton<CoursesLocalDataSource>(
    () => CoursesLocalDataSource(),
  );

  sl.registerLazySingleton<LessonProgressLocalDataSource>(
  () => LessonProgressLocalDataSource(sharedPreferences: sl()),
);

}
