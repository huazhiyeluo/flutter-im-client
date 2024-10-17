import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFieldMore extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool expands;
  final int? maxLines;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FocusNode? focusNode;
  final bool isFocused;
  final Color focusedColor;
  final Color unfocusedColor;
  final Color fillColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showUnderline;

  const CustomTextFieldMore({
    super.key,
    required this.controller,
    required this.hintText,
    this.expands = false,
    this.maxLines = 1,
    this.onTap,
    this.onSubmitted,
    this.onChanged,
    this.obscureText = false,
    this.focusNode,
    this.isFocused = false,
    this.focusedColor = const Color.fromARGB(255, 60, 183, 21),
    this.unfocusedColor = Colors.grey,
    this.fillColor = Colors.white,
    this.prefixIcon,
    this.inputFormatters,
    this.keyboardType,
    this.suffixIcon,
    this.showUnderline = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      style: const TextStyle(textBaseline: TextBaseline.alphabetic),
      maxLines: maxLines,
      decoration: InputDecoration(
        fillColor: fillColor,
        hintText: hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 111, 104, 104)),
        prefixIcon: prefixIcon, // 允许传入前置图标
        suffixIcon: suffixIcon, // 允许传入后置图标
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 10.0,
        ),
        border: showUnderline
            ? UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isFocused ? focusedColor : unfocusedColor,
                  width: 1.0,
                ),
              )
            : InputBorder.none,
        focusedBorder: showUnderline
            ? UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isFocused ? focusedColor : unfocusedColor,
                  width: 1.0,
                ),
              )
            : InputBorder.none,
        enabledBorder: showUnderline
            ? UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isFocused ? focusedColor : unfocusedColor,
                  width: 1.0,
                ),
              )
            : InputBorder.none,
      ),
      onTap: onTap,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}
