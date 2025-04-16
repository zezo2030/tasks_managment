import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tasks_managment/models/habit_model.dart';
import 'package:tasks_managment/services/habit_adapter.dart';

class HabitStorageService {
  static const String habitBoxName = 'habits';
  Box<Habit>? _habitsBox;
  bool _isInitialized = false;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    if (_isInitialized && _habitsBox != null && _habitsBox!.isOpen) return;

    try {
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CustomHabitFrequencyAdapter());
      }

      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CustomHabitAdapter());
      }

      // Only close the box if it's actually open
      if (Hive.isBoxOpen(habitBoxName)) {
        await Hive.box<Habit>(habitBoxName).close();
      }

      // Open box with clear recovery strategy
      _habitsBox = await Hive.openBox<Habit>(
        habitBoxName,
        compactionStrategy: (entries, deletedEntries) => deletedEntries > 50,
        crashRecovery: true,
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing Hive box: $e');
      // Try to recreate box in case of corruption
      await _recreateBoxOnError();
    }
  }

  /// Ensure box is open and initialized
  Future<Box<Habit>> _getBox() async {
    if (!_isInitialized || _habitsBox == null || !_habitsBox!.isOpen) {
      await init();
    }
    if (_habitsBox == null || !_habitsBox!.isOpen) {
      throw Exception('Failed to initialize Hive box');
    }
    return _habitsBox!;
  }

  /// Get all habits
  List<Habit> getAllHabits() {
    try {
      if (!_isInitialized || _habitsBox == null || !_habitsBox!.isOpen) {
        init(); // Initialize for next time, but return empty for now
        return [];
      }
      return _habitsBox!.values.toList();
    } catch (e) {
      debugPrint('Error getting habits: $e');
      return [];
    }
  }

  /// Add a new habit
  Future<void> addHabit(Habit habit) async {
    try {
      final box = await _getBox();
      await box.put(habit.id, habit);
    } catch (e) {
      debugPrint('Error adding habit: $e');
      rethrow; // Rethrow to allow proper error handling in the cubit
    }
  }

  /// Update an existing habit
  Future<void> updateHabit(Habit habit) async {
    try {
      final box = await _getBox();
      await box.put(habit.id, habit);
    } catch (e) {
      debugPrint('Error updating habit: $e');
      rethrow; // Rethrow to allow proper error handling in the cubit
    }
  }

  /// Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      final box = await _getBox();
      await box.delete(habitId);
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      rethrow;
    }
  }

  /// Get a habit by ID
  Habit? getHabitById(String habitId) {
    try {
      if (!_isInitialized || _habitsBox == null || !_habitsBox!.isOpen) {
        return null;
      }
      return _habitsBox!.get(habitId);
    } catch (e) {
      debugPrint('Error getting habit by ID: $e');
      return null;
    }
  }

  /// Clear all habits (for testing or reset)
  Future<void> clearAllHabits() async {
    try {
      final box = await _getBox();
      await box.clear();
    } catch (e) {
      debugPrint('Error clearing habits: $e');
      rethrow;
    }
  }

  /// Recreate box in case of errors
  Future<void> _recreateBoxOnError() async {
    try {
      _isInitialized = false;
      _habitsBox = null;

      // Delete the corrupted box file
      await Hive.deleteBoxFromDisk(habitBoxName);

      // Reopen the box
      _habitsBox = await Hive.openBox<Habit>(habitBoxName);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to recreate box: $e');
      _isInitialized = false;
    }
  }
}
