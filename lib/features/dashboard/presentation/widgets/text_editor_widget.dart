import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amora/core/theme/theme.dart';

class TextEditorWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onTextChanged;
  final double textSize;
  final Color textColor;
  final bool isBold;
  final bool isItalic;
  final bool hasShadow;
  final TextAlign textAlign;
  final double textRotation;
  final bool isPreviewMode;
  final Function(Offset) onPositionChanged;
  final Offset textPosition;
  final VoidCallback resetTextPosition; // Changed from Function to VoidCallback
  final TextDirection Function(String) getTextDirection;

  const TextEditorWidget({
    Key? key,
    required this.controller,
    required this.onTextChanged,
    required this.textSize,
    required this.textColor,
    required this.isBold,
    required this.isItalic,
    required this.hasShadow,
    required this.textAlign,
    required this.textRotation,
    required this.isPreviewMode,
    required this.onPositionChanged,
    required this.textPosition,
    required this.resetTextPosition,
    required this.getTextDirection,
  }) : super(key: key);

  @override
  _TextEditorWidgetState createState() => _TextEditorWidgetState();
}

class _TextEditorWidgetState extends State<TextEditorWidget> {
  late Offset _currentPosition;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.textPosition;
  }

  @override
  void didUpdateWidget(TextEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textPosition != widget.textPosition) {
      _currentPosition = widget.textPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontScaleFactor = screenWidth > 600 ? 1.2 : 0.85;

    final textDirection = widget.getTextDirection(
        widget.controller.text.isEmpty ? 'Your Text' : widget.controller.text);

    return Positioned(
      left: _currentPosition.dx + screenWidth * 0.475,
      top: _currentPosition.dy + screenHeight * 0.25,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _currentPosition = Offset(
              _currentPosition.dx + details.delta.dx,
              _currentPosition.dy + details.delta.dy,
            );
          });
          widget.onPositionChanged(_currentPosition);
        },
        onDoubleTap: () {
          setState(() {
            _currentPosition = const Offset(0, 0);
          });
          widget.resetTextPosition(); // Call the reset callback
        },
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.8,
            minWidth: screenWidth * 0.3,
            minHeight: screenHeight * 0.05,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.roseGold, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            color: widget.isPreviewMode
                ? Colors.transparent
                : AppTheme.creamWhite.withOpacity(0.8),
            boxShadow: widget.isPreviewMode
                ? null
                : [
              BoxShadow(
                color: AppTheme.softPink.withOpacity(0.3),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: screenHeight * 0.015,
          ),
          child: Stack(
            children: [
              Transform.rotate(
                angle: widget.textRotation * 3.14159 / 180,
                child: Directionality(
                  textDirection: textDirection,
                  child: widget.isPreviewMode
                      ? Text(
                    widget.controller.text.isEmpty
                        ? 'Your Text'
                        : widget.controller.text,
                    textAlign: widget.textAlign,
                    style: GoogleFonts.montserrat(
                      fontSize: widget.textSize,
                      color: widget.textColor,
                      fontWeight: widget.isBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontStyle: widget.isItalic
                          ? FontStyle.italic
                          : FontStyle.normal,
                      shadows: widget.hasShadow
                          ? [
                        Shadow(
                          blurRadius: 4,
                          color: AppTheme.roseGold.withOpacity(0.5),
                          offset: const Offset(1, 1),
                        ),
                      ]
                          : null,
                    ),
                  )
                      : TextField(
                    controller: widget.controller,
                    onChanged: widget.onTextChanged,
                    textAlign: widget.textAlign,
                    style: GoogleFonts.montserrat(
                      fontSize: widget.textSize,
                      color: widget.textColor,
                      fontWeight: widget.isBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontStyle: widget.isItalic
                          ? FontStyle.italic
                          : FontStyle.normal,
                      shadows: widget.hasShadow
                          ? [
                        Shadow(
                          blurRadius: 4,
                          color: AppTheme.roseGold.withOpacity(0.5),
                          offset: const Offset(1, 1),
                        ),
                      ]
                          : null,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Your Text',
                      hintStyle: GoogleFonts.montserrat(
                        color: AppTheme.roseGold.withOpacity(0.5),
                        fontSize: widget.textSize,
                      ),
                      border: InputBorder.none,
                    ),
                    textDirection: textDirection,
                    maxLines: null,
                    maxLength: 200,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ),
              if (!widget.isPreviewMode)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Icon(
                    Icons.drag_indicator,
                    color: AppTheme.roseGold,
                    size: 24 * fontScaleFactor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}