import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tasks_managment/models/habit_model.dart';
import 'package:tasks_managment/services/habit_storage_service.dart';

part 'habit_state.dart';

class HabitCubit extends Cubit<HabitState> {
  final HabitStorageService _storageService;
  List<Habit> _habits = [];

  HabitCubit({HabitStorageService? storageService})
    : _storageService = storageService ?? HabitStorageService(),
      super(HabitInitial()) {
    loadHabits();
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
    } catch (e) {
      emit(HabitError('Failed to load habits: ${e.toString()}'));
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
