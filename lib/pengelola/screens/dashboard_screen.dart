import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'edit_tempat.dart';
import 'tambah_tempat.dart';

class DashboardPengelola extends StatefulWidget {
  const DashboardPengelola({super.key});

  @override
  State<DashboardPengelola> createState() => _DashboardPengelolaState();
}

class _DashboardPengelolaState extends State<DashboardPengelola> {
  
  // Fungsi untuk menghapus data langsung dari Firebase
  Future<void> _handleDelete(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('places').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destinasi berhasil dihapus')),
        );
      }
    } catch (e) {
      debugPrint("Gagal menghapus: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            _statsSection(),
            _addToggleButton(),
            _placesListStream(), // Menggunakan StreamBuilder
            _footerInfo(),
          ],
        ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Admin Dashboard',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              Text('Kelola Wisata Ciamis (Real-time)',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
          IconButton(
            onPressed: () {}, // Logika logout bisa ditambahkan di sini
            icon: const Icon(Icons.logout, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
          )
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
            String total = snapshot.hasData ? snapshot.data!.docs.length.toString() : '...';
            return Row(
              children: [
                _statCard('Total Destinasi', total, Icons.map_sharp, Colors.purple),
                const SizedBox(width: 16),
                _statCard('Database', 'Active', Icons.cloud_done, Colors.green),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _addToggleButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahTempatScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Destinasi Wisata'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  // Widget Inti: Menampilkan data real-time dari Firestore
  Widget _placesListStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('places')
          .orderBy('createdAt', descending: true) // Mengurutkan dari yang terbaru
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan data.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(30.0),
            child: CircularProgressIndicator(),
          ));
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Text('Belum ada data destinasi.'),
          ));
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daftar Destinasi Wisata',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
                  String docId = doc.id; // Mengambil ID Dokumen Firebase

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFF6A1B9A),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(item['category'] ?? 'Umum',
                              style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        const SizedBox(height: 12),
                        Text(item['name'] ?? '',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(item['location'] ?? '',
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(item['description'] ?? '',
                            style: const TextStyle(color: Colors.black54, fontSize: 14)),
                        const SizedBox(height: 12),
                        Text(item['price'] ?? '',
                            style: const TextStyle(
                                color: Color(0xFF6A1B9A),
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const Divider(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditTempatScreen(
                                        place: item,
                                        docId: docId, // Kirim docId ke halaman edit
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6A1B9A),
                                  side: const BorderSide(color: Color(0xFFF3E5F5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _handleDelete(docId),
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text('Hapus'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Color(0xFFFFEBEE)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _footerInfo() {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('ℹ️ Panduan Admin', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('• Data tersinkronisasi otomatis dengan Firestore',
              style: TextStyle(fontSize: 13, color: Colors.black54)),
          Text('• Gunakan ID unik untuk edit dan hapus',
              style: TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}