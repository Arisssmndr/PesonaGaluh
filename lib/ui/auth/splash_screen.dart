import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Gradient lebih halus sesuai gambar
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C), // Ungu tua di atas
              Color(0xFF7B1FA2), // Ungu medium
              Colors.white,      // Putih di bawah
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo dengan dekorasi lingkaran halus (Glassmorphism)
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
              child: Image.asset(
                'assets/splashlogo.png',
                width: 120, // Ukuran logo disesuaikan agar proporsional
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.spa, size: 80, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Teks Nama Aplikasi (Dibuat lebih kecil & elegan sesuai gambar)
            const Text(
              "Pesona Galuh",
              style: TextStyle(
                fontSize: 20, // Teks tidak terlalu besar
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            // Jarak ke loading
            const SizedBox(height: 60),

            // Animasi Loading tipis
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3, // Garis loading lebih tipis
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
              ),
            ),

            const SizedBox(height: 20),
            // Teks loading kecil di bawahnya
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 12,
                color: Colors.purple[900]?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}