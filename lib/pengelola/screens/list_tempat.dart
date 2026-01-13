import 'package:flutter/material.dart';
import 'tambah_tempat.dart';

// Model Data (Pastikan ini ada agar tidak error)
class User {
  final String role;
  User({required this.role});
}

class Place {
  final int id;
  final String name, location, category, price, image;
  final double rating;
  Place({required this.id, required this.name, required this.location, required this.category, required this.rating, required this.price, required this.image});
}

class PlaceListScreen extends StatefulWidget {
  final User user;
  final void Function(String screen) onNavigate;
  final VoidCallback onLogout;

  const PlaceListScreen({super.key, required this.user, required this.onNavigate, required this.onLogout});

  @override
  State<PlaceListScreen> createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends State<PlaceListScreen> {
  String searchQuery = '';
  String selectedCategory = 'Semua';

  final List<String> categories = ['Semua', 'Pantai', 'Gunung', 'Candi', 'Air Terjun', 'Taman'];
  final List<Place> places = [
    Place(id: 1, name: 'Candi Borobudur', location: 'Magelang, Jawa Tengah', category: 'Candi', rating: 4.9, price: 'Rp 50.000', image: 'https://images.unsplash.com/photo-1675506364186-4952f2110966'),
    Place(id: 2, name: 'Pantai Kuta', location: 'Bali', category: 'Pantai', rating: 4.7, price: 'Gratis', image: 'https://images.unsplash.com/photo-1751814585162-bf482977e3d0'),
    Place(id: 3, name: 'Gunung Bromo', location: 'Probolinggo, Jawa Timur', category: 'Gunung', rating: 4.8, price: 'Rp 35.000', image: 'https://images.unsplash.com/photo-1604223190546-a43e4c7f29d7'),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = places.where((place) {
      final matchesSearch = place.name.toLowerCase().contains(searchQuery.toLowerCase()) || place.location.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'Semua' || place.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.purple[50],
      // MENGGUNAKAN BottomNavigationBar AGAR SAMA DENGAN HOME
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Set ke 1 karena ini halaman "Tempat"
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF9C27B0),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); // Kembali ke Home
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahTempatScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Tempat'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Tambah'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF800080)]),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Jelajahi Wisata',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      hintText: 'Cari tempat wisata...',
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      hintStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Kategori Chip
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (_) => setState(() => selectedCategory = category),
                    ),
                  );
                },
              ),
            ),
            // List Card
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredPlaces.length,
                itemBuilder: (context, index) {
                  final place = filteredPlaces[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: Image.network(place.image, height: 180, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(place.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(place.location, style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(place.price, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                                  Row(children: [const Icon(Icons.star, color: Colors.amber, size: 20), Text(place.rating.toString())]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}