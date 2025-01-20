import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // Liberar recursos de los controladores
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Inicia sesión con Firebase Auth
  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('Por favor, completa todos los campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showSnackbar('Inicio de sesión exitoso');
      Navigator.pushReplacementNamed(context, '/reminder-list');
    } on FirebaseAuthException catch (e) {
      // Manejo de excepciones de Firebase
      _handleAuthException(e);
    } catch (e) {
      // En caso de errores no manejados, se muestra un mensaje genérico
      _showSnackbar('Ocurrió un error inesperado. Inténtalo de nuevo.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Maneja excepciones específicas de Firebase Auth
  /// Maneja excepciones específicas de Firebase Auth
  void _handleAuthException(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No existe un usuario con ese correo electrónico.';
        break;
      case 'wrong-password':
        errorMessage = 'La contraseña es incorrecta.';
        break;
      case 'invalid-email':
        errorMessage = 'El correo electrónico no es válido.';
        break;
      case 'user-disabled':
        errorMessage = 'Esta cuenta ha sido desactivada.';
        break;
      case 'credential-already-in-use':
        errorMessage = 'Este correo ya está asociado a otra cuenta.';
        break;
      case 'operation-not-allowed':
        errorMessage =
            'El inicio de sesión con este método no está habilitado.';
        break;
      case 'auth/invalid-credential':
        errorMessage =
            'La credencial proporcionada no es válida, está malformada o ha caducado.';
        break;
      default:
        // Traducir mensaje genérico en inglés
        errorMessage = _translateFirebaseError(e.message);
    }
    _showSnackbar(errorMessage);
  }

  /// Traduce el mensaje genérico de Firebase al español
  String _translateFirebaseError(String? message) {
    if (message == null)
      return 'Ocurrió un error inesperado. Intenta de nuevo.';
    if (message.contains('The supplied auth credential is incorrect')) {
      return 'La credencial proporcionada no es válida, está malformada o ha caducado.';
    }
    return 'Error inesperado: $message';
  }

  /// Muestra un mensaje en la pantalla
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Genera decoraciones de los campos de entrada
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueGrey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: 8,
                    color: Colors.white,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'MEDICLICK',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          decoration: _buildInputDecoration(
                            'Correo Electrónico',
                            Icons.email,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: _buildInputDecoration(
                            'Contraseña',
                            Icons.lock,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blueGrey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : NeumorphicButton(
                                onPressed: _loginUser,
                                style: NeumorphicStyle(
                                  depth: 6,
                                  color: Colors.lightBlue,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(12)),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Iniciar Sesión',
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
                            Navigator.pushReplacementNamed(
                                context, '/register');
                          },
                          child: const Text(
                            '¿No tienes cuenta? Regístrate aquí',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
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
        ],
      ),
    );
  }
}
