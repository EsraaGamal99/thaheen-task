enum LessonStatus {
  notStarted,
  inProgress,
  completed,
}

class LessonProgressModel {
  final String lessonId;
  final String courseId;
  final int lastPositionSec;
  final int totalDurationSec;
  final bool isCompleted;
  final DateTime lastWatchedAt;

  const LessonProgressModel({
    required this.lessonId,
    required this.courseId,
    required this.lastPositionSec,
    required this.totalDurationSec,
    required this.isCompleted,
    required this.lastWatchedAt,
  });

  LessonStatus get status {
    if (isCompleted) return LessonStatus.completed;
    if (lastPositionSec > 0) return LessonStatus.inProgress;
    return LessonStatus.notStarted;
  }

  
  double get progressPercentage {
    if (totalDurationSec == 0) return 0.0;
    final progress = lastPositionSec / totalDurationSec;
    return progress.clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'lessonId': lessonId,
        'courseId': courseId,
        'lastPositionSec': lastPositionSec,
        'totalDurationSec': totalDurationSec,
        'isCompleted': isCompleted,
        'lastWatchedAt': lastWatchedAt.toIso8601String(),
      };

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) =>
      LessonProgressModel(
        lessonId: json['lessonId'] as String,
        courseId: json['courseId'] as String? ?? '',
        lastPositionSec: json['lastPositionSec'] as int? ?? 0,
        totalDurationSec: json['totalDurationSec'] as int? ?? 0,
        isCompleted: json['isCompleted'] as bool? ?? false,
        lastWatchedAt: json['lastWatchedAt'] != null
            ? DateTime.parse(json['lastWatchedAt'] as String)
            : DateTime.now(),
      );

  LessonProgressModel copyWith({
    int? lastPositionSec,
    int? totalDurationSec,
    bool? isCompleted,
    DateTime? lastWatchedAt,
  }) {
    return LessonProgressModel(
      lessonId: lessonId,
      courseId: courseId,
      lastPositionSec: lastPositionSec ?? this.lastPositionSec,
      totalDurationSec: totalDurationSec ?? this.totalDurationSec,
      isCompleted: isCompleted ?? this.isCompleted,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
    );
  }
}
