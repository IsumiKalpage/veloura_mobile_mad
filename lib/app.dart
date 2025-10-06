import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/welcome_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'core/theme/theme_provider.dart';

class VelouraApp extends ConsumerStatefulWidget {
  const VelouraApp({super.key});

  @override
  ConsumerState<VelouraApp> createState() => _VelouraAppState();
}

class _VelouraAppState extends ConsumerState<VelouraApp> {
  final _storage = const FlutterSecureStorage();
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadThemePreference();
  }

  Future<void> _checkLoginStatus() async {
    final token = await _storage.read(key: "token");
    setState(() {
      _initialRoute = (token != null && token.isNotEmpty) ? '/home' : '/welcome';
    });
  }

  Future<void> _loadThemePreference() async {
    final savedTheme = await _storage.read(key: "themeMode");

    if (savedTheme != null) {
      final notifier = ref.read(themeModeProvider.notifier);
      switch (savedTheme) {
        case "dark":
          notifier.state = ThemeMode.dark;
          break;
        case "light":
          notifier.state = ThemeMode.light;
          break;
        default:
          notifier.state = ThemeMode.system;
      }
    }
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.dark:
        value = "dark";
        break;
      case ThemeMode.light:
        value = "light";
        break;
      default:
        value = "system";
    }
    await _storage.write(key: "themeMode", value: value);
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

    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeModeProvider);

        ref.listen<ThemeMode>(themeModeProvider, (previous, next) {
          if (previous != next) {
            _saveThemePreference(next);
          }
        });

        return MaterialApp.router(
          title: 'Veloura',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode, 
          routerConfig: router,
        );
      },
    );
  }
}
