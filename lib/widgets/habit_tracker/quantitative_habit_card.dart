import 'package:flutter/material.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/models/habit_model.dart';

class QuantitativeHabitCard extends StatelessWidget {
  final Habit habit;
  final Function(double) onUpdateProgress;

  const QuantitativeHabitCard({
    super.key,
    required this.habit,
    required this.onUpdateProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: habit.color.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildProgressSection(),
          const SizedBox(height: 12),
          _buildProgressBar(),
          const SizedBox(height: 16),
          _buildQuantitativeControls(context),
          const SizedBox(height: 16),
          _buildDayStatus(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Check if today's habit is completed
    final todayIndex = DateTime.now().weekday - 1;
    final todayCompleted =
        todayIndex < habit.completionStatus.length
            ? habit.completionStatus[todayIndex]
            : false;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: habit.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(habit.icon, color: habit.color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      habit.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                habit.description,
                style: TextStyle(color: AppColors.textLight, fontSize: 14),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: habit.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Daily',
            style: TextStyle(
              color: habit.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Progress:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(habit.quantitativeProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: habit.color,
              ),
            ),
          ],
        ),
        Text(
          '${habit.currentValue.toStringAsFixed(habit.currentValue.truncateToDouble() == habit.currentValue ? 0 : 1)}/${habit.targetValue.toStringAsFixed(habit.targetValue.truncateToDouble() == habit.targetValue ? 0 : 1)} ${habit.unit}',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Stack(
      children: [
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            return Container(
              height: 10,
              width: maxWidth * habit.quantitativeProgress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [habit.color, habit.color.withOpacity(0.7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDayStatus() {
    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    // Get today's index (0 = Monday, 6 = Sunday)
    final todayIndex = DateTime.now().weekday - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final isCompleted =
            index < habit.completionStatus.length
                ? habit.completionStatus[index]
                : false;

        // Determine if this day is today, in the past, or in the future
        final isPastOrToday = index <= todayIndex;
        final isFutureDay = index > todayIndex;

        return Flexible(
          fit: FlexFit.tight,
          child: Column(
            children: [
              Text(
                weekDays[index],
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color:
                      isCompleted
                          ? habit.color
                          : isFutureDay
                          ? Colors.grey.withOpacity(0.1)
                          : habit.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isCompleted
                            ? Colors.transparent
                            : isFutureDay
                            ? Colors.grey.withOpacity(0.3)
                            : habit.color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child:
                    isCompleted
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : isPastOrToday && !isCompleted
                        ? (index == todayIndex)
                            ? null
                            : Icon(
                              Icons.lock,
                              size: 12,
                              color: habit.color.withOpacity(0.7),
                            )
                        : isFutureDay
                        ? Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey.withOpacity(0.7),
                        )
                        : null,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQuantitativeControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.remove_circle_outline,
          onTap: () {
            final newValue = (habit.currentValue - 1).clamp(
              0.0,
              double.infinity,
            );
            onUpdateProgress(newValue);
          },
        ),
        const SizedBox(width: 24),
        Column(
          children: [
            Text(
              habit.currentValue.toStringAsFixed(
                habit.currentValue.truncateToDouble() == habit.currentValue
                    ? 0
                    : 1,
              ),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              habit.unit,
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
          ],
        ),
        const SizedBox(width: 24),
        _buildControlButton(
          icon: Icons.add_circle_outline,
          onTap: () {
            final newValue = habit.currentValue + 1;
            onUpdateProgress(newValue);
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: habit.color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: habit.color, size: 32),
      ),
    );
  }
}
