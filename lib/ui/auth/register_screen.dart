import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_options.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'visitor';
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  // FUNGSI REGISTRASI KE FIREBASE (DENGAN PENYIMPANAN ROLE)
  Future<void> _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      _showSnackBar("Harap isi semua bidang!");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Konfirmasi password tidak cocok!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Proses Daftarkan ke Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Simpan Data Role & Nama ke Cloud Firestore
      // UID diambil dari hasil pendaftaran Auth di atas
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nama': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole, // Menyimpan 'visitor' atau 'manager'
        'createdAt': DateTime.now(),
      });

      if (mounted) {
        _showSnackBar("Akun ${_selectedRole == 'manager' ? 'Pengelola' : 'Pengunjung'} Berhasil Dibuat!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Terjadi kesalahan";
      if (e.code == 'weak-password') {
        errorMsg = "Password terlalu lemah (min. 6 karakter).";
      } else if (e.code == 'email-already-in-use') {
        errorMsg = "Email ini sudah terdaftar.";
      } else if (e.code == 'invalid-email') {
        errorMsg = "Format email salah.";
      }
      _showSnackBar(errorMsg);
    } catch (e) {
      _showSnackBar("Gagal daftar: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String pesan) {
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6A1B9A)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Image.asset(
                'assets/splashlogo.png',
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.auto_awesome, size: 80, color: Color(0xFF6A1B9A)),
              ),

              const SizedBox(height: 10),
              const Text(
                  "PESONA GALUH",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))
              ),
              const Text("Daftar akun baru", style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5)
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField("Nama Lengkap", _nameController, Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildTextField("Email", _emailController, Icons.mail_outline),
                    const SizedBox(height: 16),

                    const Text(
                        "Daftar Sebagai",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildRoleButton("Pengunjung", "visitor", "👤"),
                        const SizedBox(width: 12),
                        _buildRoleButton("Pengelola", "manager", "👨‍💼"),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _buildPasswordField("Password", _passwordController, _showPassword, () => setState(() => _showPassword = !_showPassword)),
                    const SizedBox(height: 16),
                    _buildPasswordField("Konfirmasi Password", _confirmPasswordController, _showConfirmPassword, () => setState(() => _showConfirmPassword = !_showConfirmPassword)),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Daftar Sekarang", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF6A1B9A)),
            filled: true,
            fillColor: const Color(0xFFF3E5F5).withOpacity(0.4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isVisible, VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6A1B9A)),
            suffixIcon: IconButton(icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility), onPressed: toggle),
            filled: true,
            fillColor: const Color(0xFFF3E5F5).withOpacity(0.4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleButton(String label, String roleValue, String emoji) {
    bool isSelected = _selectedRole == roleValue;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRole = roleValue),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6A1B9A) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF6A1B9A), width: 1.5),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              Text(
                  label,
                  style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF6A1B9A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}