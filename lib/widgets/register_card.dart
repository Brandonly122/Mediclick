import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class RegisterCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? icon;
  final String? Function(String?)? validator; // Agregamos el parámetro validator

  const RegisterCard({
    Key? key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.validator, // Inicializamos validator
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -4,
        color: Colors.blueGrey[50],
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator, // Agregamos la validación aquí
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            prefixIcon: icon != null ? Icon(icon, color: Colors.blueGrey) : null,
          ),
        ),
      ),
    );
  }
}
