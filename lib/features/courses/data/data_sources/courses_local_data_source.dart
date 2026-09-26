import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/course_model.dart';

class CoursesLocalDataSource {
  Future<List<CourseModel>> getCourses() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/courses.json',
    );

    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final coursesJson = jsonData['courses'] as List;

    return coursesJson
        .map(
          (course) => CourseModel.fromJson(
            course as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}