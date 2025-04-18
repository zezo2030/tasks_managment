import 'package:flutter/material.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/models/habit_model.dart';

class StatisticsWidget extends StatelessWidget {
  final Habit habit;

  const StatisticsWidget({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              value: '5 days',
              icon: Icons.local_fire_department_rounded,
              color: AppColors.cardOrange,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              title: 'Longest Streak',
              value: '21 days',
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
              value: '15/20 days',
              icon: Icons.calendar_month_rounded,
              color: AppColors.cardBlue,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              title: 'Total',
              value: '45 days',
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
