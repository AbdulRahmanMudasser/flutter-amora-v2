import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amora/core/theme/theme.dart';

import '../../data/models/word_style.dart';

class RichTextEditor extends StatefulWidget {
  final List<WordStyle> wordStyles;
  final ValueChanged<List<WordStyle>> onTextChanged;
  final double fontSize;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final bool isPreviewMode;
  final Function(Offset) onPositionChanged;
  final Offset textPosition;
  final VoidCallback resetTextPosition;

  const RichTextEditor({
    super.key,
    required this.wordStyles,
    required this.onTextChanged,
    required this.fontSize,
    required this.textAlign,
    required this.textDirection,
    required this.isPreviewMode,
    required this.onPositionChanged,
    required this.textPosition,
    required this.resetTextPosition,
  });

  @override
  _RichTextEditorState createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late Offset _currentPosition;
  int? _selectedWordIndex;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showColorPalette = true;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.textPosition;
    _textController.text = widget.wordStyles.map((ws) => ws.word).join(' ');
    _focusNode.requestFocus();
  }

  void _updateWordColor(int wordIndex, Color color) {
    setState(() {
      widget.wordStyles[wordIndex] = widget.wordStyles[wordIndex].copyWith(color: color);
    });
    widget.onTextChanged(widget.wordStyles);
  }

  Widget _buildColorPalette() {
    final colors = [
      Colors.black, Colors.blue, Colors.red, Colors.green,
      Colors.purple, Colors.orange, Colors.yellow, Colors.white,
    ];

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      bottom: _showColorPalette ? 10 : -100,
      right: 10,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _showColorPalette = false),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      if (_selectedWordIndex != null) {
                        _updateWordColor(_selectedWordIndex!, color);
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedWordIndex != null &&
                              widget.wordStyles[_selectedWordIndex!].color == color
                              ? AppTheme.roseGold
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: _currentPosition.dx,
          top: _currentPosition.dy,
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
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    onChanged: (text) {
                      final words = text.split(' ');
                      final newWordStyles = <WordStyle>[];

                      for (var i = 0; i < words.length; i++) {
                        if (i < widget.wordStyles.length) {
                          newWordStyles.add(widget.wordStyles[i].copyWith(word: words[i]));
                        } else {
                          newWordStyles.add(WordStyle(word: words[i]));
                        }
                      }

                      widget.onTextChanged(newWordStyles);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Type your text here...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    style: GoogleFonts.montserrat(
                      fontSize: widget.fontSize,
                    ),
                  ),
                  if (widget.wordStyles.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            for (var i = 0; i < widget.wordStyles.length; i++)
                              TextSpan(
                                text: '${widget.wordStyles[i].word} ',
                                style: GoogleFonts.montserrat(
                                  color: widget.wordStyles[i].color,
                                  fontSize: widget.fontSize,
                                  fontWeight: widget.wordStyles[i].isBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontStyle: widget.wordStyles[i].isItalic
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  backgroundColor: _selectedWordIndex == i
                                      ? Colors.yellow.withValues(alpha: 0.3)
                                      : Colors.transparent,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => setState(() {
                                    _selectedWordIndex = i;
                                    _showColorPalette = true;
                                  }),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        _buildColorPalette(),
      ],
    );
  }
}