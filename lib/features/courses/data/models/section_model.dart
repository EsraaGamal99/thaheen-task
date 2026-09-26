import 'lesson_model.dart';

class SectionModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final List<LessonModel> lessons;

  const SectionModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.lessons,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as String,
      titleAr: json['titleAr'] as String,
      titleEn: json['titleEn'] as String,
      lessons: (json['lessons'] as List)
          .map(
            (lesson) => LessonModel.fromJson(
              lesson as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}