import 'package:flutter/material.dart';
import 'register_screen.dart'; // Import sudah ditambahkan

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Default role adalah pengunjung
  String _selectedRole = 'pengunjung';

  void _handleLogin() {
    // Logic navigasi simpel untuk tes
    print("Login sebagai: $_selectedRole");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Masuk sebagai $_selectedRole")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background Putih Bersih
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Logo Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Image.asset(
                    'assets/splashlogo.jpeg',
                    width: 100,
                    height: 100,
                    // Muncul Icon jika gambar belum ada di assets
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.auto_awesome, size: 80, color: Color(0xFF6A1B9A)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Pesona Galuh",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  "Temukan Keindahan Wisata Indonesia",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Card Login
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
                      const Text(
                          "Masuk Sebagai",
                          style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 12),

                      // Role Selection (Grid-like)
                      Row(
                        children: [
                          _buildRoleButton('pengunjung'),
                          const SizedBox(width: 8),
                          _buildRoleButton('pengelola'),
                          const SizedBox(width: 8),
                          _buildRoleButton('admin'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Email Input
                      const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF6A1B9A)),
                          hintText: "email@example.com",
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

                      const SizedBox(height: 10),

                      // Submit Button
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
                const SizedBox(height: 30),

                // Bottom Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? "),
                    GestureDetector(
                      onTap: () {
                        // NAVIGASI DITAMBAHKAN DI SINI
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
                const SizedBox(height: 40),
                const Text(
                    "© 2024 Pesona Galuh. All rights reserved.",
                    style: TextStyle(color: Colors.grey, fontSize: 12)
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Button Role
  Widget _buildRoleButton(String role) {
    bool isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6A1B9A) : const Color(0xFFF8F5FB),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? null
                : Border.all(color: const Color(0xFFE1BEE7), width: 0.5),
          ),
          child: Center(
            child: Text(
              role[0].toUpperCase() + role.substring(1),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}