import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Pastikan tulisannya seperti ini
import 'register_screen.dart';
import '../../pengunjung/screens/dashboard_screen.dart';
import '../../pengelola/screens/dashboard_screen.dart';
// Import file dashboard pengelola kamu di sini, contoh:
// import '../../pengelola/screens/dashboard_pengelola.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // FUNGSI LOGIN DENGAN PENGECEKAN ROLE
  Future<void> _handleLogin() async {
    // Validasi input kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar("Harap isi email dan kata sandi!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Proses Sign In ke Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Ambil data dokumen user berdasarkan UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        // Ambil value dari field 'role' di Firestore
        String role = userDoc.get('role');

        if (mounted) {
          // 3. Logika Navigasi Berdasarkan Role
          if (role == 'manager') {
            // LOGIN SEBAGAI PENGELOLA
            _showSuccessSnackBar("Berhasil Masuk sebagai Pengelola");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPengelola()),
            );
          } else if (role == 'visitor') {
            // LOGIN SEBAGAI PENGUNJUNG
            _showSuccessSnackBar("Berhasil Masuk sebagai Pengunjung");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPengunjung()),
            );
          } else {
            // Jika ada role lain yang tidak terdaftar
            _showErrorSnackBar("Role pengguna tidak dikenali.");
          }
        }
      } else {
        _showErrorSnackBar("Data profile pengguna tidak ditemukan di database.");
      }
    } on FirebaseAuthException catch (e) {
      // Menangani error dari Firebase Auth (Email salah/Password salah)
      String errorMsg = "Gagal Masuk";
      if (e.code == 'user-not-found') {
        errorMsg = "Email tidak terdaftar.";
      } else if (e.code == 'wrong-password') {
        errorMsg = "Kata sandi salah.";
      } else if (e.code == 'invalid-email') {
        errorMsg = "Format email tidak valid.";
      } else {
        errorMsg = e.message ?? "Terjadi kesalahan.";
      }
      _showErrorSnackBar(errorMsg);
    } catch (e) {
      _showErrorSnackBar("Terjadi kesalahan sistem: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessSnackBar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: const Color(0xFF6A1B9A)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 70),

                Image.asset(
                  'assets/splashlogo.png',
                  width: 130,
                  height: 130,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.auto_awesome, size: 80, color: Color(0xFF6A1B9A)),
                ),

                const SizedBox(height: 10),
                const Text(
                  "Pesona Galuh",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  "Selamat datang kembali!",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFF3E5F5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF6A1B9A)),
                          hintText: "Masukkan email kamu",
                          fillColor: const Color(0xFFF8F5FB),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text("Kata Sandi", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6A1B9A)),
                          hintText: "••••••••",
                          fillColor: const Color(0xFFF8F5FB),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                              "Lupa Kata Sandi?",
                              style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "Masuk",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "Daftar Sekarang",
                        style: TextStyle(
                            color: Color(0xFF6A1B9A),
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}