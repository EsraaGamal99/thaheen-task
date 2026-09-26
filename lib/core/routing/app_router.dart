import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thaheen_task/core/di/dependency_injection.dart';
import 'package:thaheen_task/features/courses/data/models/course_model.dart';
import 'package:thaheen_task/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:thaheen_task/features/courses/presentation/screens/course_details_screen.dart';
import 'package:thaheen_task/features/courses/presentation/screens/lesson_playes_screen.dart';
import '../routing/routes.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/courses/presentation/screens/courses_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return _createRoute(const SplashScreen());
      case Routes.coursesScreen:
        return _createRoute(BlocProvider(
          create: (context) => CoursesCubit(
            coursesRepo: sl(),
            progressDataSource: sl(),
          )..getCourses(),
          child: const CoursesScreen(),
        ));
      case Routes.courseDetailsScreen:
        final args = settings.arguments as Map<String, dynamic>;
        final courses = args['courses'] as List<CourseModel>;
        final courseIndex = args['courseIndex'] as int;
        final lang = args['lang'] as String;
        return _createRoute(CourseDetailsScreen(
          courses: courses,
          courseIndex: courseIndex,
          lang: lang,
        ));

      case Routes.lessonPlayerScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return _createRoute(LessonPlayerScreen(
          lesson: args['lesson'],
          courseId: args['courseId'],
          allLessons: args['allLessons'],
          currentIndex: args['currentIndex'],
        ));

      default:
        return null;
    }
  }

  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
