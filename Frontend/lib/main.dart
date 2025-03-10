import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/HomePage.dart';
import 'screens/responder_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trail Safety App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/responder-home': (context) => const ResponderHomePage(),
        '/hiker-home': (context) => const HomePage(),
      },
    );
  }
}
