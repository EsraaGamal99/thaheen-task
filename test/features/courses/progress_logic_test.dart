import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/features/courses/data/data_sources/courses_local_data_source.dart';
import 'package:thaheen_task/features/courses/data/data_sources/lesson_progress_local_data_source.dart';
import 'package:thaheen_task/features/courses/data/models/course_model.dart';
import 'package:thaheen_task/features/courses/data/models/lesson_model.dart';
import 'package:thaheen_task/features/courses/data/models/lesson_progress_model.dart';
import 'package:thaheen_task/features/courses/data/models/section_model.dart';
import 'package:thaheen_task/features/courses/data/repositories/courses_repository.dart';
import 'package:thaheen_task/features/courses/presentation/cubit/courses_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonProgressLocalDataSource progressDataSource;
  late CoursesCubit coursesCubit;

  LessonModel createLesson(String id, {int durationSec = 100}) {
    return LessonModel(
      id: id,
      titleAr: 'درس $id',
      titleEn: 'Lesson $id',
      durationSec: durationSec,
      image: 'image.png',
      video: 'video.mp4',
    );
  }

  CourseModel createCourse({required List<LessonModel> lessons}) {
    return CourseModel(
      id: 'course-1',
      titleAr: 'دورة تعليمية',
      titleEn: 'Sample Course',
      instructor: 'Instructor',
      thumbnail: 'thumb.png',
      lessonCount: lessons.length,
      sections: [
        SectionModel(
          id: 'section-1',
          titleAr: 'الوحدة الأولى',
          titleEn: 'Section 1',
          lessons: lessons,
        ),
      ],
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    progressDataSource = LessonProgressLocalDataSource(sharedPreferences: prefs);
    coursesCubit = CoursesCubit(
      coursesRepo: CoursesRepository(localDataSource: CoursesLocalDataSource()),
      progressDataSource: progressDataSource,
    );
  });

  tearDown(() {
    coursesCubit.close();
  });

  group('Course Progress Logic Unit Tests', () {
    // Test 1: The 90% Completion Rule
    
    test('1. The 90% completion rule: lesson is marked completed at or above 90% and stays completed', () async {
      const lessonId = 'lesson-1';
      const courseId = 'course-1';
      const totalDurationSec = 100;

      // 1. Below 90% ... NOT completed
      await coursesCubit.updateLessonProgress(
        lessonId: lessonId,
        courseId: courseId,
        currentPositionSec: 89,
        totalDurationSec: totalDurationSec,
      );

      expect(
        coursesCubit.progressMap[lessonId]?.isCompleted,
        isFalse,
        reason: 'Lesson should not be marked as completed when watched < 90%',
      );

      // 2. Exactly 90% ... Completed
      await coursesCubit.updateLessonProgress(
        lessonId: lessonId,
        courseId: courseId,
        currentPositionSec: 90,
        totalDurationSec: totalDurationSec,
      );

      expect(
        coursesCubit.progressMap[lessonId]?.isCompleted,
        isTrue,
        reason: 'Lesson should be marked as completed when watched >= 90%',
      );

      // 3. Seeking back to an earlier position (e.g. 15s) retains completed state
      await coursesCubit.updateLessonProgress(
        lessonId: lessonId,
        courseId: courseId,
        currentPositionSec: 15,
        totalDurationSec: totalDurationSec,
      );

      expect(
        coursesCubit.progressMap[lessonId]?.isCompleted,
        isTrue,
        reason: 'Lesson must remain completed even if watched position is updated to a lower value',
      );
    });


    // Test 2: The Unlock Rule

    test('2. The unlock rule: first lesson is unlocked by default, next lesson unlocks only after previous is completed', () async {
      final lessons = [
        createLesson('lesson-1'),
        createLesson('lesson-2'),
        createLesson('lesson-3'),
      ];

      // 1. First lesson (index 0) is always unlocked by default
      expect(
        coursesCubit.isLessonUnlocked(0, lessons),
        isTrue,
        reason: 'First lesson (index 0) must always be unlocked',
      );

      // 2. Second lesson is locked because lesson-1 is not completed
      expect(
        coursesCubit.isLessonUnlocked(1, lessons),
        isFalse,
        reason: 'Second lesson must be locked before previous lesson is completed',
      );

      // 3. Partial progress on lesson-1 (< 90%) still keeps lesson-2 locked
      await coursesCubit.updateLessonProgress(
        lessonId: 'lesson-1',
        courseId: 'course-1',
        currentPositionSec: 50,
        totalDurationSec: 100,
      );

      expect(
        coursesCubit.isLessonUnlocked(1, lessons),
        isFalse,
        reason: 'Second lesson must remain locked while first lesson is only partially watched',
      );

      // 4. When lesson-1 reaches 90% (completed), lesson-2 becomes unlocked
      await coursesCubit.updateLessonProgress(
        lessonId: 'lesson-1',
        courseId: 'course-1',
        currentPositionSec: 90,
        totalDurationSec: 100,
      );

      expect(
        coursesCubit.isLessonUnlocked(1, lessons),
        isTrue,
        reason: 'Second lesson should unlock once previous lesson is completed',
      );

      // 5. Lesson-3 remains locked because lesson-2 is not yet completed
      expect(
        coursesCubit.isLessonUnlocked(2, lessons),
        isFalse,
        reason: 'Third lesson should still be locked since second lesson is not yet completed',
      );
    });


    // Test 3: The Progress % Calculation
    test('3. The progress % calculation: course progress percentage correctly aggregates completed and partially watched lessons', () {
      final lesson1 = createLesson('lesson-1', durationSec: 100);
      final lesson2 = createLesson('lesson-2', durationSec: 100);
      final course = createCourse(lessons: [lesson1, lesson2]);

      // 1. No progress recorded -> 0.0 (0%)
      expect(course.calculateProgress({}), 0.0);

      // 2. Partial progress:
      // - Lesson 1: completed (1.0)
      // - Lesson 2: 50s / 100s (0.50 progress)
      // Overall progress: (1.0 + 0.5) / 2 = 0.75 (75%)
      final partialProgressMap = {
        'lesson-1': LessonProgressModel(
          lessonId: 'lesson-1',
          courseId: 'course-1',
          lastPositionSec: 100,
          totalDurationSec: 100,
          isCompleted: true,
          lastWatchedAt: DateTime.now(),
        ),
        'lesson-2': LessonProgressModel(
          lessonId: 'lesson-2',
          courseId: 'course-1',
          lastPositionSec: 50,
          totalDurationSec: 100,
          isCompleted: false,
          lastWatchedAt: DateTime.now(),
        ),
      };

      final courseProgress = course.calculateProgress(partialProgressMap);
      expect(courseProgress, closeTo(0.75, 0.0001));
      expect((courseProgress * 100).toInt(), 75);

      // 3. All lessons completed:
      // Overall progress: (1.0 + 1.0) / 2 = 1.0 (100%)
      final allCompletedProgressMap = {
        'lesson-1': LessonProgressModel(
          lessonId: 'lesson-1',
          courseId: 'course-1',
          lastPositionSec: 100,
          totalDurationSec: 100,
          isCompleted: true,
          lastWatchedAt: DateTime.now(),
        ),
        'lesson-2': LessonProgressModel(
          lessonId: 'lesson-2',
          courseId: 'course-1',
          lastPositionSec: 95,
          totalDurationSec: 100,
          isCompleted: true,
          lastWatchedAt: DateTime.now(),
        ),
      };

      final fullProgress = course.calculateProgress(allCompletedProgressMap);
      expect(fullProgress, 1.0);
      expect((fullProgress * 100).toInt(), 100);
    });
  });
}
