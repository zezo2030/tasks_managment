import 'package:flutter/material.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/models/habit_model.dart';

class StatisticsWidget extends StatelessWidget {
  final Habit habit;

  const StatisticsWidget({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final statuses = habit.completionStatus;
    final createdAt = habit.createdAt;

    // Get today's weekday index (0 = Monday, 6 = Sunday)
    final todayWeekdayIndex = today.weekday - 1;

    // Calculate the current streak by counting consecutive completed days up to today
    int currentStreak = 0;

    // Check if habit has any completion statuses
    if (statuses.isNotEmpty) {
      // Calculate days since creation
      final daysSinceCreation = today.difference(createdAt).inDays;

      // Start from today and check backwards for consecutive completed days
      int daysToCheck = statuses.length - 1; // Last index in the status array

      // Check if today's habit is completed
      if (todayWeekdayIndex < statuses.length && statuses[todayWeekdayIndex]) {
        currentStreak = 1;

        // Check previous days
        int prevDay = todayWeekdayIndex - 1;
        if (prevDay < 0) prevDay = 6; // Wrap around to Sunday if needed

        // Go back through previous days checking for consecutive completions
        for (int i = 1; i <= daysSinceCreation && i < statuses.length; i++) {
          if (prevDay >= 0 && prevDay < statuses.length && statuses[prevDay]) {
            currentStreak++;
            prevDay--;
            if (prevDay < 0) prevDay = 6; // Wrap around to Sunday
          } else {
            break; // Break on first uncompleted day
          }
        }
      }
    }

    // Compute longest streak correctly
    int longestStreak = 0;
    int tempStreak = 0;
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i]) {
        tempStreak++;
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        tempStreak = 0;
      }
    }

    // Compute this month's completions
    final currentMonth = today.month;
    final currentYear = today.year;
    int monthCompletions = 0;
    int daysInMonth = 0;

    // Calculate days in current month
    for (int i = 0; i < statuses.length; i++) {
      final date = createdAt.add(Duration(days: i));
      if (date.month == currentMonth && date.year == currentYear) {
        daysInMonth++;
        if (statuses[i]) {
          monthCompletions++;
        }
      }
    }

    // If the habit was created this month, use days since creation
    // Otherwise use days in month so far
    final daysSoFar = daysInMonth > 0 ? daysInMonth : today.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              title: 'Current Streak',
              value: '$currentStreak days',
              icon: Icons.local_fire_department_rounded,
              color: AppColors.cardOrange,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              title: 'Longest Streak',
              value: '$longestStreak days',
              icon: Icons.emoji_events_rounded,
              color: AppColors.cardPurple,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              title: 'This Month',
              value: '$monthCompletions/$daysSoFar days',
              icon: Icons.calendar_month_rounded,
              color: AppColors.cardBlue,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              title: 'Total',
              value: '${habit.daysCompleted} days',
              icon: Icons.bar_chart_rounded,
              color: AppColors.cardPink,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
