import 'package:flutter/material.dart';

class PrivasiScreen extends StatelessWidget {
  const PrivasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keamanan & Privasi"),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _tile("Izinkan Lokasi", true),
          _tile("Tampilkan Email di Publik", false),
          _tile("Notifikasi Email", true),
          const Divider(),
          ListTile(
            title: const Text("Kebijakan Privasi", style: TextStyle(color: Color(0xFF9C27B0))),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _tile(String title, bool val) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: val,
      activeColor: const Color(0xFF9C27B0),
      onChanged: (bool value) {},
    );
  }
}