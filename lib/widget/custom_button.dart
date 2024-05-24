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
    Key? key,
    required this.onPressed,
    required this.text,
    this.backgroundColor = Colors.red,
    this.foregroundColor = Colors.white,
    this.padding = const EdgeInsets.fromLTRB(10, 10, 10, 10),
    this.textStyle = const TextStyle(fontSize: 18),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
        foregroundColor: MaterialStateProperty.all<Color>(foregroundColor),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(padding),
        textStyle: MaterialStateProperty.all<TextStyle>(textStyle),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
        ),
      ),
      child: Text(text),
    );
  }
}
