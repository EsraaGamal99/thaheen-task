import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thaheen_task/core/translations/locale_keys.g.dart';
import 'package:thaheen_task/features/courses/data/models/course_model.dart';
import 'package:thaheen_task/features/courses/presentation/widgets/expandable_card.dart';
 
class CourseDetailsScreen extends StatelessWidget {
  final List<CourseModel> courses;
  final int courseIndex;
  final String lang;
  const CourseDetailsScreen(
      {super.key,
      required this.courses,
      required this.courseIndex,
      required this.lang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ar'
            ? courses[courseIndex].titleAr
            : courses[courseIndex].titleEn),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                courses[courseIndex].thumbnail,
                width: 390.w,
                height: 250.h,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 16),
              Text(
                LocaleKeys.courseDescription.tr(),
                style: TextStyle(fontSize: 16),
              ),
              Card(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: courses[courseIndex].sections.length,
                    itemBuilder: (context, index) {
                      final lessons =
                          courses[courseIndex].sections[index].lessons;
                      return Column(
                        children: [
                          ListTile(
                            title: Text(lang == 'ar'
                                ? courses[courseIndex].sections[index].titleAr
                                : courses[courseIndex].sections[index].titleEn),
                          ),
                          ExpandableCard(
                            title: LocaleKeys.lessons.tr(),
                            lang: lang,
                            lessons: lessons,
                            courseId: courses[courseIndex].id,
                          ),
                        ],
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
