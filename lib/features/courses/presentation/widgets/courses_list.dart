import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thaheen_task/core/extensions/navigation_extensions.dart';
import 'package:thaheen_task/core/extensions/sizedbox_extensions.dart';
import 'package:thaheen_task/core/extensions/theme_extensions.dart';
import 'package:thaheen_task/core/routing/routes.dart';
import 'package:thaheen_task/core/theme/app_colors.dart';
import 'package:thaheen_task/core/translations/locale_keys.g.dart';
import 'package:thaheen_task/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:thaheen_task/features/courses/presentation/widgets/build_continue_watching_card.dart';

class CoursesList extends StatelessWidget {
  const CoursesList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String lang = context.locale.languageCode;
    return BlocBuilder<CoursesCubit, CoursesState>(
      builder: (context, state) {
        if (state is CoursesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColor.primaryColor,
            ),
          );
        } else if (state is CoursesSuccess) {
          final courses = state.courses;
          return Column(
            children: [
              buildContinueWatchingCard(context),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: courses.length,
                  separatorBuilder: (context, index) => verticalSpace(10.h),
                  itemBuilder: (context, index) {
                    // current proggress caalculate
                    final course = courses[index];
                    final progressMap = state.progressMap;
                    final courseProgress =
                        course.calculateProgress(progressMap);
                    final percentage = (courseProgress * 100).toInt();

                    // detrmind if display aontinue flag or not
                    final isContinueWatching =
                        courseProgress > 0 && courseProgress < 1.0;

                    return InkWell(
                      onTap: () {
                        context.pushNamed(
                          Routes.courseDetailsScreen,
                          arguments: {
                            'courses': courses,
                            'courseIndex': index,
                            'lang': lang,
                          },
                        );
                        if (context.mounted) {
                          context.read<CoursesCubit>().reloadProgress();
                        }
                      },
                      child: Card(
                        color: context.theme.scaffoldBackgroundColor,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image(
                                  image: AssetImage(courses[index].thumbnail),
                                  width: 100.w,
                                  height: 100.h,
                                  fit: BoxFit.fill,
                                ),
                                horizontalSpace(10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lang == 'ar'
                                            ? courses[index].titleAr
                                            : courses[index].titleEn,
                                        style: GoogleFonts.nunito(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      verticalSpace(5.h),
                                      Text(
                                        lang == 'ar'
                                            ? LocaleKeys.instructor.tr()
                                            : LocaleKeys.instructor.tr(),
                                        style: GoogleFonts.nunito(
                                          fontSize: 14.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      verticalSpace(5.h),
                                      Text(
                                        "${LocaleKeys.lessonsCount.tr()}: ${courses[index].lessonCount.toString()}",
                                        style: GoogleFonts.nunito(
                                          fontSize: 14.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      verticalSpace(5.h),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: SizedBox(
                                            height: 10,
                                            child: LinearProgressIndicator(
                                              value: courseProgress,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                      Color>(
                                                AppColor.orangColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      verticalSpace(5.h),
                                      Text(
                                        "${LocaleKeys.progress.tr()}: $percentage%",
                                        style: GoogleFonts.nunito(
                                          fontSize: 14.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (state is CoursesError) {
          return Center(
            child: Text(state.message),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
