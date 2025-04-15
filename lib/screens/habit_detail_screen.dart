import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/models/habit_model.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Habit _habit;

  // List of the days of the current month
  late List<DateTime> _monthDays;
  late final DateTime _today = DateTime.now();
  final DateFormat _monthFormat = DateFormat('MMMM yyyy');

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

    _generateMonthDays();
    _animationController.forward();
  }

  void _generateMonthDays() {
    final DateTime firstDayOfMonth = DateTime(_today.year, _today.month, 1);
    final DateTime lastDayOfMonth = DateTime(_today.year, _today.month + 1, 0);

    _monthDays = List.generate(
      lastDayOfMonth.day,
      (index) => DateTime(_today.year, _today.month, index + 1),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHabitHeader(),
                    const SizedBox(height: 24),
                    _buildProgressSection(),
                    const SizedBox(height: 30),
                    _buildMonthlyCalendar(),
                    const SizedBox(height: 30),
                    _buildStatisticsSection(),
                    const SizedBox(height: 30),
                    _buildStreakSection(),
                    const SizedBox(
                      height: 80,
                    ), // Add space for the floating action button
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _habit.isQuantitative
              ? null
              : FloatingActionButton(
                onPressed: () {
                  // Add today's completion
                  final bool isCompleted = !(_habit.completionStatus.last);
                  final newStatus = List<bool>.from(_habit.completionStatus);
                  newStatus[newStatus.length - 1] = isCompleted;

                  setState(() {
                    _habit = _habit.copyWith(completionStatus: newStatus);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isCompleted
                            ? 'Marked as completed for today!'
                            : 'Marked as not completed for today',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: isCompleted ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                backgroundColor:
                    _habit.completionStatus.last ? Colors.green : _habit.color,
                child: Icon(
                  _habit.completionStatus.last ? Icons.check : Icons.add,
                  size: 28,
                ),
              ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context, _habit),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, size: 24),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit_outlined, size: 24),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.settings_outlined, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _habit.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(_habit.icon, color: _habit.color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _habit.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _habit.description,
                  style: TextStyle(fontSize: 16, color: AppColors.textLight),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _habit.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Daily Habit',
                    style: TextStyle(
                      color: _habit.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    if (_habit.isQuantitative) {
      return _buildQuantitativeProgressSection();
    }

    final int successPercentage = (_habit.progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              '$successPercentage% Completed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _habit.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 12,
              width: MediaQuery.of(context).size.width * _habit.progress - 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_habit.color, _habit.color.withOpacity(0.7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'This Week',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 12),
        _buildWeeklyProgress(),
      ],
    );
  }

  Widget _buildQuantitativeProgressSection() {
    final int progressPercentage = (_habit.quantitativeProgress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              '$progressPercentage% Completed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _habit.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 12,
              width:
                  MediaQuery.of(context).size.width *
                      _habit.quantitativeProgress -
                  48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_habit.color, _habit.color.withOpacity(0.7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
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
            children: [
              Text(
                _habit.currentValue.toStringAsFixed(
                  _habit.currentValue.truncateToDouble() == _habit.currentValue
                      ? 0
                      : 1,
                ),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'out of ${_habit.targetValue.toStringAsFixed(_habit.targetValue.truncateToDouble() == _habit.targetValue ? 0 : 1)} ${_habit.unit}',
                style: TextStyle(fontSize: 16, color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onTap: () {
                      setState(() {
                        final newValue = (_habit.currentValue - 1).clamp(
                          0.0,
                          double.infinity,
                        );
                        _habit = _habit.copyWith(currentValue: newValue);
                      });
                    },
                  ),
                  _buildQuantityButton(
                    icon: Icons.add,
                    onTap: () {
                      setState(() {
                        _habit = _habit.copyWith(
                          currentValue: _habit.currentValue + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'This Week',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 12),
        _buildWeeklyProgress(),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _habit.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: _habit.color, size: 32),
      ),
    );
  }

  Widget _buildWeeklyProgress() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final isCompleted =
              index < _habit.completionStatus.length
                  ? _habit.completionStatus[index]
                  : false;

          return Column(
            children: [
              Text(
                weekDays[index],
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color:
                      isCompleted
                          ? _habit.color
                          : _habit.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isCompleted
                            ? Colors.transparent
                            : _habit.color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child:
                    isCompleted
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : null,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMonthlyCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _monthFormat.format(_today),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
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
            children: [
              // Days of week
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                      return Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              // Calendar grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount:
                    _monthDays.length +
                    DateTime(_today.year, _today.month, 1).weekday -
                    1,
                itemBuilder: (context, index) {
                  // Add empty cells for the beginning of the month
                  final firstDayOffset =
                      DateTime(_today.year, _today.month, 1).weekday - 1;

                  if (index < firstDayOffset) {
                    return Container();
                  }

                  final dayIndex = index - firstDayOffset;
                  if (dayIndex >= _monthDays.length) {
                    return Container();
                  }

                  final day = _monthDays[dayIndex];
                  final isToday =
                      day.day == _today.day &&
                      day.month == _today.month &&
                      day.year == _today.year;

                  // Mock habit completion (for demo purposes)
                  final isCompleted = dayIndex % 2 == 0;

                  return Container(
                    decoration: BoxDecoration(
                      color:
                          isToday
                              ? _habit.color.withOpacity(0.2)
                              : isCompleted
                              ? _habit.color.withOpacity(0.1)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                      border:
                          isToday
                              ? Border.all(color: _habit.color, width: 2)
                              : null,
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              color:
                                  isToday ? _habit.color : AppColors.textDark,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isCompleted && !isToday)
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: _habit.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              title: 'Current Streak',
              value: '5 days',
              icon: Icons.local_fire_department_rounded,
              color: AppColors.cardOrange,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              title: 'Longest Streak',
              value: '21 days',
              icon: Icons.emoji_events_rounded,
              color: AppColors.cardPurple,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              title: 'This Month',
              value: '15/20 days',
              icon: Icons.calendar_month_rounded,
              color: AppColors.cardBlue,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              title: 'Total',
              value: '45 days',
              icon: Icons.bar_chart_rounded,
              color: AppColors.cardPink,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Streak',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.cardOrange,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '5 days',
                    style: TextStyle(
                      color: AppColors.cardOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(10, (index) {
                  final isActive = index < 5;

                  return Column(
                    children: [
                      Container(
                        width: 5,
                        height: 30 + (index % 3) * 10.0,
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? _habit.color
                                  : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_today.day - 9 + index}',
                        style: TextStyle(
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          color:
                              isActive
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 20),
              const Text(
                'Keep going! You\'re on a 5-day streak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your best streak is 21 days',
                style: TextStyle(fontSize: 14, color: AppColors.textLight),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
