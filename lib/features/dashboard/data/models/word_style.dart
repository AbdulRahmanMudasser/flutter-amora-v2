// lib/features/write/models/word_style.dart
import 'dart:ui' show Color;

import 'package:flutter/material.dart' show Colors;

class WordStyle {
  final String word;
  final Color color;
  final bool isBold;
  final bool isItalic;

  WordStyle({
    required this.word,
    this.color = Colors.black,
    this.isBold = false,
    this.isItalic = false,
  });

  WordStyle copyWith({
    String? word,
    Color? color,
    bool? isBold,
    bool? isItalic,
  }) {
    return WordStyle(
      word: word ?? this.word,
      color: color ?? this.color,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
    );
  }
}