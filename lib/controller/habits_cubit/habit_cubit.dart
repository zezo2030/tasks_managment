import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tasks_managment/models/habit_model.dart';
import 'package:tasks_managment/services/habit_storage_service.dart';
import 'package:tasks_managment/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

part 'habit_state.dart';

class HabitCubit extends Cubit<HabitState> {
  final HabitStorageService _storageService;
  final NotificationService _notificationService;
  List<Habit> _habits = [];

  HabitCubit({
    HabitStorageService? storageService,
    NotificationService? notificationService,
  }) : _storageService = storageService ?? HabitStorageService(),
       _notificationService = notificationService ?? NotificationService(),
       super(HabitInitial()) {
    loadHabits();
    checkForDailyReset();
    _requestExactAlarmPermissionIfNeeded();
  }

  // Request exact alarm permission for Android 13+
  Future<void> _requestExactAlarmPermissionIfNeeded() async {
    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      final androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        await androidImplementation.requestExactAlarmsPermission();
      }
    } catch (e) {
      // Permission request might fail on older Android versions
      emit(
        HabitError('Failed to request exact alarm permission: ${e.toString()}'),
      );
    }
  }

  // Load all habits and emit HabitLoaded state
  Future<void> loadHabits() async {
    emit(HabitLoading());
    try {
      // Ensure storage service is initialized
      await _storageService.init();

      // Try to load from storage
      _habits = _storageService.getAllHabits();

      // If no habits found in storage, initialize with default habits
      if (_habits.isEmpty) {
        _initializeDefaultHabits();
        // Save default habits to storage
        for (var habit in _habits) {
          await _storageService.addHabit(habit);
        }
      }

      emit(HabitLoaded(_habits));
      print("Habits loaded: ${_habits.length}");
    } catch (e) {
      emit(HabitError('Failed to load habits: ${e.toString()}'));
    }
  }

  // Check if we need to reset habits for a new day
  Future<void> checkForDailyReset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastResetDate = prefs.getString('lastHabitResetDate');
      final today =
          DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format

      // If we haven't reset today, do it now
      if (lastResetDate != today) {
        await resetDailyHabits();
        // Save today's date as last reset date
        await prefs.setString('lastHabitResetDate', today);
      }
    } catch (e) {
      emit(HabitError('Failed to check for daily reset: ${e.toString()}'));
    }
  }

  // Reset daily habits and mark unfinished ones as incomplete
  Future<void> resetDailyHabits() async {
    try {
      final updatedHabits = <Habit>[];
      bool anyChanges = false;
      int incompleteHabits = 0;
      List<String> incompleteHabitNames = [];

      for (final habit in _habits) {
        // Only process daily habits
        if (habit.frequency == HabitFrequency.daily) {
          final completionStatus = List<bool>.from(habit.completionStatus);

          // Check the last day's completion status (yesterday)
          // If it's not completed, it will remain false in the history
          if (completionStatus.isNotEmpty && !completionStatus.last) {
            anyChanges = true;
            incompleteHabits++;
            incompleteHabitNames.add(habit.title);
          }

          // Add new day with uncompleted status (today)
          final updatedStatus = [...completionStatus, false];
          final updatedHabit = habit.copyWith(completionStatus: updatedStatus);
          updatedHabits.add(updatedHabit);

          // Save the updated habit to storage
          await _storageService.updateHabit(updatedHabit);
        } else {
          // For non-daily habits, just keep them as is
          updatedHabits.add(habit);
        }
      }

      // If there were incomplete habits, send a notification
      if (incompleteHabits > 0) {
        String body =
            incompleteHabits == 1
                ? 'You missed completing "${incompleteHabitNames[0]}" yesterday'
                : 'You missed completing $incompleteHabits habits yesterday';

        await _notificationService.scheduleHabitIncompletionReminder(
          id: 2,
          title: 'Incomplete Habits',
          body: body,
          time: TimeOfDay.now(),
        );
      }

      if (anyChanges || updatedHabits.isNotEmpty) {
        // Update the habits list and emit updated state
        _habits = updatedHabits;
        emit(HabitLoaded(_habits));
      }
    } catch (e) {
      emit(HabitError('Failed to reset daily habits: ${e.toString()}'));
    }
  }

  // Add a new habit
  Future<void> addHabit(Habit habit) async {
    emit(HabitLoading());
    try {
      await _storageService.addHabit(habit);
      _habits.add(habit);
      emit(HabitLoaded(_habits));
      emit(HabitAdded(habit));
      print("Habit added: ${habit.title}");
    } catch (e) {
      emit(HabitError('Failed to add habit: ${e.toString()}'));
    }
  }

  // Update an existing habit
  Future<void> updateHabit(Habit updatedHabit) async {
    emit(HabitLoading());
    try {
      await _storageService.updateHabit(updatedHabit);
      final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
      if (index != -1) {
        _habits[index] = updatedHabit;
        emit(HabitLoaded(_habits));
        emit(HabitUpdated(updatedHabit));
      } else {
        emit(HabitError('Habit not found'));
      }
    } catch (e) {
      emit(HabitError('Failed to update habit: ${e.toString()}'));
      // Re-initialize storage if box was closed
      if (e.toString().contains('Box has already been closed')) {
        await _storageService.init();
        emit(HabitLoaded(_habits));
      }
    }
  }

  // Delete a habit by ID
  Future<void> deleteHabit(String habitId) async {
    emit(HabitLoading());
    try {
      await _storageService.deleteHabit(habitId);
      _habits.removeWhere((h) => h.id == habitId);
      emit(HabitLoaded(_habits));
      emit(HabitDeleted(habitId));
    } catch (e) {
      emit(HabitError('Failed to delete habit: ${e.toString()}'));
      // Re-initialize storage if box was closed
      if (e.toString().contains('Box has already been closed')) {
        await _storageService.init();
        emit(HabitLoaded(_habits));
      }
    }
  }

  // Toggle habit completion for a specific day
  Future<void> toggleHabitCompletion(String habitId, int dayIndex) async {
    try {
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1 && dayIndex < _habits[index].completionStatus.length) {
        final habit = _habits[index];
        final newStatus = List<bool>.from(habit.completionStatus);
        newStatus[dayIndex] = !newStatus[dayIndex];

        final updatedHabit = habit.copyWith(completionStatus: newStatus);
        await updateHabit(updatedHabit);
      }
    } catch (e) {
      emit(HabitError('Failed to toggle completion: ${e.toString()}'));
      // Re-initialize storage if box was closed
      if (e.toString().contains('Box has already been closed')) {
        await _storageService.init();
      }
    }
  }

  // Update quantitative habit progress
  Future<void> updateQuantitativeProgress(
    String habitId,
    double newValue,
  ) async {
    try {
      // First get a copy of the current state to avoid losing habits
      final currentHabits = _habits;

      // Find the habit to update
      final index = currentHabits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        final habit = currentHabits[index];
        if (habit.isQuantitative) {
          final clampedValue = newValue.clamp(0.0, double.infinity);

          // Create updated habit with new value
          final updatedHabit = habit.copyWith(currentValue: clampedValue);

          // Update local list first before calling storage
          currentHabits[index] = updatedHabit;
          _habits = currentHabits;

          // Emit loaded state immediately to ensure UI updates
          emit(HabitLoaded(List.from(_habits)));

          // Then update storage (and handle any storage errors)
          await _storageService.updateHabit(updatedHabit);
        }
      }
    } catch (e) {
      emit(HabitError('Failed to update progress: ${e.toString()}'));
      // Re-initialize storage if box was closed
      if (e.toString().contains('Box has already been closed')) {
        await _storageService.init();
        // Make sure to emit the current habits again after re-initializing
        emit(HabitLoaded(_habits));
      }
    }
  }

  // Get habit by ID
  Habit? getHabitById(String habitId) {
    try {
      return _habits.firstWhere((h) => h.id == habitId);
    } catch (e) {
      return null;
    }
  }

  // Clear all habits
  Future<void> clearAllHabits() async {
    emit(HabitLoading());
    try {
      await _storageService.clearAllHabits();
      _habits = [];
      emit(HabitLoaded(_habits));
    } catch (e) {
      emit(HabitError('Failed to clear habits: ${e.toString()}'));
      // Re-initialize storage if box was closed
      if (e.toString().contains('Box has already been closed')) {
        await _storageService.init();
        emit(HabitLoaded(_habits));
      }
    }
  }

  // Initialize default habits
  void _initializeDefaultHabits() {
    _habits = []; // Empty list instead of predefined default habits
  }
}
