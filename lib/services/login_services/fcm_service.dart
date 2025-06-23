import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final AuthService _authService = AuthService();
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static StreamSubscription<RemoteMessage>? _foregroundSubscription;
  static StreamSubscription<RemoteMessage>? _backgroundSubscription;


  static Future<void> initialize() async {

    await _requestPermissions();
    

    await _setupForegroundMessaging();
    await _setupBackgroundMessaging();
    
    await _getToken();
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
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  /// Configurar listener para notificaciones en primer plano
  static Future<void> _setupForegroundMessaging() async {
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación recibida en primer plano: ${message.messageId}');
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

  /// Manejar notificaciones de seguridad que requieren cerrar sesión
  static Future<void> _handleSecurityNotification(RemoteMessage message) async {
    try {
      // Log de la notificación recibida
      print('Procesando notificación FCM:');
      print('Título: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');
      print('Datos: ${message.data}');

      // IMPORTANTE: Actualmente CUALQUIER notificación FCM resultará en eliminar datos sensibles
      // 
      // Si necesitas hacer esto más específico, puedes verificar los datos del mensaje:
      // Ejemplo 1: Solo para notificaciones de seguridad específicas
      // if (message.data['action'] == 'security_logout') {
      //   await _clearSensitiveData();
      // }
      //
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
      await _clearSensitiveData();
      
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

  /// Obtener el token FCM para debugging/registro
  static Future<String?> _getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error al obtener token FCM: $e');
      return null;
    }
  }

  /// Obtener el token FCM público (para registrar en el servidor)
  static Future<String?> getToken() async {
    return await _getToken();
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