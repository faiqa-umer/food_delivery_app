import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    
    // Wait 2 seconds for splash effect
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      // Token exists → go to profile
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      // No token → go to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 80, color: Color(0xFFFF4D00)),
            SizedBox(height: 20),
            Text(
              "Food Delivery App",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Color(0xFFFF4D00)),
          ],
        ),
      ),
    );
  }
}