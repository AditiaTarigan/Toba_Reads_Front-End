import 'package:flutter/material.dart';
import 'package:tobareads/pages/kuis_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/loading_screen.dart';
import 'pages/profil_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth Demo',
      initialRoute: '/loading',
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
