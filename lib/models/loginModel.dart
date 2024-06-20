import 'package:flutter/material.dart';

class LogInModel {
  final String label;
  bool obsucre;
  final bool suffix;
  final IconData? suffixIcon;
  Function()? suffixOnpress;
  final TextEditingController controller;
  final Function(String? x) validate;
  final TextInputType keyboardtype;
  final int maxLines;
  final double width;

  LogInModel(
      {required this.label,
      this.suffix = false,
      this.suffixIcon,
      this.suffixOnpress,
      this.obsucre = false,
      required this.controller,
      required this.validate,
      this.keyboardtype = TextInputType.text,
      this.maxLines = 1,
      this.width = 500});
}
