import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; //
import 'firebase_options.dart'; // File ini otomatis ada setelah 'flutterfire configure'
import 'ui/auth/splash_screen.dart';

// Ubah main menjadi async agar bisa menunggu Firebase beres
void main() async {
  // 1. Pastikan binding Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase menggunakan opsi dari file yang kamu generate tadi
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pesona Galuh',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Saya ganti ungu biar match sama Profil
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    ),
  );
}