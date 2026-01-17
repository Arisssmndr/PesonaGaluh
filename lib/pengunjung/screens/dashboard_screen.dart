import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'favorit_screen.dart';
import 'profil_screen.dart';
import 'detail_wisata_screen.dart';
import 'daftar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'search_result_screen.dart';

class DashboardPengunjung extends StatefulWidget {
  const DashboardPengunjung({super.key});

  @override
  State<DashboardPengunjung> createState() => _DashboardPengunjungState();
}

class _DashboardPengunjungState extends State<DashboardPengunjung> {
  int _selectedIndex = 0;
  String _lokasiUser = "Mencari lokasi...";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tentukanPosisi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _tentukanPosisi() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _lokasiUser = "GPS Mati");
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _lokasiUser = "Izin Ditolak");
        return;
      }
    }
    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark tempat = placemarks[0];
        setState(() {
          _lokasiUser = "${tempat.locality ?? "Kecamatan"}, ${tempat.subAdministrativeArea ?? "Kota"}";
        });
      }
    } catch (e) {
      setState(() => _lokasiUser = "Gagal mengambil lokasi");
    }
  }

  List<Widget> _getHalaman() {
    return [
      _buildBerandaSatuScroll(),
      const FavoritScreen(),
      const ProfilScreen(),
      daftartempat(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A1B9A),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _getHalaman()),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- REVISI: BOX PUTIH MUNCUL & SCROLL MENYATU ---
  // --- REVISI: TETAP PAS TAPI BISA DI-SCROLL KE ATAS ---
Widget _buildBerandaSatuScroll() {
    return Stack(
      children: [
        // 1. Bagian Ungu (Header, Search, Kategori)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopHeader(),
            _buildSearchBar(),
            const Padding(
              padding: EdgeInsets.only(left: 25, top: 10, bottom: 5),
              child: Text("Pilih Kategori", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            _buildCategories(),
            const SizedBox(height: 20),
          ],
        ),

        // 2. Kotak Putih Besar (Sheet)
        DraggableScrollableSheet(
          initialChildSize: 0.48, 
          minChildSize: 0.48, 
          maxChildSize: 0.95, 
          snap: true,
          // Tambahkan snapSizes agar kotak langsung 'nempel' ke atas saat ditarik
          snapSizes: const [0.48, 0.95], 
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35), 
                  topRight: Radius.circular(35)
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, -5))
                ],
              ),
              // Agar SATU KOTAK terangkat, kita gunakan SingleChildScrollView
              // yang dihubungkan dengan scrollController bawaan sheet
              child: SingleChildScrollView(
                controller: scrollController,
                // ClampingScrollPhysics wajib agar sheet tidak membal dan lebih mudah ditarik
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Handle bar (garis abu-abu)
                    Center(
                      child: Container(
                        width: 45, 
                        height: 5, 
                        decoration: BoxDecoration(
                          color: Colors.grey[300], 
                          borderRadius: BorderRadius.circular(10)
                        )
                      ),
                    ),
                    _buildSectionHeader("Destinasi Populer"),
                    
                    // Isi konten wisata
                    _buildWisataGrid(),
                    
                    // Beri jarak bawah sangat besar agar bisa di-scroll sampai akhir
                    const SizedBox(height: 200), 
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: Row(
        children: [
          const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=aris')),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hi, Selamat Datang!", style: TextStyle(color: Colors.white70, fontSize: 12)),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.amber, size: 16),
                    Text(" $_lokasiUser", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          _buildNotificationIcon(),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
      child: const Icon(Icons.notifications_none, color: Colors.white, size: 24),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 55,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
              child: TextField(
                controller: _searchController,
                onSubmitted: (v) {
                  if (v.isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (c) => SearchResultScreen(query: v)));
                },
                decoration: const InputDecoration(hintText: "Cari Wisata Idaman...", prefixIcon: Icon(Icons.search, color: Color(0xFF6A1B9A)), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 18)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.tune, color: Colors.white)),
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

  return SizedBox(
    height: 110,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      itemCount: categories.length,
      itemBuilder: (context, index) => GestureDetector( // 1. Tambahkan GestureDetector
        onTap: () {
          // 2. Arahkan ke daftartempat sambil bawa nama kategori
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => daftartempat(
                kategoriAwal: categories[index]['name'],
              ),
            ),
          );
        },
        child: Container(
          width: 85,
          margin: const EdgeInsets.only(right: 15, bottom: 10, top: 5),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(22), 
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              Text(categories[index]['icon'], style: const TextStyle(fontSize: 30)), 
              const SizedBox(height: 6), 
              Text(
                categories[index]['name'], 
                style: const TextStyle(fontSize: 11, color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold)
              )
            ]
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => daftartempat())),
            child: const Text("Lihat Semua", style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildWisataGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('places').orderBy('views', descending: true).limit(4).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Scroll mengikuti CustomScrollView utama
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 18, mainAxisSpacing: 20, childAspectRatio: 0.78),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return _buildWisataCard(context, data, docs[index].id);
          },
        );
      },
    );
  }

  Widget _buildWisataCard(BuildContext context, Map<String, dynamic> data, String docId) {
    return GestureDetector(
      onTap: () {
        FirebaseFirestore.instance.collection('places').doc(docId).update({'views': FieldValue.increment(1)});
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailWisataScreen(wisata: data)));
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), child: Image.network(data['imagePath'] ?? '', fit: BoxFit.cover, width: double.infinity))),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                  const SizedBox(height: 4),
                  Row(children: [const Icon(Icons.location_on, color: Colors.red, size: 12), const SizedBox(width: 4), Expanded(child: Text(data['location'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 10), maxLines: 1))]),
                  const SizedBox(height: 6),
                  Text("Rp ${data['price']}", style: const TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold, fontSize: 12)),
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
      height: 75,
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_filled, "Beranda", 0),
          _navItem(Icons.favorite_rounded, "Favorit", 1),
          _navItem(Icons.person_rounded, "Profil", 2),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[400], size: 28),
        Text(label, style: TextStyle(color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[400], fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}