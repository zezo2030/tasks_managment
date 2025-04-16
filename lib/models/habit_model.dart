import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
enum HabitFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  custom,
}

@HiveType(typeId: 1)
class Habit {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int iconData;

  @HiveField(4)
  final int colorValue;

  @HiveField(5)
  final HabitFrequency frequency;

  @HiveField(6)
  final List<bool> completionStatus;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final int goal;

  @HiveField(9)
  final bool isQuantitative;

  @HiveField(10)
  final double targetValue;

  @HiveField(11)
  final double currentValue;

  @HiveField(12)
  final String unit;

  // Getters for IconData and Color (not stored directly in Hive)
  IconData get icon => IconData(iconData, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  Habit({
    required this.id,
    required this.title,
    this.description = '',
    required IconData icon,
    required Color color,
    this.frequency = HabitFrequency.daily,
    required this.completionStatus,
    required this.createdAt,
    this.goal = 1,
    this.isQuantitative = false,
    this.targetValue = 0,
    this.currentValue = 0,
    this.unit = '',
  }) : iconData = icon.codePoint,
       colorValue = color.value;

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
      'icon': iconData,
      'color': colorValue,
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
