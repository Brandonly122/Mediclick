import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  /// Inicializa Firebase Messaging
  static Future<void> initialize() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Solicitar permisos
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permiso de notificaciones push otorgado.');

      // Suscribirse al tema 'reminders'
      await messaging.subscribeToTopic('reminders');
      print('Suscrito al tema reminders.');
    } else {
      print('Permiso de notificaciones push denegado.');
      return;
    }

    // Obtener el token del dispositivo
    String? token = await messaging.getToken();
    print('FCM Token: $token');

    // Manejo de mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en primer plano:');
      print('Título: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');
    });

    // Manejo de mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }

  /// Manejador de notificaciones en segundo plano
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    print('Mensaje recibido en segundo plano:');
    print('Título: ${message.notification?.title}');
    print('Cuerpo: ${message.notification?.body}');
  }
}
