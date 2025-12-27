import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../../pengunjung/screens/dashboard_screen.dart'; // Import dashboard pengunjung

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    // Navigasi langsung ke dashboard (Sementara)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPengunjung()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Berhasil Masuk")),
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

                // Logo Section - Bersih Tanpa Kotak
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

                // Card Login - Lebih Simpel Tanpa Role Selection
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
                      // Email Input
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

                      // Password Input
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

                      // Tombol Masuk
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
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

                // Register Link
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