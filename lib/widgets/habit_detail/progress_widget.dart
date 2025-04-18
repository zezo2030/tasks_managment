import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_managment/controller/habits_cubit/habit_cubit.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/models/habit_model.dart';
import 'package:tasks_managment/widgets/habit_detail/weekly_progress_widget.dart';

class HabitProgressWidget extends StatelessWidget {
  final Habit habit;

  const HabitProgressWidget({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return habit.isQuantitative
        ? _buildQuantitativeProgressSection(context)
        : _buildRegularProgressSection(context);
  }

  Widget _buildRegularProgressSection(BuildContext context) {
    final int successPercentage = (habit.progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Current Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              '$successPercentage% Completed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: habit.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildProgressBar(context, habit.progress),
        const SizedBox(height: 12),
        const Text(
          'This Week',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 12),
        WeeklyProgressWidget(habit: habit),
      ],
    );
  }

  Widget _buildQuantitativeProgressSection(BuildContext context) {
    final int progressPercentage = (habit.quantitativeProgress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Current Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              '$progressPercentage% Completed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: habit.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildProgressBar(context, habit.quantitativeProgress),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                habit.currentValue.toStringAsFixed(
                  habit.currentValue.truncateToDouble() == habit.currentValue
                      ? 0
                      : 1,
                ),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'out of ${habit.targetValue.toStringAsFixed(habit.targetValue.truncateToDouble() == habit.targetValue ? 0 : 1)} ${habit.unit}',
                style: TextStyle(fontSize: 16, color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onTap: () {
                      final newValue = (habit.currentValue - 1).clamp(
                        0.0,
                        double.infinity,
                      );
                      context.read<HabitCubit>().updateQuantitativeProgress(
                        habit.id,
                        newValue,
                      );
                    },
                  ),
                  _buildQuantityButton(
                    icon: Icons.add,
                    onTap: () {
                      context.read<HabitCubit>().updateQuantitativeProgress(
                        habit.id,
                        habit.currentValue + 1,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'This Week',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 12),
        WeeklyProgressWidget(habit: habit),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    return Stack(
      children: [
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Container(
          height: 12,
          width: (MediaQuery.of(context).size.width * progress - 48).clamp(
            0,
            double.infinity,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [habit.color, habit.color.withOpacity(0.7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: habit.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: habit.color, size: 32),
      ),
    );
  }
}
