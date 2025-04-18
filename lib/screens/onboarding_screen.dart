import 'package:flutter/material.dart';
import 'package:tasks_managment/core/constants.dart';
import 'package:tasks_managment/core/image_placeholder.dart';
import 'package:tasks_managment/core/navigation_helper.dart';
import 'package:tasks_managment/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentPage = 0;

  final List<OnboardingData> onboardingItems = [
    OnboardingData(
      title: 'Manage Your Tasks',
      description:
          'Organize all your to-do\'s in lists and projects. Color tag them to set priorities and categories.',
      color: AppColors.cardPink,
    ),
    OnboardingData(
      title: 'Track Your Progress',
      description:
          'See your completed tasks and track your productivity with beautiful analytics and insights.',
      color: AppColors.cardBlue,
    ),
    OnboardingData(
      title: 'Achieve Your Goals',
      description:
          'Set daily, weekly and monthly goals and get reminders to keep yourself on track.',
      color: AppColors.cardOrange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _navigateToHome(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: onboardingItems.length,
                itemBuilder: (context, index) {
                  return _buildPage(context, onboardingItems[index], index);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(
                        onboardingItems.length,
                        (index) => _buildDotIndicator(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == onboardingItems.length - 1) {
                        _navigateToHome();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 6,
                      shadowColor: AppColors.primaryColor.withOpacity(0.4),
                      backgroundColor:
                          _currentPage == 0
                              ? AppColors.cardPink
                              : _currentPage == 1
                              ? AppColors.cardBlue
                              : AppColors.cardOrange,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == onboardingItems.length - 1
                              ? 'Get Started'
                              : 'Continue',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHome() {
    NavigationHelper.navigateToHome(context);
  }

  Widget _buildPage(BuildContext context, OnboardingData data, int index) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: Container(
                  height: 280,
                  width: 280,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: OnboardingImageWidget(width: 250, height: 250),
                ),
              ),
            ),
          ),
          const Spacer(),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: data.color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data.description,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textLight,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: _currentPage == index ? 24 : 10,
      decoration: BoxDecoration(
        color:
            _currentPage == index
                ? _currentPage == 0
                    ? AppColors.cardPink
                    : _currentPage == 1
                    ? AppColors.cardBlue
                    : AppColors.cardOrange
                : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.color,
  });
}
