import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Manejar cierre de sesión por inactividad
  Future<void> handleSessionTimeout() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final idToken = await user.getIdToken();
      await _secureStorage.write(key: 'last_inactive_token', value: idToken);
      await _secureStorage.write(
        key: 'session_timeout_timestamp',
        value: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // Si hay un error, lo registramos pero continuamos con el logout
      print('Error al guardar datos de sesión inactiva: $e');
    } finally {
      // Cerramos la sesión independientemente de si se guardaron los datos
      await signOut();
    }
  }

  // Iniciar sesión con email y contraseña
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Si hay un error de serialización pero el usuario está autenticado, 
      // devolvemos null pero el usuario seguirá logueado
      if (e.toString().contains('PigeonUserDetails') && _auth.currentUser != null) {
        print('Warning: Serialization error but user is authenticated: ${_auth.currentUser?.uid}');
        return null; // El usuario está autenticado aunque haya error
      }
      rethrow;
    }
  }

  // Crear cuenta con email y contraseña
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Enviar email de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Iniciar sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Inicia el flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        return null;
      }

      // Obtiene los detalles de autenticación de la solicitud
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crea una nueva credencial
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Inicia sesión en Firebase con la credencial de Google
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // Si hay un error de serialización pero el usuario está autenticado, 
      // devolvemos null pero el usuario seguirá logueado
      if (e.toString().contains('PigeonUserDetails') && _auth.currentUser != null) {
        print('Warning: Serialization error but user is authenticated: ${_auth.currentUser?.uid}');
        return null; // El usuario está autenticado aunque haya error
      }
      rethrow;
    }
  }

  // Verificar y procesar limpieza pendiente por notificaciones FCM
  Future<bool> checkAndProcessPendingCleanup() async {
    try {
      final pendingCleanup = await _secureStorage.read(key: 'pending_security_cleanup');
      if (pendingCleanup != null) {
        print('Procesando limpieza pendiente desde: $pendingCleanup');
        
        // Ejecutar limpieza completa
        await signOut();
        await _secureStorage.deleteAll();
        
        print('Limpieza pendiente completada');
        return true; // Indica que se realizó limpieza
      }
      return false; // No había limpieza pendiente
    } catch (e) {
      print('Error al verificar limpieza pendiente: $e');
      return false;
    }
  }

  // Limpiar todos los datos sensibles (método completo)
  Future<void> clearAllSensitiveData() async {
    try {
      // Cerrar sesión
      await signOut();
      
      // Limpiar almacenamiento seguro completo
      await _secureStorage.deleteAll();
      
      print('Todos los datos sensibles han sido eliminados');
    } catch (e) {
      print('Error al eliminar datos sensibles: $e');
      rethrow;
    }
  }
}
