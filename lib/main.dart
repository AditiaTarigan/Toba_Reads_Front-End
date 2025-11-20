import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'main.dart'; // Import navigatorKey dan navigateTo

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); // Definisikan navigatorKey di sini

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
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}