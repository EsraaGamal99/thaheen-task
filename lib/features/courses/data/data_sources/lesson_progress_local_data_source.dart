import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson_progress_model.dart';

class LessonProgressLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _progressKey = 'lessons_progress_data';

  LessonProgressLocalDataSource({required this.sharedPreferences});


  Map<String, LessonProgressModel> getAllProgress() {
    final rawJson = sharedPreferences.getString(_progressKey);
    if (rawJson == null) return {};

    final Map<String, dynamic> decoded = json.decode(rawJson);
    return decoded.map(
      (key, value) => MapEntry(
        key,
        LessonProgressModel.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  
  LessonProgressModel? getLessonProgress(String lessonId) {
    final all = getAllProgress();
    return all[lessonId];
  }


  Future<void> saveProgress(LessonProgressModel progress) async {
    final all = getAllProgress();
    all[progress.lessonId] = progress;

    final encoded = json.encode(
      all.map((key, value) => MapEntry(key, value.toJson())),
    );
    await sharedPreferences.setString(_progressKey, encoded);
  }

  LessonProgressModel? getLastUnfinishedLesson() {
    final all = getAllProgress().values.toList();
    final unfinished = all
        .where((p) => p.status == LessonStatus.inProgress && !p.isCompleted)
        .toList();

    if (unfinished.isEmpty) return null;

    unfinished.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));
    return unfinished.first;
  }
}
