import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_tempat.dart';
import 'tambah_tempat.dart';

class DashboardPengelola extends StatefulWidget {
  const DashboardPengelola({super.key});

  @override
  State<DashboardPengelola> createState() => _DashboardPengelolaState();
}

class _DashboardPengelolaState extends State<DashboardPengelola> {
  // Variabel untuk Search dan Filter
  String _searchQuery = "";
  String _selectedCategory = "Semua";
  final TextEditingController _searchController = TextEditingController();

  // Daftar Kategori Sesuai Permintaan
  final List<String> _categories = [
    "Semua",
    "Danau",
    "Air Terjun",
    "Hutan",
    "Pegunungan",
    "Sungai"
  ];

  // --- FUNGSI: LOGOUT ---
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
            onPressed: () => Navigator.pop(context), // Redirect ke LoginScreen di sini
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A), foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI: HAPUS ---
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
                  _searchAndFilterSection(), // Nav Pencarian & Filter
                  _addToggleButton(),
                  _placesListStream(), // Hasil Pencarian & List
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
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Kelola Wisata Ciamis', style: TextStyle(color: Colors.white70)),
            ],
          ),
          IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _statsSection() {
    return Transform.translate(
      offset: const Offset(0, -25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
                _statCard('Destinasi', snapshot.hasData ? snapshot.data!.docs.length.toString() : '...', Icons.map, Colors.purple),
                const SizedBox(width: 16),
                _statCard('Total Views', totalViews.toString(), Icons.visibility, Colors.blue),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- BAGIAN PENCARIAN & FILTER KATEGORI ---
  Widget _searchAndFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Cari nama destinasi...",
              prefixIcon: const Icon(Icons.search, color: Colors.purple),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
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
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    showCheckmark: false,
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
      padding: const EdgeInsets.all(24),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TambahTempatScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Destinasi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A1B9A), foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  // --- STREAM LIST DENGAN LOGIKA SEARCH & FILTER ---
  Widget _placesListStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('places').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        // Logika Filter
        var docs = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String name = (data['name'] ?? "").toString().toLowerCase();
          String category = data['category'] ?? "";

          bool matchesSearch = name.contains(_searchQuery);
          bool matchesCategory = _selectedCategory == "Semua" || category == _selectedCategory;

          return matchesSearch && matchesCategory;
        }).toList();

        if (docs.isEmpty) return const Padding(padding: EdgeInsets.all(40), child: Text("Data tidak ditemukan"));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var doc = docs[index];
            Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
            return _placeCard(doc.id, item);
          },
        );
      },
    );
  }

  Widget _placeCard(String docId, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: item['imagePath'] != null
                ? Image.network(item['imagePath'], height: 160, width: double.infinity, fit: BoxFit.cover)
                : Container(height: 160, color: Colors.grey[200], child: const Icon(Icons.image)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _badge(item['category'] ?? 'Umum'),
                const SizedBox(height: 10),
                Text(item['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.purple),
                    const SizedBox(width: 4),
                    Expanded(child: Text(item['location'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                  ],
                ),
                const Divider(height: 30),
                Row(
                  children: [
                    if (item['gmapsUrl'] != null && item['gmapsUrl'] != "")
                      _smallButton("Maps", Icons.near_me, Colors.green, () => launchUrl(Uri.parse(item['gmapsUrl']))),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditTempatScreen(place: item, docId: docId))),
                      icon: const Icon(Icons.edit, color: Colors.blue),
                    ),
                    IconButton(
                      onPressed: () => _handleDelete(docId, item['name']),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                )
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: Color(0xFF6A1B9A), fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}