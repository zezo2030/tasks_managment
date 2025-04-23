// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tasks_managment/main.dart';
import 'package:tasks_managment/services/habit_storage_service.dart';
import 'package:tasks_managment/services/notification_service.dart';

void main() {
  setUp(() async {
    // Initialize Hive for testing
    await Hive.initFlutter('./test/hive_testing');
  });

  tearDown(() async {
    // Clean up after each test
    await Hive.deleteFromDisk();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create a test storage service
    final habitStorageService = HabitStorageService();
    await habitStorageService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(
        habitStorageService: habitStorageService,
        notificationService: NotificationService(),
      ),
    );

    // Skip the rest of the tests for now, as they're specific to the counter example
    // and our app is a habit tracker
  });
}
