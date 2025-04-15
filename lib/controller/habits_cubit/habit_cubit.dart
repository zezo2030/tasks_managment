import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tasks_managment/models/habit_model.dart';

part 'habit_state.dart';

class HabitCubit extends Cubit<HabitState> {
  List<Habit> _habits = [];

  HabitCubit() : super(HabitInitial()) {
    // Initialize with default habits
    _habits = [
      Habit(
        id: '1',
        title: 'Running',
        description: 'Morning run for 30 minutes',
        icon: Icons.directions_run_rounded,
        color: const Color(0xFF4C9BFB), // AppColors.cardBlue
        completionStatus: [true, true, true, true, true, false, false],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Habit(
        id: '2',
        title: 'Water Intake',
        description: 'Drink 8 glasses of water',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF9B51E0), // AppColors.cardPurple
        completionStatus: [true, false, true, true, true, false, false],
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        isQuantitative: true,
        targetValue: 8,
        currentValue: 5,
        unit: 'cups',
      ),
      Habit(
        id: '3',
        title: 'Reading',
        description: 'Read for 30 minutes',
        icon: Icons.book_rounded,
        color: const Color(0xFFF2994A), // AppColors.cardOrange
        completionStatus: [true, true, true, true, true, true, false],
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        isQuantitative: true,
        targetValue: 20,
        currentValue: 12,
        unit: 'pages',
      ),
      Habit(
        id: '4',
        title: 'Meditation',
        description: 'Meditate for 10 minutes',
        icon: Icons.self_improvement_rounded,
        color: const Color(0xFFF1678E), // AppColors.cardPink
        completionStatus: [true, true, false, false, true, false, false],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        isQuantitative: true,
        targetValue: 10,
        currentValue: 6,
        unit: 'minutes',
      ),
      Habit(
        id: '5',
        title: 'Walking',
        description: 'Walking steps throughout the day',
        icon: Icons.directions_walk_rounded,
        color: Colors.teal,
        completionStatus: [true, true, true, false, true, false, false],
        createdAt: DateTime.now().subtract(const Duration(days: 21)),
        isQuantitative: true,
        targetValue: 5000,
        currentValue: 3250,
        unit: 'steps',
      ),
    ];
    loadHabits();
  }

  // Load all habits and emit HabitLoaded state
  void loadHabits() {
    emit(HabitLoading());
    try {
      emit(HabitLoaded(_habits));
    } catch (e) {
      emit(HabitError('Failed to load habits: ${e.toString()}'));
    }
  }

  // Add a new habit
  void addHabit(Habit habit) {
    emit(HabitLoading());
    try {
      _habits.add(habit);
      emit(HabitLoaded(_habits));
      emit(HabitAdded(habit));
    } catch (e) {
      emit(HabitError('Failed to add habit: ${e.toString()}'));
    }
  }

  // Update an existing habit
  void updateHabit(Habit updatedHabit) {
    emit(HabitLoading());
    try {
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
    }
  }

  // Delete a habit by ID
  void deleteHabit(String habitId) {
    emit(HabitLoading());
    try {
      _habits.removeWhere((h) => h.id == habitId);
      emit(HabitLoaded(_habits));
      emit(HabitDeleted(habitId));
    } catch (e) {
      emit(HabitError('Failed to delete habit: ${e.toString()}'));
    }
  }

  // Toggle habit completion for a specific day
  void toggleHabitCompletion(String habitId, int dayIndex) {
    try {
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1 && dayIndex < _habits[index].completionStatus.length) {
        final habit = _habits[index];
        final newStatus = List<bool>.from(habit.completionStatus);
        newStatus[dayIndex] = !newStatus[dayIndex];

        final updatedHabit = habit.copyWith(completionStatus: newStatus);
        _habits[index] = updatedHabit;

        emit(HabitLoaded(_habits));
        emit(HabitUpdated(updatedHabit));
      }
    } catch (e) {
      emit(HabitError('Failed to toggle completion: ${e.toString()}'));
    }
  }

  // Update quantitative habit progress
  void updateQuantitativeProgress(String habitId, double newValue) {
    try {
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        final habit = _habits[index];
        if (habit.isQuantitative) {
          final clampedValue = newValue.clamp(0.0, double.infinity);
          final updatedHabit = habit.copyWith(currentValue: clampedValue);
          _habits[index] = updatedHabit;

          emit(HabitLoaded(_habits));
          emit(HabitUpdated(updatedHabit));
        }
      }
    } catch (e) {
      emit(HabitError('Failed to update progress: ${e.toString()}'));
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
}
