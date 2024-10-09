import 'package:flutter/material.dart';

class CustomChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool expands;
  final double maxHeight;
  final double minHeight;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const CustomChatTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.expands = false,
    this.maxHeight = double.infinity,
    this.minHeight = 25,
    this.onTap,
    this.onChanged,
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
        maxLines: expands ? null : 1,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onTap: onTap,
        onChanged: onChanged,
      ),
    );
  }
}
