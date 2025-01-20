import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class RegisterCard extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? icon;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;

  const RegisterCard({
    Key? key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.validator,
    this.onTap,
  }) : super(key: key);

  @override
  State<RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<RegisterCard> {
  bool _isPasswordVisible = false; // Estado para mostrar/ocultar la contraseña

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: -4,
          color: Colors.blueGrey[50],
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: widget.onTap != null
              ? Row(
                  children: [
                    if (widget.icon != null) Icon(widget.icon, color: Colors.blueGrey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.controller.text.isEmpty ? widget.label : widget.controller.text,
                        style: TextStyle(
                          color: widget.controller.text.isEmpty ? Colors.grey : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                )
              : TextFormField(
                  controller: widget.controller,
                  obscureText: widget.isPassword ? !_isPasswordVisible : false,
                  keyboardType: widget.keyboardType,
                  validator: widget.validator,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    border: InputBorder.none,
                    prefixIcon:
                        widget.icon != null ? Icon(widget.icon, color: Colors.blueGrey) : null,
                    suffixIcon: widget.isPassword
                        ? IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          )
                        : null,
                  ),
                  readOnly: widget.onTap != null,
                ),
        ),
      ),
    );
  }
}
