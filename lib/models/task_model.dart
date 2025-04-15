import 'package:flutter/material.dart';

enum TaskCategory { mobileApp, webDesign, illustration, pending, other }

enum TaskStatus { ongoing, completed, pending }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final TaskCategory category;
  final TaskStatus status;
  final Color color;
  final int taskCount;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.status,
    required this.color,
    this.taskCount = 0,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      category: TaskCategory.values.byName(json['category']),
      status: TaskStatus.values.byName(json['status']),
      color: Color(json['color']),
      taskCount: json['taskCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'category': category.name,
      'status': status.name,
      'color': color.value,
      'taskCount': taskCount,
    };
  }
}
