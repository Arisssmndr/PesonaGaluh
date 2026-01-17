import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "";
    _emailController.text = user?.email ?? "";
  }

  Future<void> _updateProfile() async {
    if (_emailController.text.isEmpty || _nameController.text.isEmpty) {
      _showSnackBar("Nama dan Email wajib diisi");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Update Nama
      if (_nameController.text != user?.displayName) {
        await user?.updateDisplayName(_nameController.text);
      }

      // 2. Update Email
      if (_emailController.text != user?.email) {
        await user?.verifyBeforeUpdateEmail(_emailController.text);
        _showSnackBar("Link verifikasi dikirim ke email baru.");
      }

      // 3. Update Password
      if (_passwordController.text.isNotEmpty) {
        if (_passwordController.text.length < 6) {
          throw 'Password minimal 6 karakter';
        }
        await user?.updatePassword(_passwordController.text);
      }

      // SINKRONISASI: Memaksa Firebase memperbarui data lokal di HP
      await user?.reload();

      if (mounted) {
        _showSnackBar("Profil diperbarui!");
        Navigator.pop(context, true); // Kirim 'true' sebagai tanda sukses
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showSnackBar("Sesi habis. Silakan Logout & Login ulang demi keamanan.");
      } else {
        _showSnackBar(e.message ?? "Gagal memperbarui profil");
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInput(controller: _nameController, label: "Nama Lengkap", icon: Icons.person),
            const SizedBox(height: 16),
            _buildInput(controller: _emailController, label: "Email", icon: Icons.email, type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildInput(controller: _passwordController, label: "Password Baru", icon: Icons.lock, isPass: true, hint: "Kosongkan jika tidak ganti"),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String label, required IconData icon, bool isPass = false, TextInputType type = TextInputType.text, String? hint}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF9C27B0)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9C27B0))),
      ),
    );
  }
}