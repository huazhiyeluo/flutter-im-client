// custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final BorderRadiusGeometry borderRadius;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor = Colors.red,
    this.foregroundColor = Colors.white,
    this.padding = const EdgeInsets.fromLTRB(10, 10, 10, 10),
    this.textStyle = const TextStyle(fontSize: 18),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
        foregroundColor: WidgetStateProperty.all<Color>(foregroundColor),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(padding),
        textStyle: WidgetStateProperty.all<TextStyle>(textStyle),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
        ),
        minimumSize: WidgetStateProperty.all(const Size(50, 30)),
      ),
      child: Text(text),
    );
  }
}
