import 'package:flutter/material.dart';
// Import mengarah ke folder ui/auth
import 'ui/auth/splash_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pesona Galuh',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Memanggil class SplashScreen dari folder auth
      home: SplashScreen(),
    ),
  );
}