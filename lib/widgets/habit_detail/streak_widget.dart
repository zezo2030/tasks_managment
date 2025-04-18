import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/models/habit_model.dart';

class StreakWidget extends StatefulWidget {
  final Habit habit;

  const StreakWidget({Key? key, required this.habit}) : super(key: key);

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget>
    with SingleTickerProviderStateMixin {
  late final DateTime _today = DateTime.now();
  // Mock data for demonstration
  final int currentStreak = 5;
  final int bestStreak = 21;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Streak',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              builder: (context, double value, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardOrange.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, double val, child) {
                          return Transform.scale(
                            scale: 1.0 + val * math.sin(value * 10) * 0.1,
                            child: const Icon(
                              Icons.local_fire_department_rounded,
                              color: AppColors.cardOrange,
                              size: 18,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$currentStreak days',
                        style: const TextStyle(
                          color: AppColors.cardOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
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
              // Animated bar chart visualization
              SizedBox(
                height: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(10, (index) {
                    final isActive = index < currentStreak;
                    final barHeight = 30 + (index % 3) * 10.0;

                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 500 + (index * 100)),
                      curve: Curves.elasticOut,
                      builder: (context, double value, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 5,
                              height: barHeight * value,
                              decoration: BoxDecoration(
                                color:
                                    isActive
                                        ? widget.habit.color
                                        : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow:
                                    isActive
                                        ? [
                                          BoxShadow(
                                            color: widget.habit.color
                                                .withOpacity(0.2),
                                            blurRadius: 3,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontWeight:
                                    isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isActive
                                        ? AppColors.textDark
                                        : AppColors.textLight,
                              ),
                              child: Text('${_today.day - 9 + index}'),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 25),
              // Add an achievement badge for current streak
              if (currentStreak >= 5)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.habit.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.habit.color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: widget.habit.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievement Unlocked!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.habit.color,
                            ),
                          ),
                          const Text(
                            'Maintained 5-day streak',
                            style: TextStyle(color: AppColors.textLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Keep going! You\'re on a $currentStreak-day streak',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your best streak is $bestStreak days',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.workspace_premium_rounded,
                    size: 16,
                    color: Colors.amber,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
