import 'package:flutter/material.dart';
import 'detail_wisata_screen.dart';

class DashboardPengunjung extends StatefulWidget {
  const DashboardPengunjung({super.key});

  @override
  State<DashboardPengunjung> createState() => _DashboardPengunjungState();
}

class _DashboardPengunjungState extends State<DashboardPengunjung> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SESUAI FOTO ---
              _buildTopHeader(),

              // --- SEARCH BAR ---
              _buildSearchBar(),

              // --- CATEGORIES ---
              _buildCategories(),

              // --- PROMO BANNER ---
              _buildPromoBanner(),

              // --- DESTINASI POPULER (CARD DARI FIGMA) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Destinasi Populer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Lihat Semua", style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              _buildWisataGrid(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: _buildBottomNav(),
    );
  }

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
            children: [
              Row(
                children: const [
                  Text("Lokasi Saya", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                ],
              ),
              Row(
                children: const [
                  Icon(Icons.location_on, color: Colors.red, size: 18),
                  Text(" Ciamis, Jawa Barat", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: const Badge(
              label: Text("2"),
              child: Icon(Icons.notifications_outlined, color: Colors.black),
            ),
          ),
        ],
      ),
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(categories[index]['icon'], style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 5),
              Text(categories[index]['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Promo Spesial!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("Diskon 30% Tiket Masuk", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text("Ambil Promo"),
                )
              ],
            ),
          ),
          const Icon(Icons.confirmation_num_outlined, size: 80, color: Colors.white24),
        ],
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
      // Ganti bagian onTap di Card Wisata:
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1604223190546-a43e4c7f29d7'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10, right: 10,
                    child: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.8), child: const Icon(Icons.favorite_border, color: Colors.red, size: 20)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Bukit Baros", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Row(
                    children: const [
                      Icon(Icons.location_on, size: 12, color: Color(0xFF6A1B9A)),
                      Text(" Ciamis", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Rp 15.000", style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(Icons.home_filled, "Beranda", 0),
          _navItem(Icons.favorite, "Favorit", 1),
          _navItem(Icons.confirmation_number, "Tiket", 2),
          _navItem(Icons.person, "Profil", 3),
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
          Text(label, style: TextStyle(color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}