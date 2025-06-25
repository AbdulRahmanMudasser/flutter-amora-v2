import 'package:flutter/material.dart';
import 'package:amora/core/theme/theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Icon? prefixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85; // Match RegistrationScreen

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14 * fontScaleFactor,
        color: AppTheme.deepRose,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14 * fontScaleFactor,
          color: AppTheme.roseGold.withOpacity(0.7),
        ),
        prefixIcon: prefixIcon != null
            ? Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: prefixIcon,
        )
            : null,
        filled: true,
        fillColor: AppTheme.softPink.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.roseGold, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.roseGold, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.deepRose, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        // Add subtle shadow for romantic effect
        suffixIcon: obscureText
            ? Icon(
          Icons.visibility_off,
          color: AppTheme.roseGold,
          size: 20 * fontScaleFactor,
        )
            : null,
      ),
    );
  }
}