import 'package:flutter/material.dart';

class FavoritScreen extends StatelessWidget {
  const FavoritScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- JUDUL HALAMAN ---
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 20),
              child: Text(
                "Favorit Saya",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // --- SEARCH BAR (Sama seperti Dashboard) ---
            _buildSearchBar(),

            // --- CATEGORIES (Sama seperti Dashboard) ---
            _buildCategories(),

            // --- GRID WISATA FAVORIT (2 KOLOM) ---
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.75, // Menyesuaikan tinggi card
                ),
                itemCount: 6, // Contoh jumlah data
                itemBuilder: (context, index) => _buildFavoritGridCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: "Cari favoritmu...",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    List<String> categories = ["Semua", "Danau", "Air Terjun", "Puncak", "Hutan", "Pantai"];

    return Container(
      height: 45, // Lebih tipis dan elegan
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = index == 0; // Simulasi kategori pertama terpilih
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black87 : Colors.white, // Warna gelap sesuai gambar
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                categories[index],
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 13
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritGridCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar & Icon Love
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1604223190546-a43e4c7f29d7'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: const Icon(Icons.favorite, color: Colors.red, size: 16),
                  ),
                ),
              ],
            ),
          ),
          // Info: Nama, Lokasi, Harga
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bukit Baros",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.location_on, size: 12, color: Color(0xFF6A1B9A)),
                    Expanded(
                      child: Text(
                        " Ciamis, Jawa Barat",
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Rp 15.000",
                  style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}