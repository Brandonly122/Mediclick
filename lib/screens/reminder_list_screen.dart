import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/login_screen.dart';
import '../screens/add_reminder_screen.dart';
import 'edit_screen.dart';
import '../widgets/reminder_card.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({Key? key}) : super(key: key);

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recordatorios',
          style: GoogleFonts.poppins(
            textStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresca la pantalla
              setState(() {});
            },
          ),
        ],
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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF64B5F6), Color(0xFF2196F3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditUserInfoScreen(userData: userData),
                              ),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: userData['profileImageUrl'] !=
                                          null &&
                                      userData['profileImageUrl'].isNotEmpty
                                  ? NetworkImage(userData['profileImageUrl'])
                                  : const AssetImage(
                                          'assets/default_avatar.png')
                                      as ImageProvider,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userData['name'] != null &&
                                      userData['lastName'] != null
                                  ? '${userData['name']} ${userData['lastName']}'
                                  : 'Nombre no especificado',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              userData['email'] ?? 'Correo no especificado',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.shieldVirus,
                    color: Colors.blue,
                  ),
                  title: const Text('¿Tiene alguna enfermedad?'),
                  subtitle: Text(
                    userData['hasIllness'] == true
                        ? userData['illnessDetails'] ?? 'No especificado'
                        : 'NO',
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.allergies,
                    color: Colors.orange,
                  ),
                  title: const Text('¿Tiene alguna alergia?'),
                  subtitle: Text(
                    userData['hasAllergy'] == true
                        ? userData['allergyDetails'] ?? 'No especificado'
                        : 'NO',
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.wheelchair,
                    color: Colors.purple,
                  ),
                  title: const Text('¿Tiene alguna discapacidad?'),
                  subtitle: Text(
                    userData['hasDisability'] == true
                        ? userData['disabilityDetails'] ?? 'No especificado'
                        : 'NO',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.signOutAlt,
                    color: Colors.red,
                  ),
                  title: const Text('Cerrar sesión'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
                    ? (data['time'] as Timestamp)
                        .toDate()
                        .toLocal()
                        .toString()
                    : 'Sin especificar',
                remainingDays: data['duration'] ?? 0,
                description: data['description'] ??
                    'Sin descripción', // Incluimos la descripción
                onDelete: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .collection('reminders')
                      .doc(reminder.id)
                      .delete();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: OpenContainer(
        closedShape: const CircleBorder(),
        closedColor: Colors.lightBlue,
        openBuilder: (context, _) => const AddReminderScreen(),
        closedBuilder: (context, openContainer) => FloatingActionButton(
          onPressed: openContainer,
          backgroundColor: Colors.lightBlue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
