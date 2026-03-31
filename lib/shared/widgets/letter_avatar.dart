import 'package:flutter/material.dart';

/// A reusable circular avatar that displays the first letter of a name.
/// Ideal for account drawers, profile placeholders, and top-bar user avatars.
class LetterAvatar extends StatelessWidget {
  final String? name;
  final double size;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const LetterAvatar({
    super.key,
    required this.name,
    this.size = 40.0,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Gracefully handle null or empty names
    final displayLetter = (name != null && name!.trim().isNotEmpty)
        ? name!.trim()[0].toUpperCase()
        : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF282828), // Dark-theme friendly gray
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white10,
          width: 0.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        displayLetter,
        style: textStyle ??
            TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.45, // Proportional font size
            ),
      ),
    );
  }
}
