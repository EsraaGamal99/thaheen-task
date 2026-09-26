import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thaheen_task/core/di/dependency_injection.dart';
import 'package:thaheen_task/core/extensions/navigation_extensions.dart';
import 'package:thaheen_task/core/routing/routes.dart';
import 'package:thaheen_task/core/theme/app_colors.dart';
import 'package:thaheen_task/core/translations/locale_keys.g.dart';
import 'package:thaheen_task/features/courses/data/data_sources/lesson_progress_local_data_source.dart';
import 'package:thaheen_task/features/courses/data/models/lesson_model.dart';
import 'package:thaheen_task/features/courses/data/models/lesson_progress_model.dart';

class ExpandableCard extends StatelessWidget {
  final String title;
  final String lang;
  final List<LessonModel> lessons;
  final String courseId;

  const ExpandableCard({
    super.key,
    required this.title,
    required this.lessons,
    required this.lang,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final progressDataSource = sl<LessonProgressLocalDataSource>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColor.orangColor,
          collapsedIconColor: AppColor.primaryColor,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          children: [
            if (lessons.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(LocaleKeys.empryLessons.tr()),
              )
            else
              for (int i = 0; i < lessons.length; i++) ...[
                Builder(
                  builder: (context) {
                    final currentLesson = lessons[i];

                     
                    final bool isUnlocked = i == 0 ||
                        (progressDataSource
                                .getLessonProgress(lessons[i - 1].id)
                                ?.isCompleted ??
                            false);

                     
                    final progress =
                        progressDataSource.getLessonProgress(currentLesson.id);
                    final status = progress?.status ?? LessonStatus.notStarted;

                    return ListTile(
                       
                      leading: Icon(
                        Icons.play_circle_fill,
                        color: isUnlocked
                            ? AppColor.orangColor
                            : Colors.grey.shade400,
                        size: 30.sp,
                      ),
                      
                      title: Text(
                        lang == 'ar'
                            ? currentLesson.titleAr
                            : currentLesson.titleEn,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked ? Colors.black87 : Colors.grey,
                        ),
                      ),
                       
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: _buildLessonStatusText(status, isUnlocked, lang),
                      ),
                      
                      trailing: Text(
                        '${LocaleKeys.duration.tr()} : ${currentLesson.durationSec} ${LocaleKeys.seconds.tr()}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isUnlocked
                              ? Colors.black54
                              : Colors.grey.shade400,
                        ),
                      ),
                      onTap: () {
                        if (!isUnlocked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                              content: Text(
                                  LocaleKeys.thisLessonClosedNow.tr()),
                            ),
                          );
                          return;
                        }

                        context.pushNamed(
                          Routes.lessonPlayerScreen,
                          arguments: {
                            'lesson': currentLesson,
                            'courseId': courseId,
                            'allLessons': lessons,
                            'currentIndex': i,
                          },
                        );
                      },
                    );
                  },
                ),
              ],
          ],
        ),
      ),
    );
  }

   
  Widget _buildLessonStatusText(
      LessonStatus status, bool isUnlocked, String lang) {
    if (!isUnlocked) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, size: 14.sp, color: Colors.grey),
          SizedBox(width: 4.w),
          Text(
            LocaleKeys.locked.tr(),
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    String text;
    Color color;

    switch (status) {
      case LessonStatus.completed:
        text = LocaleKeys.completed.tr();
        color = Colors.green;
        break;
      case LessonStatus.inProgress:
        text = LocaleKeys.inProgress.tr();
        color = AppColor.orangColor;
        break;
      case LessonStatus.notStarted:
        text = LocaleKeys.start.tr();
        color = AppColor.primaryColor;
        break;
    }

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
