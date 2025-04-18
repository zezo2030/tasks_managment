import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/models/habit_model.dart';

class MonthlyCalendarWidget extends StatefulWidget {
  final Habit habit;

  const MonthlyCalendarWidget({Key? key, required this.habit})
    : super(key: key);

  @override
  State<MonthlyCalendarWidget> createState() => _MonthlyCalendarWidgetState();
}

class _MonthlyCalendarWidgetState extends State<MonthlyCalendarWidget> {
  late List<DateTime> _monthDays;
  late final DateTime _today = DateTime.now();
  final DateFormat _monthFormat = DateFormat('MMMM yyyy');

  @override
  void initState() {
    super.initState();
    _generateMonthDays();
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _monthFormat.format(_today),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
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
                        style: const TextStyle(
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

                  // Check habit completion for this day
                  // Get the day's index in week (0-6) from start of habit tracking
                  final daysSinceStart =
                      day
                          .difference(
                            DateTime.now().subtract(
                              Duration(days: DateTime.now().weekday - 1),
                            ),
                          )
                          .inDays;
                  final weekdayIndex = (daysSinceStart % 7);

                  // Only consider completed if it's within the available data and marked complete
                  final isCompleted =
                      weekdayIndex >= 0 &&
                      weekdayIndex < widget.habit.completionStatus.length &&
                      widget.habit.completionStatus[weekdayIndex];

                  return Container(
                    decoration: BoxDecoration(
                      color:
                          isToday
                              ? widget.habit.color.withOpacity(0.2)
                              : isCompleted
                              ? widget.habit.color.withOpacity(0.1)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                      border:
                          isToday
                              ? Border.all(color: widget.habit.color, width: 2)
                              : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color:
                                isToday
                                    ? widget.habit.color
                                    : AppColors.textDark,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isCompleted && !isToday)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: widget.habit.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
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
}
