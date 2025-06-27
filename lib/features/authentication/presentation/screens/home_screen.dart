import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:amora/core/theme/theme.dart';
import 'package:amora/features/authentication/data/models/user_model.dart';

class HomeScreen extends StatelessWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;
    final verticalSpacing = screenHeight * 0.015;

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.creamWhite,
              AppTheme.softPink.withOpacity(0.3),
            ],
          ),
        ),
        child: FutureBuilder<Box<UserModel>>(
          future: Hive.openBox<UserModel>('users'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.roseGold));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text(
                  'Error loading user data',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18 * fontScaleFactor,
                    color: AppTheme.deepRose,
                  ),
                ),
              );
            }

            final userBox = snapshot.data!;
            final user = userBox.values.firstWhere(
                  (user) => user.email == email,
              orElse: () => UserModel(
                id: '',
                username: 'Unknown',
                email: email,
                role: 'Unknown',
                securityQuestion: '',
                securityAnswer: '',
                secretWord: '',
              ),
            );

            return SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.25,
                          maxWidth: screenWidth * 0.85,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.roseGold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.softPink.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            'assets/images/register.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              return Container(
                                color: AppTheme.softPink.withOpacity(0.2),
                                child: Icon(
                                  Icons.favorite,
                                  size: screenWidth * 0.15,
                                  color: AppTheme.roseGold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: verticalSpacing * 2),
                      Text(
                        'Welcome to Your Love Story, ${user.role}!',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 26 * fontScaleFactor,
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
                      SizedBox(height: verticalSpacing * 2),
                      Text(
                        'Your journey together continues...',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18 * fontScaleFactor,
                          color: AppTheme.deepRose,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}