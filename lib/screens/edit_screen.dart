import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserInfoScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditUserInfoScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<EditUserInfoScreen> createState() => _EditUserInfoScreenState();
}

class _EditUserInfoScreenState extends State<EditUserInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _illnessController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _disabilityController = TextEditingController();
  File? _profileImage;

  bool _isPasswordVisible = false; // Para controlar la visibilidad de la contraseña

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData['name'] ?? '';
    _lastNameController.text = widget.userData['lastName'] ?? '';
    _emailController.text = widget.userData['email'] ?? '';
    _illnessController.text = widget.userData['illnessDetails'] ?? '';
    _allergyController.text = widget.userData['allergyDetails'] ?? '';
    _disabilityController.text = widget.userData['disabilityDetails'] ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado. Inicia sesión.')),
      );
      return;
    }

    try {
      String? profileImageUrl;
      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_pics/${user.uid}.jpg');
        await storageRef.putFile(_profileImage!);
        profileImageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'illnessDetails': _illnessController.text,
        'allergyDetails': _allergyController.text,
        'disabilityDetails': _disabilityController.text,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      });

      if (_passwordController.text.isNotEmpty) {
        await user.updatePassword(_passwordController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Información actualizada con éxito.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Información'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (widget.userData['profileImageUrl'] != null &&
                                widget.userData['profileImageUrl'].isNotEmpty
                            ? NetworkImage(widget.userData['profileImageUrl'])
                            : const AssetImage('assets/default_avatar.png')) as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Nombre', _nameController),
              _buildTextField('Apellido', _lastNameController),
              _buildTextField('Correo', _emailController),
              _buildPasswordField('Nueva Contraseña (opcional)', _passwordController),
              _buildTextField('Detalles de Enfermedad', _illnessController),
              _buildTextField('Detalles de Alergia', _allergyController),
              _buildTextField('Detalles de Discapacidad', _disabilityController),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(12.0),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }
}
