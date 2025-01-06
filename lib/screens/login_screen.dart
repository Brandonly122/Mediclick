import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/neumorphic_input_field.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Estado para mostrar el indicador de carga

  Future<void> _loginUser() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      // Validar que los campos no estén vacíos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Muestra el indicador de carga
    });

    try {
      // Intenta iniciar sesión
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de sesión exitoso')),
      );

      // Navega a la pantalla de la lista de recordatorios
      Navigator.pushReplacementNamed(context, '/reminder-list');
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      // Maneja errores específicos de Firebase
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
          errorMessage = 'La cuenta está deshabilitada.';
          break;
        case 'too-many-requests':
          errorMessage = 'Demasiados intentos. Inténtalo más tarde.';
          break;
        case 'network-request-failed':
          errorMessage = 'Sin conexión a internet.';
          break;
        default:
          errorMessage = 'Ocurrió un error inesperado. Inténtalo de nuevo.';
          break;
      }

      // Muestra el mensaje en un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Maneja errores generales
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al iniciar sesión. Inténtalo más tarde.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Oculta el indicador de carga
      });
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'MEDICLICK',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 18, 223, 255),
                        ),
                      ),
                      const SizedBox(height: 16),
                      NeumorphicInputField(
                        label: 'Correo Electrónico',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      NeumorphicInputField(
                        label: 'Contraseña',
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator() // Muestra indicador de carga
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
                          // Navegar a la pantalla de registro
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                        child: const Text(
                          '¿No tienes cuenta? Regístrate aquí',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          // Navegar a la pantalla de recuperación de contraseña
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
      ),
    );
  }
}
