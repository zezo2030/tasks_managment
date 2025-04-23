import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasks_managment/controller/habits_cubit/habit_cubit.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/core/router.dart';
import 'package:tasks_managment/models/habit_model.dart';

class HabitDetailHeader extends StatelessWidget {
  final Color habitColor;
  final VoidCallback onBack;
  final Habit habit;

  const HabitDetailHeader({
    super.key,
    required this.habitColor,
    required this.onBack,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildBackButton(), _buildActionButtons(context)],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back, size: 24),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(Icons.edit_outlined, AppColors.white, onTap: () {}),
        const SizedBox(width: 12),
        _buildActionButton(
          Icons.delete_outline,
          Colors.red.withOpacity(0.1),
          iconColor: Colors.red,
          onTap: () => _showDeleteConfirmation(context),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          Icons.settings_outlined,
          AppColors.white,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color backgroundColor, {
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 24, color: iconColor),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final habitCubit = context.read<HabitCubit>();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Habit'),
            content: const Text('Are you sure you want to delete this habit?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Delete the habit using the cubit
                  await habitCubit.deleteHabit(habit.id);

                  // Make sure to reload habits after deletion
                  await habitCubit.loadHabits();

                  // Close the dialog
                  Navigator.pop(ctx);

                  // Navigate back to the previous screen
                  context.pop();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
