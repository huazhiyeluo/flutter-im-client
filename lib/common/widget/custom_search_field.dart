import 'package:flutter/material.dart';

class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool expands;
  final double maxHeight;
  final double minHeight;
  final VoidCallback? onTap;
  final ValueChanged? onSubmitted;

  const CustomSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.expands = false,
    this.maxHeight = double.infinity,
    this.minHeight = 25,
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
        style: const TextStyle(textBaseline: TextBaseline.alphabetic),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[50],
          hintText: hintText,
          hintStyle: const TextStyle(color: Color.fromARGB(255, 111, 104, 104)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 5.0,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onTap: onTap,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
