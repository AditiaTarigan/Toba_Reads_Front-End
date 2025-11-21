import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/loading_screen.dart';
import 'pages/profil_page.dart';
import 'pages/kuis_page.dart';

// Definisikan navigatorKey di luar main function
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AuthService sebelum runApp
  await AuthService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Kaitkan navigatorKey dengan MaterialApp
      debugShowCheckedModeBanner: false,
      title: 'TobaReads',
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => const LoadingScreenWrapper(),
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilPage(),
        '/kuis': (context) => const KuisPage(),
      },
    );
  }
}

class LoadingScreenWrapper extends StatefulWidget {
  const LoadingScreenWrapper({super.key});

  @override
  State<LoadingScreenWrapper> createState() => _LoadingScreenWrapperState();
}

class _LoadingScreenWrapperState extends State<LoadingScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    // Cek status login dari SharedPreferences
    final isLoggedIn = await AuthService.checkLoginStatus();

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (isLoggedIn) {
        // Update juga variable static
        AuthService.isLoggedIn = true;
        AuthService.userName = await AuthService.getUsername();

        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen();
  }
}
