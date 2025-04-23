import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:tasks_managment/controller/habits_cubit/habit_cubit.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/models/habit_model.dart';

class WeeklyProgressWidget extends StatefulWidget {
  final Habit habit;

  const WeeklyProgressWidget({super.key, required this.habit});

  @override
  State<WeeklyProgressWidget> createState() => _WeeklyProgressWidgetState();
}

class _WeeklyProgressWidgetState extends State<WeeklyProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Animation status tracking for each day
  final Map<int, bool> _animationActive = {};

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOutBack),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start pulse animation for today's circle
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
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
              .isNotEmpty)
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
              // Get today's index (0 = Monday, 6 = Sunday)
              final todayIndex = DateTime.now().weekday - 1;

              // Only allow interaction with today's habit
              if (index != todayIndex) {
                // Show message that only today's habit can be toggled
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'لا يمكن تعديل العادات السابقة أو القادمة، فقط اليوم الحالي متاح',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.grey[700],
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
                return;
              }

              if (index < widget.habit.completionStatus.length) {
                // Provide haptic feedback
                HapticFeedback.mediumImpact();

                // Track which day is being animated
                _animationActive[index] = true;

                // Play different animations based on current status
                if (!isCompleted) {
                  // Play completion animation - scale + rotate
                  _scaleController.reset();
                  _rotationController.reset();
                  _scaleController.forward();
                  _rotationController.forward().then((_) {
                    _animationActive[index] = false;
                  });
                } else {
                  // Play simpler animation for uncompleting
                  _scaleController.reset();
                  _scaleController.forward().then((_) {
                    _animationActive[index] = false;
                  });
                }

                // Toggle the completion status
                context.read<HabitCubit>().toggleHabitCompletion(
                  widget.habit.id,
                  index,
                );

                // Show feedback message
                final bool willBeCompleted = !isCompleted;
                Future.delayed(const Duration(milliseconds: 300), () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        willBeCompleted
                            ? 'Habit marked as completed! 🎉'
                            : 'Habit marked as incomplete',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor:
                          willBeCompleted
                              ? widget.habit.color
                              : Colors.grey[600],
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                });
              }
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _scaleAnimation,
                _rotationAnimation,
                _pulseAnimation,
              ]),
              builder: (context, child) {
                // Apply different animations based on state
                double scale = 1.0;
                double rotation = 0.0;

                // Apply correct animation based on active status and completion
                if (_animationActive[index] == true) {
                  scale = _scaleAnimation.value;
                  rotation = !isCompleted ? _rotationAnimation.value : 0.0;
                } else if (isToday) {
                  // Apply gentle pulse to today's circle
                  scale = _pulseAnimation.value;
                }

                // Determine if this day is interactive
                final bool isInteractive = index == DateTime.now().weekday - 1;

                // Determine if this day is in the future
                final bool isFutureDay = index > DateTime.now().weekday - 1;

                // Determine if this day is in the past and not completed
                final bool isPastDayNotCompleted =
                    !isFutureDay && !isToday && !isCompleted;

                return Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: rotation,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isToday ? 42 : 36,
                      height: isToday ? 42 : 36,
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? widget.habit.color
                                : isFutureDay
                                ? Colors.grey.withOpacity(0.1)
                                : widget.habit.color.withOpacity(
                                  isInteractive ? 0.1 : 0.05,
                                ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.habit.color.withOpacity(
                              isToday ? 0.4 : (isCompleted ? 0.3 : 0.1),
                            ),
                            spreadRadius: isToday ? 2 : 0,
                            blurRadius: isToday ? 6 : 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color:
                              isToday
                                  ? widget.habit.color
                                  : (isCompleted
                                      ? Colors.transparent
                                      : isFutureDay
                                      ? Colors.grey.withOpacity(0.3)
                                      : widget.habit.color.withOpacity(
                                        isInteractive ? 0.3 : 0.1,
                                      )),
                          width: isToday ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (
                              Widget child,
                              Animation<double> animation,
                            ) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child:
                                isCompleted
                                    ? Icon(
                                      Icons.check,
                                      key: const ValueKey('check'),
                                      size: isToday ? 24 : 20,
                                      color: Colors.white,
                                    )
                                    : SizedBox(
                                      key: const ValueKey('empty'),
                                      width: isToday ? 24 : 20,
                                      height: isToday ? 24 : 20,
                                    ),
                          ),
                          // Show lock icon for past days that are not completed
                          if (isPastDayNotCompleted)
                            Opacity(
                              opacity: 0.6,
                              child: Icon(
                                Icons.lock,
                                size: 14,
                                color: widget.habit.color.withOpacity(0.7),
                              ),
                            ),
                          // Show today's lock if not completed
                          // if (isToday && !isCompleted)
                          //   Opacity(
                          //     opacity: 0.7,
                          //     child: Icon(
                          //       Icons.lock,
                          //       size: 14,
                          //       color: widget.habit.color,
                          //     ),
                          //   ),
                          // Show clock icon for future days
                          if (isFutureDay)
                            Opacity(
                              opacity: 0.6,
                              child: Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
