import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
    required String lastName,
    required String birthDate,
    String? profileImageUrl,
    bool hasIllness = false,
    String? illnessDetails,
    bool hasAllergy = false,
    String? allergyDetails,
    bool hasDisability = false,
    String? disabilityDetails,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'name': name,
        'lastName': lastName,
        'birthDate': birthDate,
        'profileImageUrl': profileImageUrl ?? '',
        'hasIllness': hasIllness,
        'illnessDetails': illnessDetails ?? '',
        'hasAllergy': hasAllergy,
        'allergyDetails': allergyDetails ?? '',
        'hasDisability': hasDisability,
        'disabilityDetails': disabilityDetails ?? '',
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      throw e;
    }
  }
}
