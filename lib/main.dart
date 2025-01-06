import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firebase_messaging_service.dart';
import 'screens/add_reminder_screen.dart';
import 'screens/reminder_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar el servicio de Firebase Messaging
  await FirebaseMessagingService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Recordatorios',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
        ),
      ),
      // Verificar si el usuario ya está logueado y configurar la ruta inicial
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/reminder-list',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/reminder-list': (context) => const ReminderListScreen(),
        '/add-reminder': (context) => const AddReminderScreen(),
      },
    );
  }
}
