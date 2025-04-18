import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_managment/controller/habits_cubit/habit_cubit.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/models/habit_model.dart';
import 'package:tasks_managment/main.dart'; // Import main.dart to access the global habitCubit
import 'package:tasks_managment/widgets/habit_detail/header_widget.dart';
import 'package:tasks_managment/widgets/habit_detail/habit_info_widget.dart';
import 'package:tasks_managment/widgets/habit_detail/progress_widget.dart';
import 'package:tasks_managment/widgets/habit_detail/monthly_calendar_widget.dart';
import 'package:tasks_managment/widgets/habit_detail/statistics_widget.dart';
import 'package:tasks_managment/widgets/habit_detail/streak_widget.dart';
import 'package:tasks_managment/widgets/habit_detail/confetti_widget.dart';
import 'package:tasks_managment/widgets/habit_detail/completion_button.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Habit _habit;

  // To track confetti animation
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showConfettiAnimation() {
    setState(() {
      _showConfetti = true;
    });

    // Hide confetti after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showConfetti = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the global habitCubit and update it with the current habit
    getHabitCubit().updateHabit(_habit);

    return BlocProvider.value(
      value: getHabitCubit(),
      child: BlocConsumer<HabitCubit, HabitState>(
        listener: (context, state) {
          if (state is HabitUpdated) {
            _habit = state.habit;
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HabitDetailHeader(
                          habitColor: _habit.color,
                          onBack: () {
                            context.read<HabitCubit>().loadHabits();
                            Navigator.pop(context);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HabitInfoWidget(
                                habit: _habit,
                                fadeAnimation: _fadeAnimation,
                              ),
                              const SizedBox(height: 24),
                              HabitProgressWidget(habit: _habit),
                              const SizedBox(height: 30),
                              MonthlyCalendarWidget(habit: _habit),
                              const SizedBox(height: 30),
                              StatisticsWidget(habit: _habit),
                              const SizedBox(height: 30),
                              StreakWidget(habit: _habit),
                              const SizedBox(
                                height: 80,
                              ), // Add space for the floating action button
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Confetti Animation
                  if (_showConfetti)
                    ConfettiAnimation(habitColor: _habit.color),
                ],
              ),
            ),
            floatingActionButton:
                _habit.isQuantitative
                    ? null
                    : CompletionButton(
                      habit: _habit,
                      onCompleted: _showConfettiAnimation,
                    ),
          );
        },
      ),
    );
  }
}
