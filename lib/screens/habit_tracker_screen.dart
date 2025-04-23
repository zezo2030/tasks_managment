import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasks_managment/controller/habits_cubit/habit_cubit.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/core/router.dart';
import 'package:tasks_managment/models/habit_model.dart';
import 'package:tasks_managment/screens/create_habit_screen.dart';
import 'package:tasks_managment/screens/habit_detail_screen.dart';
import 'package:tasks_managment/main.dart'; // Import to access getHabitCubit function
import 'package:tasks_managment/widgets/habit_tracker/header_widget.dart';
import 'package:tasks_managment/widgets/habit_tracker/stats_section.dart';
import 'package:tasks_managment/widgets/habit_tracker/habits_list.dart';

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    getHabitCubit().loadHabits();
  }

  void _setupAnimations() {
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getHabitCubit(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildBody() {
    return WillPopScope(
      onWillPop: () async {
        getHabitCubit().loadHabits();
        return true;
      },
      child: SafeArea(
        child: BlocConsumer<HabitCubit, HabitState>(
          listener: _habitStateListener,
          builder: (context, state) {
            List<Habit> habits = [];
            if (state is HabitLoaded) {
              habits = state.habits;
            }
            return _buildContent(habits);
          },
        ),
      ),
    );
  }

  void _habitStateListener(BuildContext context, HabitState state) {
    if (state is HabitError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildContent(List<Habit> habits) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderWidget(
            onBackPressed: () {
              getHabitCubit().loadHabits();
              context.pushReplacement(AppRoutes.home);
            },
          ),
          _buildTitleSection(),
          const SizedBox(height: 24),
          StatsSection(habits: habits),
          const SizedBox(height: 24),
          _buildHabitsHeader(),
          const SizedBox(height: 16),
          HabitsList(
            habits: habits,
            onHabitTap: _navigateToHabitDetail,
            onToggleCompletion:
                (habitId, index) =>
                    getHabitCubit().toggleHabitCompletion(habitId, index),
            onUpdateQuantitativeProgress:
                (habitId, value) =>
                    getHabitCubit().updateQuantitativeProgress(habitId, value),
            fadeAnimation: _fadeAnimation,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: const Text(
              'Habit Tracker',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Keep track of your daily habits and build consistency',
              style: TextStyle(color: AppColors.textLight, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Your Habits',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          TextButton.icon(
            onPressed: () => _navigateToCreateHabit(context),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              size: 18,
              color: AppColors.primaryColor,
            ),
            label: const Text(
              'Add New',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + 0.1 * _animationController.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => _navigateToCreateHabit(context),
              tooltip: 'Add New Habit',
              elevation: 0,
              backgroundColor: Colors.transparent,
              isExtended: true,
              extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: const Icon(
                Icons.add_circle_rounded,
                size: 26,
                color: Colors.white,
              ),
              label: const Text(
                'Add New Habit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              extendedIconLabelSpacing: 12,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigateToCreateHabit(BuildContext context) async {
    _animateButtonPress();

    final newHabit = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const CreateHabitScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _buildSlideTransition(animation, child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );

    if (newHabit != null) {
      getHabitCubit().addHabit(newHabit);
    }
  }

  void _animateButtonPress() {
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse().then(
        (_) => _animationController.forward(),
      );
    } else {
      _animationController.forward();
    }
  }

  SlideTransition _buildSlideTransition(
    Animation<double> animation,
    Widget child,
  ) {
    var begin = const Offset(1.0, 0.0);
    var end = Offset.zero;
    var curve = Curves.easeInOut;
    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    return SlideTransition(position: animation.drive(tween), child: child);
  }

  Future<void> _navigateToHabitDetail(BuildContext context, Habit habit) async {
    final updatedHabit = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                HabitDetailScreen(habit: habit),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _buildSlideTransition(animation, child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );

    if (updatedHabit != null && updatedHabit is Habit) {
      getHabitCubit().updateHabit(updatedHabit);
    }

    getHabitCubit().loadHabits();
  }
}
