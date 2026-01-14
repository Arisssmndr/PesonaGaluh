import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambah ini untuk logout nanti
import 'favorit_screen.dart';
//import 'tiket_screen.dart';
import 'profil_screen.dart';
import 'detail_wisata_screen.dart';
import 'daftar.dart';

class DashboardPengunjung extends StatefulWidget {
  const DashboardPengunjung({super.key});

  @override
  State<DashboardPengunjung> createState() => _DashboardPengunjungState();
}

class _DashboardPengunjungState extends State<DashboardPengunjung> {
  int _selectedIndex = 0;

  // --- 1. DAFTAR HALAMAN ---
  // Kita buat fungsi agar halaman di-load dengan benar
  List<Widget> _getHalaman() {
    return [
      _buildBerandaContent(), // Index 0
      const FavoritScreen(), // Index 1
      const ProfilScreen(), // Index 2 (Pastikan ProfilScreen kamu ada const-nya)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Body akan berganti sesuai menu yang diklik
        child: _getHalaman()[_selectedIndex],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- 2. ISI BERANDA (Kodingan Estetik Kamu) ---
  Widget _buildBerandaContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopHeader(),
          _buildSearchBar(),
          _buildCategories(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Destinasi Populer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Cari bagian ini di kodingan Dashboard kamu
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const daftartempat(),
                      ),
                    );
                  },
                  child: const Text(
                    "Lihat Semua",
                    style: TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildWisataGrid(),
          const SizedBox(height: 100), // Kasih jarak biar gak ketutup nav bawah
        ],
      ),
    );
  }

  // --- FUNGSI HELPER UI ---

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=aris'),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: const [
                  Text(
                    "Lokasi Saya",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                ],
              ),
              Row(
                children: const [
                  Icon(Icons.location_on, color: Colors.red, size: 18),
                  Text(
                    " Ciamis, Jawa Barat",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          _buildNotificationIcon(),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: const Icon(Icons.notifications_outlined, color: Colors.black),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Cari tempat wisata...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    List<Map<String, dynamic>> categories = [
      {"name": "Danau", "icon": "🏞️"},
      {"name": "Air Terjun", "icon": "💧"},
      {"name": "Puncak", "icon": "⛰️"},
      {"name": "Hutan", "icon": "🌲"},
      {"name": "Pantai", "icon": "🏖️"},
    ];
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) => Container(
          width: 80,
          margin: const EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purple.shade50),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                categories[index]['icon'],
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 5),
              Text(
                categories[index]['name'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWisataGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => _buildWisataCard(context),
    );
  }

  Widget _buildWisataCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DetailWisataScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1604223190546-a43e4c7f29d7',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bukit Baros",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Color(0xFF6A1B9A),
                      ),
                      Text(
                        " Ciamis",
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Rp 15.000",
                        style: TextStyle(
                          color: Color(0xFF6A1B9A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 14),
                          Text(" 4.8", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(Icons.home_filled, "Beranda", 0),
          _navItem(Icons.favorite, "Favorit", 1),
          _navItem(Icons.person, "Profil", 2),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
