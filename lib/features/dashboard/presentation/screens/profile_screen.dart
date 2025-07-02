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
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;
    final verticalSpacing = screenHeight * 0.02;
    final horizontalPadding = screenWidth * 0.02;

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
              return const Center(child: CircularProgressIndicator(color: AppTheme.roseGold));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Directionality(
                  textDirection: _getTextDirection('Error loading profile'),
                  child: Text(
                    'Error loading profile',
                    style: GoogleFonts.montserrat(
                      fontSize: 18 * fontScaleFactor,
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
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalSpacing * 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: verticalSpacing * 2, bottom: verticalSpacing),
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.18,
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
                          'assets/images/login.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Error loading header: $error');
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
                    SizedBox(height: verticalSpacing),
                    Directionality(
                      textDirection: _getTextDirection('Your Love Profile'),
                      child: Text(
                        'Your Love Profile',
                        style: GoogleFonts.montserrat(
                          fontSize: 26 * fontScaleFactor,
                          color: AppTheme.deepRose,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              blurRadius: 3,
                              color: AppTheme.roseGold.withValues(alpha: 0.3),
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 20, color: AppTheme.roseGold),
                        SizedBox(width: 8),
                        Expanded(
                          child: Divider(color: AppTheme.roseGold, thickness: 1),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.favorite, size: 20, color: AppTheme.roseGold),
                      ],
                    ),
                    SizedBox(height: verticalSpacing * 2),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileItem(
                            context,
                            label: 'Username',
                            value: user.username,
                            fontScaleFactor: fontScaleFactor,
                          ),
                          SizedBox(height: verticalSpacing),
                          _buildProfileItem(
                            context,
                            label: 'Email',
                            value: user.email,
                            fontScaleFactor: fontScaleFactor,
                          ),
                          SizedBox(height: verticalSpacing),
                          _buildProfileItem(
                            context,
                            label: 'Role',
                            value: user.role,
                            fontScaleFactor: fontScaleFactor,
                          ),
                          SizedBox(height: verticalSpacing),
                          _buildProfileItem(
                            context,
                            label: 'Our Special Word',
                            value: user.secretWord,
                            fontScaleFactor: fontScaleFactor,
                          ),
                          SizedBox(height: verticalSpacing),
                          _buildProfileItem(
                            context,
                            label: 'CNIC',
                            value: user.cnic ?? 'Not set',
                            fontScaleFactor: fontScaleFactor,
                          ),
                          SizedBox(height: verticalSpacing),
                          _buildProfileItem(
                            context,
                            label: 'Passport',
                            value: user.passport ?? 'Not set',
                            fontScaleFactor: fontScaleFactor,
                          ),
                          SizedBox(height: verticalSpacing),
                          _buildProfileItem(
                            context,
                            label: 'Phone Numbers',
                            value: user.phoneNumbers?.join(', ') ?? 'Not set',
                            fontScaleFactor: fontScaleFactor,
                          ),
                          SizedBox(height: verticalSpacing),
                          _buildProfileItem(
                            context,
                            label: 'Nikkah Nama',
                            value: user.nikkahNama ?? 'Not set',
                            fontScaleFactor: fontScaleFactor,
                          ),
                          SizedBox(height: verticalSpacing),
                          _buildProfileItem(
                            context,
                            label: 'Husband Birthday',
                            value: user.husbandBirthday ?? 'Not set',
                            fontScaleFactor: fontScaleFactor,
                          ),
                          SizedBox(height: verticalSpacing),
                          _buildProfileItem(
                            context,
                            label: 'Wife Birthday',
                            value: user.wifeBirthday ?? 'Not set',
                            fontScaleFactor: fontScaleFactor,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 2),
                    FractionallySizedBox(
                      widthFactor: 0.98,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/edit_profile', arguments: email);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.roseGold,
                          foregroundColor: AppTheme.creamWhite,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenHeight * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppTheme.deepRose, width: 1.5),
                          ),
                          elevation: 4,
                          shadowColor: AppTheme.softPink.withValues(alpha: 0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit,
                              size: 18 * fontScaleFactor,
                              color: AppTheme.creamWhite,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Edit Profile',
                              style: GoogleFonts.montserrat(
                                fontSize: 16 * fontScaleFactor,
                                color: AppTheme.creamWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 2),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileItem(
      BuildContext context, {
        required String label,
        required String value,
        required double fontScaleFactor,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Directionality(
          textDirection: _getTextDirection(label),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 16 * fontScaleFactor,
              color: AppTheme.deepRose,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Directionality(
            textDirection: _getTextDirection(value),
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 16 * fontScaleFactor,
                color: AppTheme.vintageSepia,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}