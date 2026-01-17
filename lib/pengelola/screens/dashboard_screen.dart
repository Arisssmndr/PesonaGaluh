import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
// Import file internal proyek Anda
import 'edit_tempat.dart';
import 'tambah_tempat.dart';
import 'detail_wisata_screen.dart';
import '../../ui/auth/login_screen.dart';

class DashboardPengelola extends StatefulWidget {
  const DashboardPengelola({super.key});

  @override
  State<DashboardPengelola> createState() => _DashboardPengelolaState();
}

class _DashboardPengelolaState extends State<DashboardPengelola> {
  String _searchQuery = "";
  String _selectedCategory = "Semua";
  final TextEditingController _searchController = TextEditingController();

  // List kategori ditambah dengan "Terpopuler"
  final List<String> _categories = [
    "Semua",
    "Terpopuler", // Filter baru berdasarkan jumlah views
    "Danau",
    "Air Terjun",
    "Hutan",
    "Pegunungan",
    "Sungai"
  ];

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar dari Dashboard Admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(String docId, String placeName) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Destinasi?'),
        content: Text('Hapus "$placeName" secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseFirestore.instance.collection('places').doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _statsSection(),
                  _searchAndFilterSection(),
                  _addToggleButton(),
                  _placesListStream(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Kelola Wisata Ciamis', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 26)),
        ],
      ),
    );
  }

  Widget _statsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('places').snapshots(),
        builder: (context, snapshot) {
          int totalViews = 0;
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              totalViews += ((doc.data() as Map<String, dynamic>)['views'] as num? ?? 0).toInt();
            }
          }
          return Row(
            children: [
              _statCard('Destinasi', snapshot.hasData ? snapshot.data!.docs.length.toString() : '0', Icons.map_rounded, Colors.purple),
              const SizedBox(width: 12),
              _statCard('Total Views', totalViews.toString(), Icons.visibility_rounded, Colors.blue),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchAndFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Cari nama destinasi...",
              prefixIcon: const Icon(Icons.search, color: Colors.purple, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedCategory == _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_categories[index]),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = _categories[index]),
                    selectedColor: const Color(0xFF6A1B9A),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _addToggleButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahTempatScreen())),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Tambah Destinasi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _placesListStream() {
    // Logika pengurutan: Jika "Terpopuler" dipilih, urutkan berdasarkan 'views' descending
    Query query = FirebaseFirestore.instance.collection('places');

    if (_selectedCategory == "Terpopuler") {
      query = query.orderBy('views', descending: true);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        }

        var docs = snapshot.data?.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String name = (data['name'] ?? "").toString().toLowerCase();
          String category = data['category'] ?? "";

          bool matchesSearch = name.contains(_searchQuery);

          // Logika filter kategori
          bool matchesCategory = false;
          if (_selectedCategory == "Semua" || _selectedCategory == "Terpopuler") {
            matchesCategory = true;
          } else {
            matchesCategory = category == _selectedCategory;
          }

          return matchesSearch && matchesCategory;
        }).toList() ?? [];

        if (docs.isEmpty) return const Padding(padding: EdgeInsets.all(40), child: Text("Data tidak ditemukan"));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var doc = docs[index];
            return _placeCard(doc.id, doc.data() as Map<String, dynamic>);
          },
        );
      },
    );
  }

  Widget _placeCard(String docId, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailWisataScreen(place: item))),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: item['imagePath'] != null
                          ? Image.network(item['imagePath'], height: 160, width: double.infinity, fit: BoxFit.cover)
                          : Container(height: 160, color: Colors.grey[200], child: const Icon(Icons.image)),
                    ),
                    // Badge Views di pojok gambar agar admin tahu jumlah kliknya
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.visibility, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              "${item['views'] ?? 0}",
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _badge(item['category'] ?? 'Umum'),
                      const SizedBox(height: 8),
                      Text(item['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Color(0xFF6A1B9A)),
                          const SizedBox(width: 4),
                          Expanded(child: Text(item['location'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Divider(height: 24),
                Row(
                  children: [
                    if (item['gmapsUrl'] != null && item['gmapsUrl'] != "")
                      _smallButton(
                        "Kunjungi",
                        Icons.near_me_rounded,
                        const Color(0xFF6A1B9A),
                            () => launchUrl(Uri.parse(item['gmapsUrl'])),
                      ),
                    const Spacer(),
                    _actionIcon(Icons.edit_rounded, Colors.blue, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditTempatScreen(place: item, docId: docId)));
                    }),
                    const SizedBox(width: 8),
                    _actionIcon(Icons.delete_rounded, Colors.red, () => _handleDelete(docId, item['name'])),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _smallButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF6A1B9A).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: Color(0xFF6A1B9A), fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}