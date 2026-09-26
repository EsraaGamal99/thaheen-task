import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:thaheen_task/core/di/dependency_injection.dart';
import 'package:thaheen_task/core/theme/app_colors.dart';
import 'package:thaheen_task/core/translations/locale_keys.g.dart';
import 'package:thaheen_task/features/courses/data/data_sources/lesson_progress_local_data_source.dart';


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
          onPressed: () {
            // context.pushNamed(Routes.lessonPlayerScreen,
            //     arguments: {
            //       'lesson': lastUnfinished.lesson,
            //       'courseId': lastUnfinished.courseId,
            //       'allLessons': lastUnfinished.allLessons,
            //       'currentIndex': lastUnfinished.currentIndex,
            //     });
          },
          icon: const Icon(Icons.play_arrow),
          label: Text(LocaleKeys.continueWatching.tr()),
        ),
      ],
    ),
  );
}
