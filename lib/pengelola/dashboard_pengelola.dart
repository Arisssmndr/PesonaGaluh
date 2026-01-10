import 'package:flutter/material.dart';
import 'list_tempat.dart';   // Pastikan file ini ada di folder yang sama
import 'tambah_tempat.dart'; // Pastikan file ini ada di folder yang sama

class DashboardPengelola extends StatelessWidget {
  const DashboardPengelola({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengirim context agar navigasi di bar bawah berfungsi
      bottomNavigationBar: _bottomNav(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 16),
              _statisticCards(context),
              const SizedBox(height: 20),
              _quickMenu(context),
              const SizedBox(height: 20),
              _popularPlaces(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Home', // Diubah dari Dashboard ke Home
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Selamat datang, Pengelola Wisata',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ================= STAT CARDS =================
  Widget _statisticCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: constraints.maxWidth < 600 ? 2 : 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: const [
              _StatCard(
                icon: Icons.place,
                title: 'Total Tempat',
                value: '156',
                color: Color(0xFF9C27B0),
              ),
              _StatCard(
                icon: Icons.people,
                title: 'Pengunjung',
                value: '12.5K',
                color: Color(0xFF5C6BC0),
              ),
              _StatCard(
                icon: Icons.trending_up,
                title: 'Pendapatan',
                value: 'Rp 45M',
                color: Color(0xFF66BB6A),
              ),
              _StatCard(
                icon: Icons.star,
                title: 'Rating',
                value: '4.8',
                color: Color(0xFFFFCA28),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= QUICK MENU =================
  Widget _quickMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Cepat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.6,
            children: [
              // 1. KELOLA TEMPAT
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceListScreen(
                        user: User(role: 'pengelola'),
                        onNavigate: (screen) => print("Navigasi ke $screen"),
                        onLogout: () => print("Logout"),
                      ),
                    ),
                  );
                },
                child: const _QuickMenu(
                  title: 'Kelola Tempat',
                  icon: Icons.map,
                  filled: true,
                ),
              ),

              // 2. TAMBAH TEMPAT
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TambahTempatScreen()),
                  );
                },
                child: const _QuickMenu(
                  title: 'Tambah Tempat',
                  icon: Icons.add,
                ),
              ),

              // 3. PENDAPATAN
              const _QuickMenu(title: 'Pendapatan', icon: Icons.trending_up),

              // 4. PROFIL
              const _QuickMenu(title: 'Profil', icon: Icons.settings),
            ],
          ),
        ],
      ),
    );
  }

  // ================= POPULAR PLACES =================
  Widget _popularPlaces() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Tempat Populer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                'Lihat Semua',
                style: TextStyle(color: Color(0xFF9C27B0), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _PlaceTile(
            title: 'Curug Jami',
            subtitle: 'Curug',
            visitor: '2.3K pengunjung',
            image: 'https://images.unsplash.com/photo-1584810359583-96fc3448beaa',
          ),
          const _PlaceTile(
            title: 'Cadas Ngampar',
            subtitle: 'Sungai',
            visitor: '1.8K pengunjung',
            image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM NAV (MENU HOME) =================
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF9C27B0),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 1) { // Tab Tempat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceListScreen(
                user: User(role: 'pengelola'),
                onNavigate: (screen) => {},
                onLogout: () => {},
              ),
            ),
          );
        } else if (index == 2) { // Tab Tambah
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahTempatScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home), // Ikon Dashboard ganti ke Home
          label: 'Home',           // Label ganti ke Home
        ),
        BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Tempat'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Tambah'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}

// ================= COMPONENTS =================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title, value;
  final Color color;

  const _StatCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _QuickMenu extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool filled;

  const _QuickMenu({required this.title, required this.icon, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: filled ? const Color(0xFF7B1FA2) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: filled ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: filled ? Colors.white : const Color(0xFF9C27B0)),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: filled ? Colors.white : const Color(0xFF9C27B0),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  final String title, subtitle, visitor, image;

  const _PlaceTile({required this.title, required this.subtitle, required this.visitor, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(image, width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(visitor, style: const TextStyle(fontSize: 12, color: Color(0xFF9C27B0))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}