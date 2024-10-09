import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool expands;
  final double maxHeight;
  final double minHeight;
  final int? maxLines;
  final VoidCallback? onTap;
  final ValueChanged? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.expands = false,
    this.maxHeight = double.infinity,
    this.minHeight = 25,
    this.maxLines = 1,
    this.onTap,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minHeight: minHeight,
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(textBaseline: TextBaseline.alphabetic),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[50],
          hintText: hintText,
          hintStyle: const TextStyle(color: Color.fromARGB(255, 111, 104, 104)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 5.0,
          ), // 调整内容的内边距
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
        ),
        onTap: onTap,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
