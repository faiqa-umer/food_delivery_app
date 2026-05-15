// ============================================================
// FILE: lib/main.dart
// PURPOSE: Entry point of the Flutter app.
//          Sets up the MaterialApp with theme and initial screen.
//          Replace HomeScreen with a LoginScreen in Phase 7
//          once authentication is added.
// ============================================================

import 'package:flutter/material.dart';
import 'customer/screens/home_screen.dart';

void main() {
  runApp(const FoodDeliveryApp());
}

class FoodDeliveryApp extends StatelessWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery App',
      debugShowCheckedModeBanner: false,

      // ── App Theme ────────────────────────────────────────────
      // Deep Orange is the primary brand color used across all screens.
      // Changing it here updates every widget that uses Theme.of(context).
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          primary: Colors.deepOrange,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',

        // Global AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        // Global ElevatedButton theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),

      // ── Initial Screen ────────────────────────────────────────
      // Phase 3 & 4: Start at HomeScreen (restaurant listing)
      // Phase 7: Replace with LoginScreen or SplashScreen
      home: const HomeScreen(),
    );
  }
}