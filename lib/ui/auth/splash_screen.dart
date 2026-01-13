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
    // Saya set kembali ke 3 detik biar gak kelamaan nunggu, atau ganti 6 kalau mau
    Timer(const Duration(seconds: 6), () {
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C),
              Color(0xFF7B1FA2),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- BAGIAN INI SUDAH DIPERBAIKI: TANPA CONTAINER BULAT ---
            Image.asset(
              'assets/splashtrans.png',
              width: 190, // Ukuran sedikit diperbesar karena sekarang tanpa padding container
              height: 190,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.spa, size: 80, color: Colors.white),
            ),
            // ----------------------------------------------------------

            const SizedBox(height: 20),

            const SizedBox(height: 60),

            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
              ),
            ),

            const SizedBox(height: 20),

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