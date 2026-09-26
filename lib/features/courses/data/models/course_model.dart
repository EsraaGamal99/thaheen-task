import 'lesson_model.dart';
import 'lesson_progress_model.dart';
import 'section_model.dart';

class CourseModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final String instructor;
  final String thumbnail;
  final int lessonCount;
  final List<SectionModel> sections;

  const CourseModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.instructor,
    required this.thumbnail,
    required this.lessonCount,
    required this.sections,
  });

  List<LessonModel> get allLessons {
    return sections.expand((section) => section.lessons).toList();
  }

  double calculateProgress(Map<String, LessonProgressModel> progressMap) {
    final lessons = allLessons;
    if (lessons.isEmpty) return 0.0;

    double totalProgress = 0.0;

    for (final lesson in lessons) {
      final progress = progressMap[lesson.id];
      if (progress != null) {
        if (progress.isCompleted) {
          totalProgress += 1.0;
        } else {
          totalProgress += progress.progressPercentage;
        }
      }
    }

    return (totalProgress / lessons.length).clamp(0.0, 1.0);
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      titleAr: json['titleAr'] as String,
      titleEn: json['titleEn'] as String,
      instructor: json['instructor'] as String,
      thumbnail: json['thumbnail'] as String,
      lessonCount: json['lessonCount'] as int,
      sections: (json['sections'] as List)
          .map(
            (section) => SectionModel.fromJson(
              section as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
