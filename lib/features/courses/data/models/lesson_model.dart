class LessonModel {
  final String id;
  final String titleAr;
  final String titleEn;
  final int durationSec;
  final String image;
  final String video;

  const LessonModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.durationSec,
    required this.image,
    required this.video,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      titleAr: json['titleAr'] as String,
      titleEn: json['titleEn'] as String,
      durationSec: json['durationSec'] as int,
      image: json['img'] as String,
      video: json['video'] as String,
    );
  }
}