import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../ui/auth/login_screen.dart'; // Sesuaikan path login
import 'edit_profil_screen.dart';
import 'notifikasi_screen.dart';
import 'help_screen.dart';
import 'privasi_screen.dart'; // Pastikan file ini dibuat

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  void _refreshData() async {
    await user?.reload();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF3E5F5)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 10),
                    _buildSectionTitle("Pengaturan"),

                    // 1. Tombol Pengaturan Akun (Berfungsi)
                    _buildMenuButton(Icons.settings, "Pengaturan Akun", () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilScreen()));
                      _refreshData();
                    }),

                    // 2. Tombol Privasi (Berfungsi)
                    _buildMenuButton(Icons.lock_outline, "Privasi", () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivasiScreen()));
                    }),

                    // 3. Tombol Notifikasi (Berfungsi)
                    _buildMenuButton(Icons.notifications_none, "Notifikasi", () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NotifikasiScreen()));
                    }),

                    // 4. Tombol Bantuan (Berfungsi)
                    _buildMenuButton(Icons.help_outline, "Bantuan", () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
                    }),

                    const SizedBox(height: 30),
                    _buildLogoutButton(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 30, bottom: 40),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Text("Profil Saya", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProfileCard() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(25),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Color(0xFFBA68C8), child: Icon(Icons.person, size: 60, color: Colors.white)),
            const SizedBox(height: 10),
            Text(user?.displayName ?? "User", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _info(Icons.mail_outline, "Email", user?.email ?? "-"),
            _info(Icons.lock_outline, "Password", "******"),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilScreen()));
                  _refreshData();
                },
                icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                label: const Text("Edit Profil", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9C27B0), size: 20),
          const SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(vertical: 10), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));

  Widget _buildMenuButton(IconData icon, String title, VoidCallback onTap) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: ListTile(leading: Icon(icon, color: const Color(0xFF9C27B0)), title: Text(title, style: const TextStyle(fontSize: 14)), trailing: const Icon(Icons.chevron_right), onTap: onTap),
  );

  Widget _buildLogoutButton() => TextButton(
    onPressed: () async {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
    },
    child: const Text("Keluar Akun", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
  );
}