  import 'package:flutter/material.dart';
  import 'package:flutter/scheduler.dart';
  import 'package:google_fonts/google_fonts.dart';

  class AppTheme {
    static const Color softPink = Color(0xFFF8E1E9);
    static const Color roseGold = Color(0xFFB76E79);
    static const Color deepRose = Color(0xFF8B5A5A);
    static const Color creamWhite = Color(0xFFF5F5F5);
    static const Color vintageSepia = Color(0xFF704214);

    static ThemeData get lightTheme {
      return ThemeData(
        primaryColor: softPink,
        scaffoldBackgroundColor: creamWhite,
        colorScheme: const ColorScheme.light(
          primary: softPink,
          secondary: roseGold,
          surface: creamWhite,
          onPrimary: deepRose,
          onSecondary: vintageSepia,
          error: Colors.redAccent,
        ),

        textTheme: TextTheme(
          displayLarge: GoogleFonts.montserrat(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: deepRose,
            letterSpacing: 1.2,
          ),
          displayMedium: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w600, color: deepRose),
          headlineSmall: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w600, color: roseGold),
          titleLarge: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w500, color: deepRose),
          bodyLarge: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.normal, color: vintageSepia),
          bodyMedium: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.normal, color: vintageSepia),
          labelLarge: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: roseGold),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: roseGold,
            foregroundColor: creamWhite,
            textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: deepRose, width: 1),
            ),
            elevation: 3,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: softPink.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: roseGold, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: roseGold, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: deepRose, width: 2),
          ),
          labelStyle: GoogleFonts.montserrat(color: vintageSepia, fontSize: 14),
          hintStyle: GoogleFonts.montserrat(color: vintageSepia.withOpacity(0.6), fontSize: 14),
        ),

        cardTheme: CardThemeData(
          color: creamWhite,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: softPink, width: 1),
          ),
          shadowColor: roseGold.withOpacity(0.3),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: softPink,
          elevation: 0,
          titleTextStyle: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w600, color: deepRose),
          iconTheme: const IconThemeData(color: roseGold),
        ),

        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
    }

    static TransitionBuilder romanticTransitionBuilder = (context, child) {
      return AnimatedBuilder(
        animation: const AlwaysStoppedAnimation(1.0),
        builder: (context, _) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: AnimationController(
                  duration: const Duration(milliseconds: 500),
                  vsync: _SimpleTickerProvider(),
                )..forward(),
                curve: Curves.easeInOut,
              ),
            ),
            child: child,
          );
        },
      );
    };
  }

  class _SimpleTickerProvider extends TickerProvider {
    @override
    Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
  }
