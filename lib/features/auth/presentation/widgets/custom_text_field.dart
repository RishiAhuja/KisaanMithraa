import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPhone;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPhone = false,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
