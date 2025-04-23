import 'package:flutter/material.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/models/habit_model.dart';
import 'package:tasks_managment/widgets/habit_tracker/stat_card.dart';

class StatsSection extends StatelessWidget {
  final List<Habit> habits;

  const StatsSection({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    // Get today's index (0 = Monday, 6 = Sunday)
    final todayIndex = DateTime.now().weekday - 1;

    // Count how many habits are completed today
    int completedToday = 0;

    for (final habit in habits) {
      if (habit.completionStatus.isNotEmpty) {
        // Check if today's index is within bounds
        if (todayIndex < habit.completionStatus.length) {
          // Check if today's habit is completed
          if (habit.completionStatus[todayIndex]) {
            completedToday++;
          }
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          StatCard(
            title: 'Total Habits',
            value: habits.length.toString(),
            icon: Icons.list_alt_rounded,
            color: AppColors.cardBlue,
          ),
          const SizedBox(width: 16),
          StatCard(
            title: 'Today Completed',
            value: '$completedToday/${habits.length}',
            icon: Icons.today_rounded,
            color: AppColors.cardPink,
          ),
        ],
      ),
    );
  }
}
