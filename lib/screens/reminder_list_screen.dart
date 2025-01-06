import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart'; // Importa la librería de diseño
import '../widgets/reminder_card.dart';

class ReminderListScreen extends StatelessWidget {
  const ReminderListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recordatorios',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),
      drawer: Drawer(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return ListView(
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text(
                      'Usuario',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(
                    title: const Text('Cargar información'),
                    onTap: () {},
                  ),
                ],
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListView(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Usuario',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nombre: ${userData['name']} ${userData['lastName']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Correo: ${userData['email']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.health_and_safety),
                  title: const Text('¿Tiene alguna enfermedad?'),
                  subtitle: Text(
                    userData['hasIllness'] == true
                        ? userData['illnessDetails'] ?? 'No especificado'
                        : 'NO',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.warning_amber_rounded),
                  title: const Text('¿Tiene alguna alergia?'),
                  subtitle: Text(
                    userData['hasAllergy'] == true
                        ? userData['allergyDetails'] ?? 'No especificado'
                        : 'NO',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.accessible),
                  title: const Text('¿Tiene alguna discapacidad?'),
                  subtitle: Text(
                    userData['hasDisability'] == true
                        ? userData['disabilityDetails'] ?? 'No especificado'
                        : 'NO',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar sesión'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Container(
        color: Colors.lightBlue.shade50, // Fondo celeste claro
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('reminders')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No hay recordatorios activos',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            final reminders = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                final data = reminder.data() as Map<String, dynamic>;

                return ReminderCard(
                  medicineName: data['medicineName'] ?? 'Medicamento',
                  dose: data['dose'] ?? 'Sin especificar',
                  time: data['time'] != null
                      ? (data['time'] as Timestamp).toDate().toLocal().toString()
                      : 'Sin especificar',
                  remainingDays: data['remainingDays'] ?? 0,
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Confirmar eliminación'),
                          content: const Text(
                              '¿Estás seguro de que quieres eliminar este recordatorio?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .collection('reminders')
                          .doc(reminder.id)
                          .delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Recordatorio eliminado'),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-reminder');
        },
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
