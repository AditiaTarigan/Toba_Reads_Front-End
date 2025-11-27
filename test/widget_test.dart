import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tobareads/main.dart'; // Import MyApp
import 'package:tobareads/auth_pages/login_page.dart';
import 'package:tobareads/pages/home_page.dart';
import 'package:tobareads/auth_pages/register_page.dart';

class TestApp extends StatelessWidget {
  final bool isLoggedIn;

  const TestApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TobaReads Test',
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
      home: isLoggedIn ? const HomePage() : const LoginPage(), // Tambahkan home
    );
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const TestApp(isLoggedIn: false));

    // Verify that our counter starts at 0.
    // ... (sesuaikan dengan widget yang ada di LoginPage Anda)
    expect(find.text('Email'), findsOneWidget); // Contoh: memastikan TextField Email ada
    expect(find.text('Password'), findsOneWidget); // Contoh: memastikan TextField Password ada
  });
}