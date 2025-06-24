import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'auth_service.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final AuthService _authService = AuthService();
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static StreamSubscription<RemoteMessage>? _foregroundSubscription;
  static StreamSubscription<RemoteMessage>? _backgroundSubscription;

  /// Inicializa el servicio FCM
  static Future<void> initialize() async {
    try {
      print('🔥 Inicializando FCM Service...');
      
      // Inicializar notificaciones locales
      await _initializeLocalNotifications();
      
      // Solicitar permisos para notificaciones
      await _requestPermissions();
      
      // Configurar los listeners para notificaciones
      await _setupForegroundMessaging();
      await _setupBackgroundMessaging();
      
      // Obtener y guardar el token FCM
      await _getAndSaveToken();
      
      // Escuchar cambios en el token
      _setupTokenRefreshListener();
      
      print('✅ FCM Service inicializado correctamente');
    } catch (e) {
      print('❌ Error al inicializar FCM Service: $e');
    }
  }

  /// Inicializar notificaciones locales
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    
    await _localNotifications.initialize(initializationSettings);
    print('✅ Notificaciones locales inicializadas');
  }

  /// Solicitar permisos para notificaciones
  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Usuario otorgó permisos de notificación');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ Usuario otorgó permisos provisionales');
    } else {
      print('❌ Usuario rechazó o no aceptó permisos de notificación');
    }
  }

  /// Configurar listener para notificaciones en primer plano
  static Future<void> _setupForegroundMessaging() async {
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación recibida en primer plano: ${message.messageId}');
      
      // Mostrar la notificación visualmente cuando la app está en primer plano
      _showLocalNotification(message);
      
      // Manejar la lógica de seguridad
      _handleSecurityNotification(message);
    });
  }

  /// Configurar listener para notificaciones en segundo plano
  static Future<void> _setupBackgroundMessaging() async {
    // Notificaciones cuando la app está en segundo plano pero no terminada
    _backgroundSubscription = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación abierta desde segundo plano: ${message.messageId}');
      _handleSecurityNotification(message);
    });

    // Manejar notificación que abrió la app desde estado terminado
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('Notificación abrió la app desde estado terminado: ${initialMessage.messageId}');
      _handleSecurityNotification(initialMessage);
    }
  }

  /// Mostrar notificación local cuando la app está en primer plano
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'fcm_default_channel', // Canal de notificación
            'FCM Notifications', // Nombre del canal
            channelDescription: 'Notificaciones de Firebase Cloud Messaging',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          );
      
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );
      
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      await _localNotifications.show(
        message.hashCode, // ID único
        message.notification?.title ?? 'Notificación',
        message.notification?.body ?? 'Nueva notificación recibida',
        platformChannelSpecifics,
      );
      
      print('✅ Notificación local mostrada: ${message.notification?.title}');
    } catch (e) {
      print('❌ Error al mostrar notificación local: $e');
    }
  }

  /// Manejar notificaciones de seguridad que requieren cerrar sesión
  static Future<void> _handleSecurityNotification(RemoteMessage message) async {
    try {
      // Log de la notificación recibida
      print('Procesando notificación FCM:');
      print('Título: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');
      print('Datos: ${message.data}');

     
        if (message.data['action'] == 'security_logout') {
          await _clearSensitiveData();
        }
       
        // Ejemplo 2: Solo para ciertos tipos de notificaciones
        // if (message.data['type'] == 'security_alert' || message.data['force_logout'] == 'true') {
        //   await _clearSensitiveData();
        // }
        //
        // Ejemplo 3: Verificar múltiples condiciones
        // final shouldLogout = message.data['action'] == 'logout' || 
        //                      message.data['security_breach'] == 'true' ||
        //                      message.notification?.title?.contains('Alerta de Seguridad') == true;
        // if (shouldLogout) {
        //   await _clearSensitiveData();
        // }
        
        // CONFIGURACIÓN ACTUAL: Eliminar datos sensibles con cualquier notificación
        //await _clearSensitiveData();
        
        print('Datos sensibles eliminados por notificación FCM');
        
    } catch (e) {
      print('Error al procesar notificación FCM: $e');
    }
  }

  /// Eliminar todos los datos sensibles de la aplicación
  static Future<void> _clearSensitiveData() async {
    try {
      // 1. Cerrar sesión de Firebase
      await _authService.signOut();
      
      // 2. Limpiar almacenamiento seguro
      await _secureStorage.deleteAll();
      
      // 3. Aquí puedes agregar más limpieza de datos sensibles si es necesario
      // Por ejemplo: cache de imágenes, bases de datos locales, etc.
      
      print('Todos los datos sensibles han sido eliminados');
      
    } catch (e) {
      print('Error al eliminar datos sensibles: $e');
      // Intentar al menos cerrar sesión aunque fallen otros pasos
      try {
        await _authService.signOut();
      } catch (signOutError) {
        print('Error crítico: No se pudo cerrar sesión: $signOutError');
      }
    }
  }

  /// Obtener y guardar el token FCM en Firestore
  static Future<String?> _getAndSaveToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token obtenido: $token');
        await _saveTokenToFirestore(token);
        return token;
      }
    } catch (e) {
      print('Error al obtener token FCM: $e');
    }
    return null;
  }

  /// Guardar token FCM en Firestore
  static Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'platform': 'flutter', // Identificar la plataforma
        }, SetOptions(merge: true));
        
        print('Token FCM guardado en Firestore para usuario: ${user.uid}');
      }
    } catch (e) {
      print('Error al guardar token en Firestore: $e');
    }
  }

  /// Configurar listener para actualizaciones del token
  static void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('Token FCM actualizado: $newToken');
      _saveTokenToFirestore(newToken);
    });
  }

  /// Obtener el token FCM público (para uso manual)
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Suscribir al usuario a un tema específico
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Suscrito al tema: $topic');
    } catch (e) {
      print('Error al suscribirse al tema $topic: $e');
    }
  }

  /// Desuscribir al usuario de un tema específico
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Desuscrito del tema: $topic');
    } catch (e) {
      print('Error al desuscribirse del tema $topic: $e');
    }
  }

  /// Limpiar listeners cuando no se necesiten más
  static void dispose() {
    _foregroundSubscription?.cancel();
    _backgroundSubscription?.cancel();
  }

  /// Método manual para eliminar datos sensibles (uso de emergencia)
  static Future<void> manualClearSensitiveData() async {
    await _clearSensitiveData();
  }
}

/// Handler para notificaciones en segundo plano (debe estar fuera de la clase)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Manejando notificación en segundo plano: ${message.messageId}');
  
  // Para notificaciones en segundo plano, solo podemos hacer operaciones limitadas
  // La limpieza completa se hará cuando la app se abra
  try {
    // Guardar flag de que se necesita limpiar datos al abrir la app
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    await secureStorage.write(
      key: 'pending_security_cleanup',
      value: DateTime.now().toIso8601String(),
    );
  } catch (e) {
    print('Error al marcar limpieza pendiente: $e');
  }
} 