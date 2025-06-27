import 'package:flutter/material.dart';
import 'package:amora/core/theme/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final Icon? prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  TextDirection _getTextDirection(String text) {
    return text.contains(RegExp(r'[\u0600-\u06FF]')) ? TextDirection.rtl : TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;
    final text = widget.controller.text.isEmpty ? widget.label : widget.controller.text;

    return Directionality(
      textDirection: _getTextDirection(text),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: _obscureText,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        style: GoogleFonts.montserrat(
          fontSize: 14 * fontScaleFactor,
          color: AppTheme.vintageSepia,
        ),
        textDirection: _getTextDirection(text),
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.obscureText
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.roseGold,
              size: 20 * fontScaleFactor,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,
          filled: true,
          fillColor: AppTheme.softPink.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.roseGold, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.deepRose, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.04),
        ),
        validator: widget.validator,
      ),
    );
  }
}