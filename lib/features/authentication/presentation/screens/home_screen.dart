import 'package:flutter/material.dart';
import 'package:amora/core/theme/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Center(
        child: Text(
          'Welcome to Your Love Story!',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 24 * fontScaleFactor,
            color: AppTheme.deepRose,
            shadows: [
              Shadow(
                blurRadius: 3,
                color: AppTheme.roseGold.withOpacity(0.3),
                offset: const Offset(1, 1),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}