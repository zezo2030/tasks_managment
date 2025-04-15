import 'package:flutter/material.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/models/habit_model.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  IconData _selectedIcon = Icons.self_improvement_rounded;
  Color _selectedColor = AppColors.cardBlue;

  final List<IconData> _iconOptions = [
    Icons.directions_run_rounded,
    Icons.water_drop_rounded,
    Icons.book_rounded,
    Icons.self_improvement_rounded,
    Icons.sports_basketball_rounded,
    Icons.breakfast_dining_rounded,
    Icons.code_rounded,
    Icons.music_note_rounded,
    Icons.brush_rounded,
    Icons.favorite_rounded,
    Icons.nightlight_round,
    Icons.emoji_food_beverage_rounded,
  ];

  final List<Color> _colorOptions = [
    AppColors.cardBlue,
    AppColors.cardPink,
    AppColors.cardOrange,
    AppColors.cardPurple,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.deepOrange,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create New Habit',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Build a new habit with daily tracking',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildInputField(
                        title: 'Habit Name',
                        controller: _titleController,
                        hintText: 'e.g. Morning Meditation',
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        title: 'Description',
                        controller: _descriptionController,
                        hintText: 'e.g. Meditate for 10 minutes every morning',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      _buildFrequencySelector(),
                      const SizedBox(height: 30),
                      _buildIconSelector(),
                      const SizedBox(height: 30),
                      _buildColorSelector(),
                      const SizedBox(height: 40),
                      _buildCreateButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
            onTap: () => Navigator.pop(context),
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
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String title,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _selectedColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequency',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildFrequencyOption(
                title: 'Daily',
                subtitle: 'Track this habit every day',
                value: HabitFrequency.daily,
              ),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
              _buildFrequencyOption(
                title: 'Weekly',
                subtitle: 'Track this habit on specific days of the week',
                value: HabitFrequency.weekly,
              ),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
              _buildFrequencyOption(
                title: 'Custom',
                subtitle: 'Create a custom tracking schedule',
                value: HabitFrequency.custom,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyOption({
    required String title,
    required String subtitle,
    required HabitFrequency value,
  }) {
    return RadioListTile<HabitFrequency>(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textLight, fontSize: 14),
      ),
      value: value,
      groupValue: _selectedFrequency,
      activeColor: _selectedColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onChanged: (newValue) {
        setState(() {
          _selectedFrequency = newValue!;
        });
      },
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icon',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _iconOptions.length,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            itemBuilder: (context, index) {
              final icon = _iconOptions[index];
              final isSelected = icon == _selectedIcon;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? _selectedColor
                            : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border:
                        isSelected
                            ? Border.all(color: _selectedColor, width: 2)
                            : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColors.textLight,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _colorOptions.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemBuilder: (context, index) {
              final color = _colorOptions[index];
              final isSelected = color == _selectedColor;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 46,
                  height: 46,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border:
                        isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 10,
                              ),
                            ]
                            : null,
                  ),
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          )
                          : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final newHabit = Habit(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              description: _descriptionController.text,
              icon: _selectedIcon,
              color: _selectedColor,
              frequency: _selectedFrequency,
              completionStatus: List.generate(7, (index) => false),
              createdAt: DateTime.now(),
            );

            Navigator.pop(context, newHabit);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: _selectedColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: _selectedColor.withOpacity(0.5),
        ),
        child: const Text(
          'Create Habit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
