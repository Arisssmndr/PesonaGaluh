import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_wisata_screen.dart';

class SearchResultScreen extends StatefulWidget {
  final String? query;
  final String? category;
  final String? location;
  final int? minPrice;
  final int? maxPrice;

const SearchResultScreen({
    super.key, 
    this.query, 
    this.category, 
    this.location, 
    this.minPrice, 
    this.maxPrice,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late TextEditingController _searchController;
  late String _currentQuery;
  bool _showSuggestions = false;

  @override
void initState() {
    super.initState();
    // Mengambil query dari widget, jika kosong beri teks kosong
    _currentQuery = widget.query ?? "";
    _searchController = TextEditingController(text: _currentQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB), // Background bersih ala iOS
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 14),
            onChanged: (value) {
              setState(() {
                _currentQuery = value;
                _showSuggestions = value.isNotEmpty;
              });
            },
            onSubmitted: (value) {
              setState(() {
                _currentQuery = value;
                _showSuggestions = false; // PAKSA HILANG PAS ENTER
              });
            },
            decoration: const InputDecoration(
              hintText: "Cari destinasi seru...",
              prefixIcon: Icon(Icons.search, color: Color(0xFF6A1B9A), size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // LAYER 1: HASIL WISATA (Muncul kalau _showSuggestions FALSE)
          Column(
            children: [
              _buildModernFilterBar(),
              Expanded(
                child: _buildMainResultList(),
              ),
            ],
          ),

          // LAYER 2: OVERLAY SARAN (Hanya muncul pas ngetik)
          if (_showSuggestions && _currentQuery.isNotEmpty)
            Container(
              color: Colors.white, // Menutup hasil di bawah biar fokus ngetik
              child: _buildSuggestionList(),
            ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildModernFilterBar() {
    List<String> tags = ["Semua", "Populer", "Terdekat", "Sungai"];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          bool isSelected = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(tags[index]),
              selected: isSelected,
              selectedColor: const Color(0xFF6A1B9A),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
              onSelected: (v) {},
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainResultList() {
  return StreamBuilder<QuerySnapshot>(
    // Kita ambil semua data dari koleksi 'places'
    stream: FirebaseFirestore.instance.collection('places').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

      // Di sinilah kita melakukan penyaringan (Filtering) secara fleksibel
      var results = snapshot.data!.docs.where((doc) {
        var data = doc.data() as Map<String, dynamic>;

        // 1. Logika Filter Nama (Query pencarian)
        String name = (data['name'] ?? '').toString().toLowerCase();
        bool matchName = _currentQuery.isEmpty || name.contains(_currentQuery.toLowerCase());

        // 2. Logika Filter Lokasi (Fleksibel - Mengandung Kata)
        // Kita cek di field 'location' atau 'address'
        String locationData = (data['location'] ?? '').toString().toLowerCase();
        String addressData = (data['address'] ?? '').toString().toLowerCase();
        bool matchLocation = widget.location == null || 
                             widget.location!.isEmpty || 
                             locationData.contains(widget.location!.toLowerCase()) ||
                             addressData.contains(widget.location!.toLowerCase());

        // 3. Logika Filter Kategori
        String categoryData = (data['category'] ?? '').toString();
        bool matchCategory = widget.category == null || 
                             widget.category!.isEmpty || 
                             categoryData == widget.category;

        // 4. Logika Filter Harga
        int price = data['price'] ?? 0;
        bool matchMin = widget.minPrice == null || price >= widget.minPrice!;
        bool matchMax = widget.maxPrice == null || price <= widget.maxPrice!;

        // Data akan ditampilkan HANYA jika semua syarat di atas terpenuhi (TRUE)
        return matchName && matchLocation && matchCategory && matchMin && matchMax;
      }).toList();

      if (results.isEmpty) return _buildEmptyState();

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          var data = results[index].data() as Map<String, dynamic>;
          return _buildPremiumCard(context, data);
        },
      );
    },
  );
}

  Widget _buildPremiumCard(BuildContext context, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailWisataScreen(wisata: data))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                data['imagePath'] ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(height: 200, color: Colors.grey[300], child: const Icon(Icons.image)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Rp ${data['price']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF6A1B9A))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text(data['location'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
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

  Widget _buildSuggestionList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('places').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        var suggestions = snapshot.data!.docs.where((doc) {
          String name = (doc['name'] ?? '').toString().toLowerCase();
          return name.contains(_currentQuery.toLowerCase());
        }).take(6).toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            var data = suggestions[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(data['name'] ?? ''),
              onTap: () {
                setState(() {
                  _currentQuery = data['name'];
                  _searchController.text = _currentQuery;
                  _showSuggestions = false; // TUTUP SARAN
                });
                FocusScope.of(context).unfocus();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 100, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("Yah, '$_currentQuery' gak ada...", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}