import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:tasks_managment/controller/habits_cubit/habit_cubit.dart';
import 'package:tasks_managment/models/habit_model.dart';

class CompletionButton extends StatefulWidget {
  final Habit habit;
  final Function() onCompleted;

  const CompletionButton({
    super.key,
    required this.habit,
    required this.onCompleted,
  });

  @override
  State<CompletionButton> createState() => _CompletionButtonState();
}

class _CompletionButtonState extends State<CompletionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

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

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * math.pi,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        (widget.habit.completionStatus.length >
                                    (DateTime.now().weekday - 1) &&
                                widget.habit.completionStatus[DateTime.now()
                                        .weekday -
                                    1])
                            ? Colors.green.withOpacity(0.4)
                            : widget.habit.color.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  // Get today's weekday index (0-6)
                  final todayIndex = DateTime.now().weekday - 1; // 0 = Monday

                  // Check if we're trying to complete today's habit
                  // If the index is not for today, show error message and return
                  if (todayIndex != widget.habit.completionStatus.length - 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'لا يمكن تعديل العادات السابقة، فقط اليوم متاح',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.deepPurple.shade400,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        elevation: 4,
                        margin: EdgeInsets.all(12),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                    return;
                  }

                  // Check if completion status has enough entries
                  final bool isCompleted =
                      todayIndex < widget.habit.completionStatus.length
                          ? !(widget.habit.completionStatus[todayIndex])
                          : true;

                  // Play animation
                  if (isCompleted) {
                    _animController.reset();
                    _animController.forward();

                    // Call the callback to show confetti
                    widget.onCompleted();
                  }

                  final newStatus = List<bool>.from(
                    widget.habit.completionStatus,
                  );

                  // Update today's status
                  if (todayIndex < newStatus.length) {
                    newStatus[todayIndex] = isCompleted;
                  }

                  // Update via cubit
                  final updatedHabit = widget.habit.copyWith(
                    completionStatus: newStatus,
                  );
                  context.read<HabitCubit>().updateHabit(updatedHabit);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isCompleted
                            ? 'Habit completed for today! 🎉'
                            : 'Marked as not completed for today',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: isCompleted ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
                backgroundColor:
                    // Use current day's completion status
                    widget.habit.completionStatus.length >
                                (DateTime.now().weekday - 1) &&
                            widget
                                .habit
                                .completionStatus[DateTime.now().weekday - 1]
                        ? Colors.green
                        : widget.habit.color,
                elevation: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      // Use current day's completion status
                      widget.habit.completionStatus.length >
                                  (DateTime.now().weekday - 1) &&
                              widget
                                  .habit
                                  .completionStatus[DateTime.now().weekday - 1]
                          ? Icons.check
                          : Icons.add,
                      size: 32,
                      color: Colors.white,
                    ),
                    if (widget.habit.completionStatus.length >
                            (DateTime.now().weekday - 1) &&
                        widget.habit.completionStatus[DateTime.now().weekday -
                            1])
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 2,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
