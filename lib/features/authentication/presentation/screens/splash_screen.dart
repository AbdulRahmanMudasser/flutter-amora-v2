import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amora/core/theme/theme.dart';
import 'package:amora/features/authentication/presentation/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    // Navigate to LoginScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1200;

    // Responsive font sizes
    final titleFontSize = isMobile ? 28.0 : isTablet ? 36.0 : 44.0;
    final subtitleFontSize = isMobile ? 16.0 : isTablet ? 20.0 : 24.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.creamWhite,
              AppTheme.softPink.withOpacity(0.5),
              AppTheme.roseGold.withOpacity(0.3),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Placeholder for your image (replace with your image asset or file)
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: isMobile ? screenSize.width * 0.7 : screenSize.width * 0.5,
                  height: isMobile ? screenSize.height * 0.4 : screenSize.height * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.roseGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.softPink.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/backgrounds/bg-splash.jpg', // Replace with your image path
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.softPink.withOpacity(0.2),
                          child: Center(
                            child: Icon(
                              Icons.image,
                              size: isMobile ? 50 : 80,
                              color: AppTheme.roseGold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Title and subtitle
            Positioned(
              bottom: isMobile ? screenSize.height * 0.15 : screenSize.height * 0.2,
              left: 0,
              right: 0,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ASAD KI DUNIYA',
                        style: GoogleFonts.montserrat(
                          fontSize: titleFontSize,
                          color: AppTheme.deepRose,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: AppTheme.roseGold.withOpacity(0.4),
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'A World of Love and Memories',
                        style: GoogleFonts.montserrat(
                          fontSize: subtitleFontSize,
                          color: AppTheme.vintageSepia,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: isMobile ? 24 : 30,
                            color: AppTheme.roseGold,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: isMobile ? 100 : 150,
                            height: 2,
                            color: AppTheme.roseGold,
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.favorite,
                            size: isMobile ? 24 : 30,
                            color: AppTheme.roseGold,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Subtle animated hearts in the background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: screenSize.height * 0.1,
                        left: screenSize.width * 0.2,
                        child: Opacity(
                          opacity: _fadeAnimation.value * 0.3,
                          child: Icon(
                            Icons.favorite,
                            size: isMobile ? 30 : 40,
                            color: AppTheme.softPink.withOpacity(0.3),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: screenSize.height * 0.3,
                        right: screenSize.width * 0.15,
                        child: Opacity(
                          opacity: _fadeAnimation.value * 0.3,
                          child: Icon(
                            Icons.favorite,
                            size: isMobile ? 25 : 35,
                            color: AppTheme.softPink.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}