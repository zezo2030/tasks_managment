import 'package:flutter/material.dart';
import 'package:tasks_managment/models/habit_model.dart';
import 'package:tasks_managment/widgets/habit_tracker/standard_habit_card.dart';
import 'package:tasks_managment/widgets/habit_tracker/quantitative_habit_card.dart';

class HabitsList extends StatelessWidget {
  final List<Habit> habits;
  final Function(BuildContext, Habit) onHabitTap;
  final Function(String, int) onToggleCompletion;
  final Function(String, double) onUpdateQuantitativeProgress;
  final Animation<double> fadeAnimation;

  const HabitsList({
    super.key,
    required this.habits,
    required this.onHabitTap,
    required this.onToggleCompletion,
    required this.onUpdateQuantitativeProgress,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final delay = Duration(milliseconds: 100 * index);

        return FutureBuilder(
          future: Future.delayed(delay),
          builder: (context, snapshot) {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity:
                  snapshot.connectionState == ConnectionState.done ? 1.0 : 0.0,
              child: GestureDetector(
                onTap: () => onHabitTap(context, habit),
                child:
                    habit.isQuantitative
                        ? QuantitativeHabitCard(
                          habit: habit,
                          onUpdateProgress:
                              (value) =>
                                  onUpdateQuantitativeProgress(habit.id, value),
                        )
                        : StandardHabitCard(
                          habit: habit,
                          onToggleDay:
                              (index) => onToggleCompletion(habit.id, index),
                        ),
              ),
            );
          },
        );
      },
    );
  }
}
