import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'main.dart'; // Import navigatorKey dan navigateTo
import 'package:tobareads/pages/kuis_page.dart';
import 'pages/loading_screen.dart';
import 'pages/profil_page.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>(); // Definisikan navigatorKey di sini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Kaitkan navigatorKey dengan MaterialApp
      debugShowCheckedModeBanner: false,
      title: 'TobaReads',
      initialRoute: isLoggedIn ? '/home' : '/',

      routes: {
        '/loading': (context) => const LoadingScreenWrapper(),
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilPage(), // TAMBAH INI
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
    _redirectToHome(); // UBAH INI: langsung ke home
  }

  void _redirectToHome() async {
    // Langsung redirect ke HomePage setelah loading selesai
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // UBAH INI: ganti '/' dengan '/home'
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen();
  }
}
