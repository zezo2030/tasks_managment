import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_managment/controller/habits_cubit/habit_cubit.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/models/habit_model.dart';

class WeeklyProgressWidget extends StatefulWidget {
  final Habit habit;

  const WeeklyProgressWidget({Key? key, required this.habit}) : super(key: key);

  @override
  State<WeeklyProgressWidget> createState() => _WeeklyProgressWidgetState();
}

class _WeeklyProgressWidgetState extends State<WeeklyProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current day of week (1-7, where 1 is Monday and 7 is Sunday)
    final today = DateTime.now();
    final currentDayOfWeek = today.weekday;

    // Create a list of days starting from Monday
    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Weekly Habit Tracker',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.habit.color,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              // Determine if this is the current day
              final isToday = index + 1 == currentDayOfWeek;

              // Get completion status
              final isCompleted =
                  index < widget.habit.completionStatus.length
                      ? widget.habit.completionStatus[index]
                      : false;

              return _buildDayWidget(
                context,
                weekDays[index],
                index,
                isToday,
                isCompleted,
              );
            }),
          ),
          // Add completion streak under weekly progress
          if (widget.habit.completionStatus
                  .where((completed) => completed)
                  .length >
              0)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.habit.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: widget.habit.color,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.habit.completionStatus.where((completed) => completed).length} days completed this week!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.habit.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayWidget(
    BuildContext context,
    String dayText,
    int index,
    bool isToday,
    bool isCompleted,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: isToday ? 16 : 14,
              color: isToday ? widget.habit.color : AppColors.textLight,
              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            ),
            child: Text(dayText),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              if (index < widget.habit.completionStatus.length) {
                // Show ripple animation when tapped
                _animController.reset();
                _animController.forward();

                context.read<HabitCubit>().toggleHabitCompletion(
                  widget.habit.id,
                  index,
                );

                // Show confetti notification using parent's callback
                if (!widget.habit.completionStatus[index]) {
                  // You could add a callback to parent to show confetti
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isToday ? 40 : 35,
              height: isToday ? 40 : 35,
              decoration: BoxDecoration(
                color:
                    isCompleted
                        ? widget.habit.color
                        : widget.habit.color.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow:
                    isToday
                        ? [
                          BoxShadow(
                            color: widget.habit.color.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
                border: Border.all(
                  color:
                      isToday
                          ? widget.habit.color
                          : (isCompleted
                              ? Colors.transparent
                              : widget.habit.color.withOpacity(0.3)),
                  width: isToday ? 2 : 1,
                ),
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isCompleted ? 1.0 : 0.0,
                  child: Icon(
                    Icons.check,
                    size: isToday ? 24 : 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Add small dot below today
          if (isToday)
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: widget.habit.color,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
