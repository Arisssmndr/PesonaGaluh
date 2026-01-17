import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pusat Bantuan"),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("FAQ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _faq("Cara Ubah Profil?", "Klik tombol 'Edit Profil' di halaman akun."),
          _faq("Lupa Password?", "Gunakan fitur reset password saat login."),
          const SizedBox(height: 20),
          const Text("Hubungi Kami", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.email, color: Color(0xFF9C27B0)),
            title: const Text("admin@arisgaluh.com"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _faq(String q, String a) {
    return ExpansionTile(
      title: Text(q, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      children: [Padding(padding: const EdgeInsets.all(15), child: Text(a, style: const TextStyle(color: Colors.grey)))],
    );
  }
}