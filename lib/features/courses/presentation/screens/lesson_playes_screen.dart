import 'package:chewie/chewie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:thaheen_task/core/di/dependency_injection.dart';
import 'package:thaheen_task/core/extensions/navigation_extensions.dart';
import 'package:thaheen_task/core/routing/routes.dart';
import 'package:thaheen_task/core/theme/app_colors.dart';
import 'package:thaheen_task/core/translations/locale_keys.g.dart';
import 'package:thaheen_task/features/courses/data/data_sources/lesson_progress_local_data_source.dart';
import 'package:thaheen_task/features/courses/data/models/lesson_model.dart';
import 'package:thaheen_task/features/courses/data/models/lesson_progress_model.dart';
import 'package:video_player/video_player.dart';

class LessonPlayerScreen extends StatefulWidget {
  final LessonModel lesson;
  final String courseId;
  final List<LessonModel> allLessons;
  final int currentIndex;

  const LessonPlayerScreen({
    super.key,
    required this.lesson,
    required this.courseId,
    required this.allLessons,
    required this.currentIndex,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late final VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasVideoError = false;
  bool _isCompleted = false;

  final LessonProgressLocalDataSource _progressDataSource = sl();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoPlayerController = VideoPlayerController.asset(widget.lesson.video);
      await _videoPlayerController.initialize();

      final savedProgress =
          _progressDataSource.getLessonProgress(widget.lesson.id);
      if (savedProgress != null && savedProgress.lastPositionSec > 0) {
        _isCompleted = savedProgress.isCompleted;

        await _videoPlayerController.seekTo(
          Duration(seconds: savedProgress.lastPositionSec),
        );
      }

      _videoPlayerController.addListener(_onVideoPlaybackUpdated);

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
      );

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _hasVideoError = true);
    }
  }

  void _onVideoPlaybackUpdated() {
    final position = _videoPlayerController.value.position.inSeconds;
    final duration = _videoPlayerController.value.duration.inSeconds;

    if (duration > 0) {
      final percentage = position / duration;
      if (percentage >= 0.90 && !_isCompleted) {
        _isCompleted = true;
        _saveProgress(isCompleted: true);
        if (mounted) setState(() {}); 
      }
    }
  }

  void _saveProgress({bool? isCompleted}) {
    final position = _videoPlayerController.value.position.inSeconds;
    final duration = _videoPlayerController.value.duration.inSeconds;

    _progressDataSource.saveProgress(
      LessonProgressModel(
        lessonId: widget.lesson.id,
        courseId: widget.courseId,
        lastPositionSec: position,
        totalDurationSec: duration > 0 ? duration : widget.lesson.durationSec,
        isCompleted: isCompleted ?? _isCompleted,
        lastWatchedAt: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _saveProgress();
    _videoPlayerController.removeListener(_onVideoPlaybackUpdated);
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _onNextLessonPressed() {
    final hasNext = widget.currentIndex < widget.allLessons.length - 1;
    if (!hasNext) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تهانينا! لقد أنهيت جميع الدروس')),
      );
      return;
    }

    if (!_isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(LocaleKeys.finishAllLessons.tr()),
        ),
      );
      return;
    }

    final nextIndex = widget.currentIndex + 1;
    final nextLesson = widget.allLessons[nextIndex];

    context.pushReplacementNamed(
      Routes.lessonPlayerScreen,
      arguments: {
        'lesson': nextLesson,
        'courseId': widget.courseId,
        'allLessons': widget.allLessons,
        'currentIndex': nextIndex,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNext = widget.currentIndex < widget.allLessons.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.titleAr)),
      body: (_hasVideoError)
          ? Center(
              child: Text(
              LocaleKeys.error.tr(),
              style: TextStyle(color: AppColor.red),
            ))
          : _chewieController == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: Chewie(controller: _chewieController!),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed: hasNext ? _onNextLessonPressed : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCompleted
                              ? AppColor.primaryColor
                              : Colors.grey,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          hasNext ? LocaleKeys.nextLesson.tr() : LocaleKeys.finishCourse.tr(),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
