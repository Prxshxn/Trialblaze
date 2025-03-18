import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // For token storage
import 'package:createtrial/pages/newhome_page.dart'; // Default home page // Hiker home page
import 'package:createtrial/pages/responder_home_page.dart'; // Emergency responder home page
import 'package:createtrial/pages/landing_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 5), () {
      checkTokenAndRedirect();
    });
  }

  Future<void> checkTokenAndRedirect() async {
    try {
      // Retrieve the token from shared preferences (or cookies)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        // No token found, redirect to login
        redirectToLandingPage();
        return;
      }

      // Call the backend to verify the token
      final response = await http.get(
        Uri.parse('http://192.168.1.6:5000/api/v1/verify'),
        headers: {
          'Cookie': 'SessionID=$token', // Pass the token as a cookie
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userRole =
            data['user']['role']; // Assuming role is included in the token

        // Redirect based on user role
        if (userRole == 'hiker') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const HomePage(),
            ),
          );
        } else if (userRole == 'responder') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const ResponderHomePage(),
            ),
          );
        } else {
          // Default to HomePage if role is not recognized
          redirectToLandingPage();
        }
      } else {
        // Token is invalid or expired, redirect to login
        redirectToLandingPage();
      }
    } catch (e) {
      // Handle errors (e.g., network issues)
      redirectToLandingPage();
    }
  }

  void redirectToLandingPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LandingPage(),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
