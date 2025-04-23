import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasks_managment/screens/create_habit_screen.dart';
import 'package:tasks_managment/screens/day_view_screen.dart';
import 'package:tasks_managment/screens/habit_tracker_screen.dart';
import 'package:tasks_managment/screens/home_screen.dart';
import 'package:tasks_managment/screens/onboarding_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

// Define route names as constants for easier reference
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String habitTracker = '/habit_tracker';
  static const String createHabit = '/create-habit';
  static const String habitDetail = '/habit-detail';
  static const String dayView = '/day-view';
}

// Custom page builder with transition animations
Page<dynamic> _buildPageWithAnimation(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Fade and slide transition from right to left
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder:
          (context, state) =>
              _buildPageWithAnimation(context, state, const OnboardingScreen()),
    ),
    GoRoute(
      path: AppRoutes.home,
      pageBuilder:
          (context, state) =>
              _buildPageWithAnimation(context, state, const HomeScreen()),
    ),
    GoRoute(
      path: AppRoutes.habitTracker,
      pageBuilder:
          (context, state) => _buildPageWithAnimation(
            context,
            state,
            const HabitTrackerScreen(),
          ),
    ),
    GoRoute(
      path: AppRoutes.createHabit,
      pageBuilder:
          (context, state) => _buildPageWithAnimation(
            context,
            state,
            const CreateHabitScreen(),
          ),
    ),
    GoRoute(
      path: AppRoutes.habitDetail,
      pageBuilder: (context, state) {
        // Note: Your HabitDetailScreen requires a Habit object
        // In a real implementation, you would need to:
        // 1. Create a service to fetch a habit by ID
        // 2. Use that service here to retrieve the habit
        // 3. Then pass it to the HabitDetailScreen
        // For demonstration purposes, we're showing a placeholder
        return _buildPageWithAnimation(
          context,
          state,
          Scaffold(
            body: Center(
              child: Text(
                'To use go_router with HabitDetailScreen, you need to implement a way to get a Habit by ID',
              ),
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.dayView,
      pageBuilder:
          (context, state) =>
              _buildPageWithAnimation(context, state, const DayViewScreen()),
    ),
  ],
  errorPageBuilder:
      (context, state) => _buildPageWithAnimation(
        context,
        state,
        Scaffold(body: Center(child: Text('Route not found: ${state.error}'))),
      ),
);
