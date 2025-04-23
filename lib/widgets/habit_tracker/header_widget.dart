import 'package:flutter/material.dart';
import 'package:tasks_managment/core/constants.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback onBackPressed;

  const HeaderWidget({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBackPressed,
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
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.cardPink, AppColors.cardPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Hero(
              tag: 'profilePic',
              child: CircleAvatar(
                backgroundColor: AppColors.white,
                radius: 22,
                child: const Icon(
                  Icons.person,
                  color: AppColors.textDark,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
