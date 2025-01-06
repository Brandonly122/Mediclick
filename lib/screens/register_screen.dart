import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/register_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _illnessDetailsController = TextEditingController();
  final TextEditingController _allergyDetailsController = TextEditingController();
  final TextEditingController _disabilityDetailsController = TextEditingController();

  bool _hasIllness = false;
  bool _hasAllergy = false;
  bool _hasDisability = false;
  bool _isLoading = false; // Para mostrar un indicador de carga

  String? _validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    if (!regex.hasMatch(password)) {
      return 'La contraseña debe tener al menos 8 caracteres y un número.';
    }
    return null;
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Registro en Firebase Auth
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Guardar en Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'birthDate': _birthDateController.text.trim(),
          'hasIllness': _hasIllness,
          'illnessDetails': _illnessDetailsController.text.trim(),
          'hasAllergy': _hasAllergy,
          'allergyDetails': _allergyDetailsController.text.trim(),
          'hasDisability': _hasDisability,
          'disabilityDetails': _disabilityDetailsController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso. Inicia sesión.')),
        );

        Navigator.pushReplacementNamed(context, '/login'); // Redirigir al login
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Este correo ya está registrado.';
            break;
          case 'invalid-email':
            errorMessage = 'Correo electrónico no válido.';
            break;
          case 'weak-password':
            errorMessage = 'La contraseña es muy débil.';
            break;
          default:
            errorMessage = 'Error inesperado. Intenta de nuevo.';
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blueGrey[50],
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: 8,
                  color: Colors.white,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Registro de Usuario',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        RegisterCard(
                          label: 'Correo Electrónico',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 16),
                        RegisterCard(
                          label: 'Contraseña',
                          controller: _passwordController,
                          isPassword: true,
                          icon: Icons.lock,
                          validator: (value) => _validatePassword(value!),
                        ),
                        const SizedBox(height: 16),
                        RegisterCard(
                          label: 'Confirmar Contraseña',
                          controller: _confirmPasswordController,
                          isPassword: true,
                          icon: Icons.lock,
                        ),
                        const SizedBox(height: 16),
                        RegisterCard(
                          label: 'Nombre',
                          controller: _nameController,
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        RegisterCard(
                          label: 'Apellido',
                          controller: _lastNameController,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        RegisterCard(
                          label: 'Fecha de Nacimiento',
                          controller: _birthDateController,
                          icon: Icons.calendar_today,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('¿Tiene alguna enfermedad?'),
                          value: _hasIllness,
                          onChanged: (value) {
                            setState(() {
                              _hasIllness = value;
                            });
                          },
                        ),
                        if (_hasIllness)
                          RegisterCard(
                            label: 'Especifique la enfermedad',
                            controller: _illnessDetailsController,
                          ),
                        SwitchListTile(
                          title: const Text('¿Tiene alguna alergia?'),
                          value: _hasAllergy,
                          onChanged: (value) {
                            setState(() {
                              _hasAllergy = value;
                            });
                          },
                        ),
                        if (_hasAllergy)
                          RegisterCard(
                            label: 'Especifique la alergia',
                            controller: _allergyDetailsController,
                          ),
                        SwitchListTile(
                          title: const Text('¿Tiene alguna discapacidad?'),
                          value: _hasDisability,
                          onChanged: (value) {
                            setState(() {
                              _hasDisability = value;
                            });
                          },
                        ),
                        if (_hasDisability)
                          RegisterCard(
                            label: 'Especifique la discapacidad',
                            controller: _disabilityDetailsController,
                          ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : NeumorphicButton(
                                onPressed: _registerUser,
                                style: NeumorphicStyle(
                                  depth: 6,
                                  color: Colors.lightBlue,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(12)),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Registrar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            '¿Ya tienes cuenta? Inicia sesión',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
