import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTestScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTestDocument() async {
    try {
      await _firestore.collection('users').add({
        'email': 'test@example.com',
        'name': 'Test',
        'lastName': 'User',
        'birthDate': '2000-01-01',
        'hasIllness': false,
        'illnessDetails': null,
        'hasAllergy': true,
        'allergyDetails': 'Polen',
        'hasDisability': false,
        'disabilityDetails': null,
      });
      print('Documento añadido con éxito');
    } catch (e) {
      print('Error al añadir documento: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prueba de Firestore')),
      body: Center(
        child: ElevatedButton(
          onPressed: addTestDocument,
          child: Text('Añadir Documento de Prueba'),
        ),
      ),
    );
  }
}
