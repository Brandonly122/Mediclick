import 'dart:io';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../widgets/register_card.dart';
import '../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  bool _isLoading = false;
  File? _profileImage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await StorageService().uploadProfileImage(
          _profileImage!,
          _emailController.text.trim(),
        );
      }

      await AuthService().registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        profileImageUrl: profileImageUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso. Inicia sesión.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar usuario: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.2,
                colors: [
                  Color(0xFFE3F2FD),
                  Color(0xFF64B5F6),
                  Color(0xFF1976D2),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/background_shapes.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    depth: 10,
                    color: Colors.white,
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(20)),
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
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? const Icon(Icons.camera_alt,
                                      size: 50, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          RegisterCard(
                            label: 'Correo Electrónico',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            icon: Icons.email,
                            validator: (value) => Validators.isValidEmail(value ?? '')
                                ? null
                                : 'Correo no válido.',
                          ),
                          const SizedBox(height: 16),
                          RegisterCard(
                            label: 'Contraseña',
                            controller: _passwordController,
                            isPassword: true,
                            icon: Icons.lock,
                            validator: (value) => Validators.isValidPassword(value ?? '')
                                ? null
                                : 'Contraseña débil.',
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
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );

                              if (pickedDate != null) {
                                String formattedDate =
                                    '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                                setState(() {
                                  _birthDateController.text = formattedDate;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : NeumorphicButton(
                                  onPressed: _registerUser,
                                  style: NeumorphicStyle(
                                    depth: 6,
                                    color: Colors.blueAccent,
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
                              Navigator.pushReplacementNamed(
                                  context, '/login');
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
        ],
      ),
    );
  }
}
