import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:amora/core/theme/theme.dart';
import 'package:amora/features/authentication/data/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  final String email;

  const ProfileScreen({super.key, required this.email});

  TextDirection _getTextDirection(String text) {
    return text.contains(RegExp(r'[\u0600-\u06FF]')) ? TextDirection.rtl : TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;
    final fontScaleFactor = isLargeScreen ? 1.3 : 1.0;
    final verticalSpacing = screenHeight * (isLargeScreen ? 0.03 : 0.02);
    final horizontalPadding = screenWidth * (isLargeScreen ? 0.1 : 0.05);

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.creamWhite,
              AppTheme.softPink.withValues(alpha: 0.4),
              AppTheme.roseGold.withValues(alpha: 0.2),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          image: const DecorationImage(
            image: AssetImage('assets/images/backgrounds/bg-8.jpg'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: FutureBuilder<Box<UserModel>>(
          future: Hive.openBox<UserModel>('users'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.roseGold,
                  strokeWidth: 2.5,
                ),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Directionality(
                  textDirection: _getTextDirection('Error loading profile'),
                  child: Text(
                    'Error loading profile',
                    style: GoogleFonts.montserrat(
                      fontSize: isLargeScreen ? 22 : 18,
                      color: AppTheme.deepRose,
                      fontWeight: FontWeight.w500,
                    ),
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
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalSpacing,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: verticalSpacing * 2),
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
                          color: AppTheme.softPink.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/otp.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading image: $error');
                          return Container(
                            color: AppTheme.softPink.withValues(alpha: 0.2),
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
                  Directionality(
                    textDirection: _getTextDirection('Hamari Private Information'),
                    child: Text(
                      'Hamari Private Information',
                      style: GoogleFonts.montserrat(
                        fontSize: isLargeScreen ? 28 : 22,
                        color: AppTheme.deepRose,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: AppTheme.roseGold.withValues(alpha: 0.3),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: isLargeScreen ? 28 : 20,
                        color: AppTheme.roseGold,
                      ),
                      SizedBox(width: isLargeScreen ? 16 : 8),
                      const Expanded(
                        child: Divider(
                          color: AppTheme.roseGold,
                          thickness: 1.5,
                          height: 1,
                        ),
                      ),
                      SizedBox(width: isLargeScreen ? 16 : 8),
                      Icon(
                        Icons.favorite,
                        size: isLargeScreen ? 28 : 20,
                        color: AppTheme.roseGold,
                      ),
                    ],
                  ),
                  SizedBox(height: verticalSpacing * 2),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? screenWidth * 0.1 : screenWidth * 0.05,
                      vertical: isLargeScreen ? 32 : 24,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.creamWhite.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.roseGold,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.softPink.withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileItem(
                          context,
                          icon: Icons.person_outline,
                          label: 'Username',
                          value: user.username,
                          isLargeScreen: isLargeScreen,
                        ),
                        SizedBox(height: verticalSpacing * 1.5),
                        _buildProfileItem(
                          context,
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.email,
                          isLargeScreen: isLargeScreen,
                        ),
                        SizedBox(height: verticalSpacing * 1.5),
                        _buildProfileItem(
                          context,
                          icon: Icons.verified_user_outlined,
                          label: 'Role',
                          value: user.role,
                          isLargeScreen: isLargeScreen,
                        ),
                        SizedBox(height: verticalSpacing * 1.5),
                        _buildProfileItem(
                          context,
                          icon: Icons.favorite_border,
                          label: 'Our Special Word',
                          value: user.secretWord,
                          isLargeScreen: isLargeScreen,
                        ),
                        SizedBox(height: verticalSpacing * 1.5),
                        _buildProfileItem(
                          context,
                          icon: Icons.credit_card_outlined,
                          label: 'CNIC',
                          value: user.cnic ?? 'Not set',
                          isLargeScreen: isLargeScreen,
                        ),
                        SizedBox(height: verticalSpacing * 1.5),
                        _buildProfileItem(
                          context,
                          icon: Icons.airplane_ticket_outlined,
                          label: 'Passport',
                          value: user.passport ?? 'Not set',
                          isLargeScreen: isLargeScreen,
                        ),
                        SizedBox(height: verticalSpacing * 1.5),
                        _buildProfileItem(
                          context,
                          icon: Icons.phone_iphone_outlined,
                          label: 'Phone Numbers',
                          value: user.phoneNumbers?.join(', ') ?? 'Not set',
                          isLargeScreen: isLargeScreen,
                        ),
                        SizedBox(height: verticalSpacing * 1.5),
                        _buildProfileItem(
                          context,
                          icon: Icons.article_outlined,
                          label: 'Nikkah Nama',
                          value: user.nikkahNama ?? 'Not set',
                          isLargeScreen: isLargeScreen,
                        ),
                        SizedBox(height: verticalSpacing * 1.5),
                        _buildProfileItem(
                          context,
                          icon: Icons.cake_outlined,
                          label: 'Husband Birthday',
                          value: user.husbandBirthday ?? 'Not set',
                          isLargeScreen: isLargeScreen,
                        ),
                        SizedBox(height: verticalSpacing * 1.5),
                        _buildProfileItem(
                          context,
                          icon: Icons.cake_outlined,
                          label: 'Wife Birthday',
                          value: user.wifeBirthday ?? 'Not set',
                          isLargeScreen: isLargeScreen,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: verticalSpacing * 3),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required bool isLargeScreen,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: isLargeScreen ? 28 : 22,
          color: AppTheme.roseGold,
        ),
        SizedBox(width: isLargeScreen ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Directionality(
                textDirection: _getTextDirection(label),
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: isLargeScreen ? 18 : 14,
                    color: AppTheme.deepRose.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: isLargeScreen ? 8 : 4),
              Directionality(
                textDirection: _getTextDirection(value),
                child: Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: isLargeScreen ? 16 : 14,
                    color: AppTheme.vintageSepia,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}