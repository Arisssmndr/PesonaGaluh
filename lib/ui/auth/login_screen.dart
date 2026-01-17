import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_screen.dart';
import '../../pengunjung/screens/dashboard_screen.dart';
import '../../pengelola/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  final Color primaryColor = const Color(0xFF6A1B9A);
  final Color accentColor = const Color(0xFF9C27B0);

  // --- LOGIC HANDLE (Tetap Sesuai Kode Aris) ---
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Harap isi email dan kata sandi!", isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc.get('role');
        if (mounted) {
          if (role == 'manager') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPengelola()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPengunjung()));
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Gagal Masuk", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String pesan, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // 1. BACKGROUND & LOGO TETAP (DI BELAKANG)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              color: primaryColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/splashtrans.png',
                    width: 180, // FOTO GEDE BANGET
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.auto_awesome, size: 100, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "PESONA GALUH",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. KOTAK PUTIH (BLOK UTUH YANG BERGESER NAIK)
          DraggableScrollableSheet(
            initialChildSize: 0.58, // Posisi awal kotak putih
            minChildSize: 0.58,     // Batas bawah
            maxChildSize: 0.98,     // Bisa ditarik sampai hampir full ke atas
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, -5))
                  ],
                ),
                child: SingleChildScrollView( // Pakai SingleChildScrollView agar satu blok geser
                  controller: scrollController,
                  // PENTING: NeverScrollableScrollPhysics agar kotaknya yang ditarik, bukan isinya
                  physics: const ClampingScrollPhysics(), 
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        // Handle bar seperti di Dashboard
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        const Text(
                          "Selamat Datang Kembali!",
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF6A1B9A)
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Silakan masuk untuk melanjutkan",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 40),

                        _buildModernField(
                          label: "Email Aktif",
                          controller: _emailController,
                          icon: Icons.alternate_email_rounded,
                        ),
                        const SizedBox(height: 20),
                        _buildModernField(
                          label: "Password",
                          controller: _passwordController,
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Lupa Password?",
                              style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // TOMBOL LOGIN
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "MASUK SEKARANG",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // FOOTER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Belum punya akun? ", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                              child: const Text(
                                "Daftar Di Sini",
                                style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 100), // Ruang agar konten tidak tertutup saat ditarik
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- MODERN FIELD (Selaras dengan Input di Register) ---
  Widget _buildModernField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor.withOpacity(0.8)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.1)), // Border tipis biar mewah
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? !_showPassword : false,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: isPassword ? "********" : "Masukkan $label",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: Icon(icon, color: primaryColor, size: 20),
              suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 18),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  )
                : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }
}