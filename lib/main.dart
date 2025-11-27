import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'auth_pages/login_page.dart';
import 'auth_pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/profil_page.dart';
import 'pages/kuis_page.dart';
import 'pages/upload_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TobaReads',
      initialRoute: '/home',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilPage(),
        '/kuis': (context) => const KuisPage(),
        '/upload': (context) => const UnggahKaryaPage(),
      },
    );
  }
}
