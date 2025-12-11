import 'package:flutter/material.dart';
import 'package:tobareads/users/account/account_screen.dart';
import 'services/auth_service.dart';
import 'auth_pages/login_page.dart';
import 'auth_pages/register_page.dart';
import 'users/home_page.dart';
import 'users/profil_page.dart';
import 'users/kuis/kuis_page.dart';
import 'users/unggah_karya/karya_page.dart';
import 'users/karya_favorite/favorite_page.dart';

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
        '/karya_saya': (context) => const KaryaSayaPage(),
        '/akun_saya': (context) => AccountScreen(),
      },
    );
  }
}
