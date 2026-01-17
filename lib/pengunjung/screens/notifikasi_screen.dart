import 'package:flutter/material.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikasi"),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _item(Icons.local_offer, "Promo!", "Diskon khusus untuk Anda.", "2 jam lalu", true),
          _item(Icons.security, "Keamanan", "Profil berhasil diperbarui.", "1 hari lalu", false),
          _item(Icons.info, "Sistem", "Versi aplikasi terbaru tersedia.", "3 hari lalu", false),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String title, String desc, String time, bool unread) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFF9C27B0), child: Icon(icon, color: Colors.white, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        tileColor: unread ? const Color(0xFFF3E5F5) : null,
      ),
    );
  }
}