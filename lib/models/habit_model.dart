import 'package:flutter/material.dart';

enum HabitFrequency { daily, weekly, custom }

class Habit {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final HabitFrequency frequency;
  final List<bool> completionStatus; // For the last 7 days
  final DateTime createdAt;
  final int goal; // Days or times per period
  final bool isQuantitative; // Whether this habit has a quantitative goal
  final double targetValue; // Quantitative target (e.g., 8 cups, 5000 steps)
  final double currentValue; // Current progress toward the target
  final String unit; // Unit of measurement (e.g., cups, pages, steps)

  Habit({
    required this.id,
    required this.title,
    this.description = '',
    required this.icon,
    required this.color,
    this.frequency = HabitFrequency.daily,
    required this.completionStatus,
    required this.createdAt,
    this.goal = 1,
    this.isQuantitative = false,
    this.targetValue = 0,
    this.currentValue = 0,
    this.unit = '',
  });

  int get daysCompleted => completionStatus.where((day) => day).length;

  double get progress =>
      completionStatus.isEmpty ? 0.0 : daysCompleted / completionStatus.length;

  double get quantitativeProgress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      frequency: HabitFrequency.values.byName(json['frequency']),
      completionStatus: List<bool>.from(json['completionStatus']),
      createdAt: DateTime.parse(json['createdAt']),
      goal: json['goal'] ?? 1,
      isQuantitative: json['isQuantitative'] ?? false,
      targetValue: json['targetValue']?.toDouble() ?? 0.0,
      currentValue: json['currentValue']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon.codePoint,
      'color': color.value,
      'frequency': frequency.name,
      'completionStatus': completionStatus,
      'createdAt': createdAt.toIso8601String(),
      'goal': goal,
      'isQuantitative': isQuantitative,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
    };
  }

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    HabitFrequency? frequency,
    List<bool>? completionStatus,
    DateTime? createdAt,
    int? goal,
    bool? isQuantitative,
    double? targetValue,
    double? currentValue,
    String? unit,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      completionStatus: completionStatus ?? this.completionStatus,
      createdAt: createdAt ?? this.createdAt,
      goal: goal ?? this.goal,
      isQuantitative: isQuantitative ?? this.isQuantitative,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
    );
  }
}
