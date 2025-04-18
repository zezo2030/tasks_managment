import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasks_managment/core/router.dart';
import 'package:tasks_managment/main.dart'; // Import to access getHabitCubit function

/// Helper class for navigating through the app using go_router
class NavigationHelper {
  /// Navigate to the onboarding screen
  static void navigateToOnboarding(BuildContext context) {
    GoRouter.of(context).go(AppRoutes.onboarding);
  }

  /// Navigate to the home screen
  static void navigateToHome(BuildContext context) {
    // Refresh habits when navigating to home
    getHabitCubit().loadHabits();
    GoRouter.of(context).go(AppRoutes.home);
  }

  /// Navigate to the habit tracker screen
  static void navigateToHabitTracker(BuildContext context) {
    // Refresh habits when navigating to habit tracker
    getHabitCubit().loadHabits();
    GoRouter.of(context).go(AppRoutes.habitTracker);
  }

  /// Navigate to the create habit screen
  static void navigateToCreateHabit(BuildContext context) {
    GoRouter.of(context).go(AppRoutes.createHabit);
  }

  /// Navigate to the day view screen
  static void navigateToDayView(BuildContext context) {
    GoRouter.of(context).go(AppRoutes.dayView);
  }

  /// Go back to the previous screen
  static void goBack(BuildContext context) {
    GoRouter.of(context).pop();
  }
}
