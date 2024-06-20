import 'package:flutter/material.dart';

class CtextFormField extends StatelessWidget {
  const CtextFormField(
      {super.key,
      required this.label,
      this.suffix = false,
      this.suffixIcon,
      this.suffixOnpress,
      required this.validate,
      this.keyboardtype = TextInputType.text,
      required this.controller,
      this.maxLines = 1,
      this.width = 500.0,
      this.obscure = false});

  final TextEditingController controller;
  final String label;
  final bool suffix;
  final IconData? suffixIcon;
  final Function()? suffixOnpress;
  final Function(String? x) validate;
  final TextInputType keyboardtype;
  final int maxLines;
  final double width;
  final bool obscure;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        controller: controller,
        keyboardType: keyboardtype,
        obscureText: obscure,
        validator: (value) => validate(value),
        decoration: InputDecoration(
            label: Text(label),
            suffix: suffix == false
                ? null
                : IconButton(onPressed: suffixOnpress, icon: Icon(suffixIcon))),
      ),
    );
  }
}
