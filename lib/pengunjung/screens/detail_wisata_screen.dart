import 'package:flutter/material.dart';

class DetailWisataScreen extends StatefulWidget {
  const DetailWisataScreen({super.key});

  @override
  State<DetailWisataScreen> createState() => _DetailWisataScreenState();
}

class _DetailWisataScreenState extends State<DetailWisataScreen> {
  int jumlahTiket = 1;
  bool isFavorite = false;
  int hargaPerTiket = 15000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Gambar Utama
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderImage(context),
                _buildMainContent(),
                const SizedBox(height: 100), // Spasi agar tidak tertutup tombol beli
              ],
            ),
          ),

          // 2. Tombol Beli Tiket (Sticky di Bawah)
          _buildBottomBuyPanel(),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1604223190546-a43e4c7f29d7'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Tombol Back
        Positioned(
          top: 40,
          left: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: const Icon(Icons.chevron_left, color: Colors.black),
            ),
          ),
        ),
        // Tombol Favorite
        Positioned(
          top: 40,
          right: 20,
          child: GestureDetector(
            onTap: () => setState(() => isFavorite = !isFavorite),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Bukit Baros", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: const [
                    Icon(Icons.star, color: Colors.orange, size: 18),
                    Text(" 4.8", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.location_on, color: Color(0xFF6A1B9A), size: 18),
              Text(" Cianjur, Jawa Barat", style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),

          // Row Jam Operasional
          _buildInfoRow(Icons.access_time, "Jam Operasional", "08:00 - 17:00 WIB"),
          const SizedBox(height: 20),

          const Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            "Nikmati keindahan pemandangan dari ketinggian Bukit Baros. Tempat ini sangat cocok untuk camping, berfoto ria, dan menikmati udara segar pegunungan bersama keluarga.",
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 25),

          const Text("Fasilitas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              _buildChip("Area Parkir"),
              _buildChip("Mushola"),
              _buildChip("Toilet"),
              _buildChip("Warung Makan"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6A1B9A)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Color(0xFF6A1B9A), fontSize: 12)),
      backgroundColor: const Color(0xFFF3E5F5),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildBottomBuyPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Row(
          children: [
            // Counter Tiket
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(onPressed: () => setState(() { if(jumlahTiket > 1) jumlahTiket--; }), icon: const Icon(Icons.remove)),
                  Text("$jumlahTiket", style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => setState(() => jumlahTiket++), icon: const Icon(Icons.add)),
                ],
              ),
            ),
            const SizedBox(width: 15),
            // Tombol Beli
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Berhasil membeli $jumlahTiket tiket!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("Beli Tiket - Rp ${hargaPerTiket * jumlahTiket}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}