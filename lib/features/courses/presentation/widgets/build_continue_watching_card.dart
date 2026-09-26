import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:thaheen_task/core/di/dependency_injection.dart';
import 'package:thaheen_task/core/extensions/navigation_extensions.dart';
import 'package:thaheen_task/core/routing/routes.dart';
import 'package:thaheen_task/core/theme/app_colors.dart';
import 'package:thaheen_task/core/translations/locale_keys.g.dart';
import 'package:thaheen_task/features/courses/data/data_sources/lesson_progress_local_data_source.dart';
import 'package:thaheen_task/features/courses/data/models/lesson_progress_model.dart';
import 'package:thaheen_task/features/courses/presentation/cubit/courses_cubit.dart';

Widget buildContinueWatchingCard(BuildContext context) {
  final progressDataSource = sl<LessonProgressLocalDataSource>();
  final lastUnfinished = progressDataSource.getLastUnfinishedLesson();

  if (lastUnfinished == null) return const SizedBox.shrink();

  final percentage = (lastUnfinished.progressPercentage * 100).toInt();

  return Container(
    margin: EdgeInsets.all(16.w),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: AppColor.primaryColor.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.continueWatching.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                  color: AppColor.orangColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LinearProgressIndicator(
            value: lastUnfinished.progressPercentage,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation(AppColor.orangColor),
            minHeight: 6.h,
          ),
        ),
        SizedBox(height: 12.h),
        ElevatedButton.icon(
          onPressed: () => _navigateToLesson(context, lastUnfinished),
          icon: const Icon(Icons.play_arrow),
          label: Text(LocaleKeys.continueWatching.tr()),
        ),
      ],
    ),
  );
}

void _navigateToLesson(
    BuildContext context, LessonProgressModel lastUnfinished) {
  final state = context.read<CoursesCubit>().state;
  if (state is! CoursesSuccess) return;

  for (final course in state.courses) {
    if (course.id != lastUnfinished.courseId) continue;

    for (final section in course.sections) {
      final lessonIndex = section.lessons
          .indexWhere((l) => l.id == lastUnfinished.lessonId);

      if (lessonIndex != -1) {
        context.pushNamed(
          Routes.lessonPlayerScreen,
          arguments: {
            'lesson': section.lessons[lessonIndex],
            'courseId': course.id,
            'allLessons': section.lessons,
            'currentIndex': lessonIndex,
          },
        );
        return;
      }
    }
  }
}
