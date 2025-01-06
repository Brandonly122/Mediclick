import 'package:flutter/material.dart';

class AddCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isNumberInput;
  final GestureTapCallback? onTap;
  final bool isReadOnly;

  const AddCard({
    Key? key,
    required this.label,
    required this.icon,
    required this.controller,
    this.isNumberInput = false,
    this.onTap,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isReadOnly ? onTap : null, // Asegura que `onTap` funcione si es de solo lectura
      child: AbsorbPointer(
        absorbing: isReadOnly, // Deshabilita la interacción directa si es de solo lectura
        child: TextField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: isNumberInput ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}
