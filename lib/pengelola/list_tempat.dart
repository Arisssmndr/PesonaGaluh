import 'package:flutter/material.dart';

class User {
  final String role;
  User({required this.role});
}

class Place {
  final int id;
  final String name;
  final String location;
  final String category;
  final double rating;
  final String price;
  final String image;

  Place({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.rating,
    required this.price,
    required this.image,
  });
}

class PlaceListScreen extends StatefulWidget {
  final User user;
  final void Function(String screen) onNavigate;
  final VoidCallback onLogout;

  const PlaceListScreen({
    super.key,
    required this.user,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  State<PlaceListScreen> createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends State<PlaceListScreen> {
  String searchQuery = '';
  String selectedCategory = 'Semua';
  List<int> favorites = [1, 3];

  final List<String> categories = ['Semua', 'Pantai', 'Gunung', 'Candi', 'Air Terjun', 'Taman'];

  final List<Place> places = [
    Place(
      id: 1,
      name: 'Candi Borobudur',
      location: 'Magelang, Jawa Tengah',
      category: 'Candi',
      rating: 4.9,
      price: 'Rp 50.000',
      image: 'https://images.unsplash.com/photo-1675506364186-4952f2110966?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0ZW1wbGUlMjB0b3VyaXNtfGVufDF8fHx8MTc2NjIwMDg1MHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    ),
    Place(
      id: 2,
      name: 'Pantai Kuta',
      location: 'Bali',
      category: 'Pantai',
      rating: 4.7,
      price: 'Gratis',
      image: 'https://images.unsplash.com/photo-1751814585162-bf482977e3d0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxiZWFjaCUyMHBhcmFkaXNlfGVufDF8fHx8MTc2NjE1NjU2Mnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    ),
    Place(
      id: 3,
      name: 'Gunung Bromo',
      location: 'Probolinggo, Jawa Timur',
      category: 'Gunung',
      rating: 4.8,
      price: 'Rp 35.000',
      image: 'https://images.unsplash.com/photo-1604223190546-a43e4c7f29d7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb3VudGFpbiUyMGxhbmRzY2FwZXxlbnwxfHx8fDE3NjYxOTQ2MTh8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    ),
    Place(
      id: 4,
      name: 'Air Terjun Tumpak Sewu',
      location: 'Lumajang, Jawa Timur',
      category: 'Air Terjun',
      rating: 4.9,
      price: 'Rp 10.000',
      image: 'https://images.unsplash.com/photo-1610044847457-f6aabcbb67d3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3YXRlcmZhbGwlMjBuYXR1cmV8ZW58MXx8fHwxNzY2MTE1ODMyfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    ),
    Place(
      id: 5,
      name: 'Kawah Ijen',
      location: 'Banyuwangi, Jawa Timur',
      category: 'Gunung',
      rating: 4.8,
      price: 'Rp 100.000',
      image: 'https://images.unsplash.com/photo-1743874772833-b824a8bc282c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpbmRvbmVzaWFuJTIwdG91cmlzdCUyMGF0dHJhY3Rpb258ZW58MXx8fHwxNzY2MjAwODQ5fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    ),
    Place(
      id: 6,
      name: 'Tanah Lot',
      location: 'Tabanan, Bali',
      category: 'Candi',
      rating: 4.6,
      price: 'Rp 60.000',
      image: 'https://images.unsplash.com/photo-1675506364186-4952f2110966?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0ZW1wbGUlMjB0b3VyaXNtfGVufDF8fHx8MTc2NjIwMDg1MHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    ),
  ];

  void toggleFavorite(int placeId) {
    setState(() {
      if (favorites.contains(placeId)) {
        favorites.remove(placeId);
      } else {
        favorites.add(placeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = places.where((place) {
      final matchesSearch = place.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          place.location.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'Semua' || place.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFF800080)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (widget.user.role != 'pengunjung')
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => widget.onNavigate('dashboard'),
                        ),
                      Expanded(
                        child: Text(
                          'Jelajahi Wisata',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      hintText: 'Cari tempat wisata...',
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Categories
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final selected = category == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) => setState(() => selectedCategory = category),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Places Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  itemCount: filteredPlaces.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 3 / 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];
                    final isFavorite = favorites.contains(place.id);
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                  child: Image.network(
                                    place.image,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: InkWell(
                                    onTap: () => toggleFavorite(place.id),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white70,
                                      child: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.purple,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      place.category,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(place.location, style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 16, color: Colors.yellow),
                                        const SizedBox(width: 4),
                                        Text(place.rating.toString()),
                                      ],
                                    ),
                                    Text(place.price, style: const TextStyle(color: Colors.purple)),
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
            ),
          ],
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (widget.user.role != 'pengunjung')
                IconButton(
                  icon: const Icon(Icons.dashboard),
                  onPressed: () => widget.onNavigate('dashboard'),
                ),
              IconButton(
                icon: const Icon(Icons.place),
                onPressed: () => widget.onNavigate('places'),
              ),
              if (widget.user.role == 'pengelola')
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => widget.onNavigate('addPlace'),
                ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => widget.onNavigate('profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
