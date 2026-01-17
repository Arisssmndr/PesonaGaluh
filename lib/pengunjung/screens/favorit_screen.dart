import 'package:flutter/material.dart';
// Pastikan folder 'data' dan file 'favorit_data.dart' sudah ada
import '../../data/favorit_data.dart'; 

class FavoritScreen extends StatefulWidget {
  const FavoritScreen({super.key});

  @override
  State<FavoritScreen> createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  String selectedCategory = "Semua";
  
  // Kategori disesuaikan agar nyambung dengan data Firebase kamu
  List<String> categories = ["Semua", "Sungai", "Alam", "Air Terjun", "Puncak", "Hutan"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder(
          // Memantau favoritNotifier dari file favorit_data.dart
          valueListenable: favoritNotifier, 
          builder: (context, List<Map<String, dynamic>> listFavorit, child) {
            
            // Logika Filter Kategori
            List<Map<String, dynamic>> filteredList = selectedCategory == "Semua"
                ? listFavorit
                : listFavorit.where((item) => item['category'] == selectedCategory).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
                  child: Text(
                    "Favorit Saya",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1),
                  ),
                ),
                
                _buildSearchBar(),
                _buildCategoryList(),

                // --- GRID DATA ---
                Expanded(
                  child: filteredList.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 18,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return _buildFavoritGridCard(filteredList[index]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET SEARCH BAR ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: "Cari di favorit...",
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 20),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // --- WIDGET CATEGORY LIST ---
  Widget _buildCategoryList() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == categories[index];
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = categories[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6A1B9A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                boxShadow: isSelected 
                  ? [BoxShadow(color: const Color(0xFF6A1B9A).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                  : [],
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET CARD GRID ---
  Widget _buildFavoritGridCard(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: DecorationImage(
                      image: NetworkImage(data['imagePath'] ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 10, right: 10,
                  child: GestureDetector(
                    onTap: () {
                      // Fungsi hapus favorit
                      List<Map<String, dynamic>> current = List.from(favoritNotifier.value);
                      current.removeWhere((item) => item['name'] == data['name']);
                      favoritNotifier.value = current;
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      radius: 14,
                      child: const Icon(Icons.favorite, color: Colors.red, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Color(0xFF6A1B9A)),
                    Expanded(
                      child: Text(" ${data['location']}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Rp ${data['price']}",
                  style: const TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline_rounded, size: 100, color: Colors.grey[200]),
          const SizedBox(height: 20),
          const Text(
            "Belum ada favorit", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)
          ),
          const Text(
            "Klik ❤️ pada destinasi yang kamu suka!", 
            style: TextStyle(color: Colors.grey)
          ),
        ],
      ),
    );
  }
} // AKHIR DARI CLASS _FavoritScreenState