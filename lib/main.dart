import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/home_screens/home_screen.dart';
import 'screens/login_screens/sign_in_screen.dart';
import 'screens/splash_screens/onboarding_screen.dart';
import 'services/login_services/auth_service.dart';
import 'services/login_services/fcm_service.dart';
import 'screens/quotes_screens/detail_quotes_screen.dart';
import 'screens/quotes_screens/quotes_screen.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('🔥 Firebase inicializado');
  
  // INICIALIZAR FCM SERVICE CON NOTIFICACIONES VISUALES
  try {
    print('🔥 Inicializando FCM Service completo...');
    await FCMService.initialize();
    
    print('🔥 Obteniendo token FCM...'); 
    final token = await FCMService.getToken();
    
    print('');
    print('🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥');
    print('🔥 TU TOKEN FCM ES:');
    print('🔥 ${token ?? 'TOKEN ES NULL'}');
    print('🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥');
    print('');
  } catch (e) {
    print('❌ Error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _sessionTimer;
  final _authService = AuthService();
  bool _isCheckingAuth = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    
    // Verificar usuario actual al iniciar
    _checkCurrentUser();
    
    // Agregar listener directo para debug
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print('🔥🔥🔥 FIREBASE AUTH DIRECTO - Usuario: ${user?.uid ?? 'null'}');
      print('🔥🔥🔥 FIREBASE AUTH DIRECTO - Email: ${user?.email ?? 'null'}');
      
      // Actualizar estado local
      setState(() {
        _currentUser = user;
        _isCheckingAuth = false;
      });
    });
    
    _authService.authStateChanges.listen((user) {
      print('🔥🔥🔥 AUTH SERVICE - Usuario: ${user?.uid ?? 'null'}');
      if (user != null) {
        _resetTimer();
      } else {
        _sessionTimer?.cancel();
      }
    });
    
    // Comentar temporalmente para evitar interferencia con la navegación
    // _checkPendingCleanup();
  }

  void _checkCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    print('🔥🔥🔥 VERIFICANDO USUARIO INICIAL: ${user?.uid ?? 'null'}');
    setState(() {
      _currentUser = user;
      _isCheckingAuth = false;
    });
  }

  void _checkPendingCleanup() async {
    try {
      final hadPendingCleanup = await _authService.checkAndProcessPendingCleanup();
      if (hadPendingCleanup) {
        // Si se realizó limpieza, navegar a la pantalla de login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
          );
        });
      }
    } catch (e) {
      print('Error al verificar limpieza pendiente: $e');
    }
  }

  void _resetTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(const Duration(minutes: 1), _handleTimeout);
  }

  void _handleTimeout() async {
    await _authService.handleSessionTimeout();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  Future<void> _showTokenDialog(BuildContext context) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Obteniendo token FCM...'),
            ],
          ),
        ),
      );

      // Obtener el token FCM directamente
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      
      // Cerrar loading
      if (context.mounted) Navigator.of(context).pop();

      if (token != null && context.mounted) {
        // Imprimir en consola
        print('🔥 TOKEN FCM DESDE BOTÓN: $token');
        
        // Mostrar en dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🔥 Tu Token FCM'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Copia este token para enviar notificaciones desde Firebase Console:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    token,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: token));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Token copiado al portapapeles'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text('Copiar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error: No se pudo obtener el token FCM'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Cerrar loading si está abierto
      if (context.mounted) Navigator.of(context).pop();
      
      print('Error al obtener token FCM: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer(),
      onScaleStart: (_) => _resetTimer(),
      behavior: HitTestBehavior.translucent,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Flutter App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: _buildHome(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/signin': (context) => const SignInScreen(),
          '/citas': (context) => const CitasScreen(),
          '/detalle-cita': (context) => const DetalleCitaScreen(),
        },
      ),
    );
  }

  Widget _buildHome() {
    print('🔥🔥🔥 BUILD HOME - isCheckingAuth: $_isCheckingAuth');
    print('🔥🔥🔥 BUILD HOME - currentUser: ${_currentUser?.uid ?? 'null'}');
    
    if (_isCheckingAuth) {
      print('🔥🔥🔥 BUILD HOME - Mostrando loading...');
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando autenticación...'),
            ],
          ),
        ),
      );
    } else if (_currentUser != null) {
      print('🔥🔥🔥 BUILD HOME - Usuario autenticado, mostrando HomeScreen');
      return const HomeScreen();
    } else {
      print('🔥🔥🔥 BUILD HOME - No hay usuario, mostrando OnboardingScreen');
      return const OnboardingScreen();
    }
  }
}
