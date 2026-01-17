import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailWisataScreen extends StatefulWidget {
  // DISINKRONKAN: Menggunakan nama parameter 'place' agar cocok dengan Navigator di Dashboard
  final Map<String, dynamic> place;

  const DetailWisataScreen({super.key, required this.place});

  @override
  State<DetailWisataScreen> createState() => _DetailWisataScreenState();
}

class _DetailWisataScreenState extends State<DetailWisataScreen> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // DISINKRONKAN: Mengambil galeri foto dari field 'imagePaths' (List) atau 'imagePath' (String tunggal)
    final List<String> gallery = widget.place['imagePaths'] != null
        ? List<String>.from(widget.place['imagePaths'])
        : [widget.place['imagePath'] ?? ''];

    return Scaffold(
      backgroundColor: const Color(0xFF6A1B9A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Detail Destinasi",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // --- 1. SLIDER GAMBAR ---
            Stack(
              alignment: Alignment.center,
              children: [
                CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 250,
                    viewportFraction: 0.85,
                    enlargeCenterPage: true,
                    onPageChanged: (index, _) => setState(() => _currentIndex = index),
                  ),
                  items: gallery.map((url) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        // Menangani jika URL gambar error
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
                Positioned(left: 10, child: _buildArrowBtn(Icons.arrow_back_ios_new, () => _carouselController.previousPage())),
                Positioned(right: 10, child: _buildArrowBtn(Icons.arrow_forward_ios, () => _carouselController.nextPage())),
              ],
            ),

            const SizedBox(height: 25),

            // --- 2. KARTU INFORMASI UTAMA ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.place['name'] ?? 'Tanpa Nama',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.red, size: 18),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(widget.place['location'] ?? 'Lokasi tidak tersedia',
                                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Badge Kategori
                      _badge(widget.place['category'] ?? 'Umum'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRatingRow(),
                      // DISINKRONKAN: Menampilkan harga sesuai data 'price'
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B9A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFF6A1B9A).withOpacity(0.2)),
                        ),
                        child: Text("Rp ${widget.place['price'] ?? '0'}",
                            style: const TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- 3. KARTU DETAIL (DESKRIPSI & FASILITAS) ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(widget.place['description'] ?? 'Tidak ada deskripsi untuk tempat ini.',
                      style: const TextStyle(color: Colors.black87, height: 1.6, fontSize: 14)),

                  const SizedBox(height: 30),
                  const Text("Fasilitas Populer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  // DISINKRONKAN: Memanggil widget fasilitas
                  _buildFacilityWrap(widget.place['facilities']),

                  const SizedBox(height: 30),
                  const Text("Lokasi Google Maps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  // Tombol GMaps
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = widget.place['gmapsUrl'] ?? '';
                        if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Link Google Maps tidak valid")),
                          );
                        }
                      },
                      icon: const Icon(Icons.near_me, color: Colors.white),
                      label: const Text("PANDU KE LOKASI",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildArrowBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF6A1B9A), size: 20),
      ),
    );
  }

  Widget _buildRatingRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.amber, size: 18))),
        const SizedBox(height: 5),
        const Text("4.8 (250 Reviewer)", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildFacilityWrap(dynamic facilities) {
    if (facilities == null || (facilities is List && facilities.isEmpty)) {
      return const Text("Fasilitas tidak tersedia", style: TextStyle(color: Colors.grey, fontSize: 13));
    }

    List listFasilitas = facilities is List ? facilities : [facilities];

    return Wrap(
      spacing: 10, runSpacing: 10,
      children: listFasilitas.map((f) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: Text(f.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      )).toList(),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6A1B9A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: const TextStyle(color: Color(0xFF6A1B9A), fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}