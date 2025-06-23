import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/home_screens/home_screen.dart';
import 'screens/login_screens/sign_in_screen.dart';
import 'screens/splash_screens/onboarding_screen.dart';
import 'services/login_services/auth_service.dart';
import 'services/login_services/fcm_service.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  

  await FCMService.initialize();
  
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

  @override
  void initState() {
    super.initState();
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _resetTimer();
      } else {
        _sessionTimer?.cancel();
      }
    });
    
    // Verificar si hay limpieza pendiente al inicializar
    _checkPendingCleanup();
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

  @override
  void dispose() {
    _sessionTimer?.cancel();
    FCMService.dispose();
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
        home: StreamBuilder<User?>(
          stream: _authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // Si hay un usuario autenticado, ir a HomeScreen
            if (snapshot.hasData && snapshot.data != null) {
              return const HomeScreen();
            }
            
            // Si no hay usuario, mostrar onboarding
            return const OnboardingScreen();
          },
        ),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/signin': (context) => const SignInScreen(),
        },
      ),
    );
  }
}
