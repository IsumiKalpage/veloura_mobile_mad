import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/welcome_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/home/presentation/home_screen.dart';

class VelouraApp extends StatefulWidget {
  const VelouraApp({super.key});

  @override
  State<VelouraApp> createState() => _VelouraAppState();
}

class _VelouraAppState extends State<VelouraApp> {
  final _storage = const FlutterSecureStorage();
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await _storage.read(key: "token");

    setState(() {
      _initialRoute =
          (token != null && token.isNotEmpty) ? '/home' : '/welcome';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialRoute == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFA4161A)),
          ),
        ),
      );
    }

    final router = GoRouter(
      initialLocation: _initialRoute!,
      routes: [
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Veloura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
