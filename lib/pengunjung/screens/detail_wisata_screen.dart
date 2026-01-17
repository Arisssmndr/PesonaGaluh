import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailWisataScreen extends StatefulWidget {
  final Map<String, dynamic> wisata;

  const DetailWisataScreen({super.key, required this.wisata});

  @override
  State<DetailWisataScreen> createState() => _DetailWisataScreenState();
}

class _DetailWisataScreenState extends State<DetailWisataScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> gallery = widget.wisata['imagePaths'] != null
        ? List<String>.from(widget.wisata['imagePaths'])
        : [widget.wisata['imagePath'] ?? ''];

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F5F5,
      ), // Background bawah abu-abu terang
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER AREA: BACKGROUND UNGU ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 340,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8E24AA), // Ungu sesuai desain
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),

                // Content: Judul, Slider, Arrows
                Column(
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      "Detail Destinasi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CarouselSlider(
                          carouselController: _carouselController,
                          options: CarouselOptions(
                            height: 200,
                            viewportFraction: 0.9,
                            enlargeCenterPage: true,
                            onPageChanged: (index, _) =>
                                setState(() => _currentIndex = index),
                          ),
                          items: gallery
                              .map(
                                (url) => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: NetworkImage(url),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        // Navigasi Panah Persis Desain
                        _buildNavArrow(
                          left: 10,
                          icon: Icons.chevron_left,
                          onTap: () => _carouselController.previousPage(),
                        ),
                        _buildNavArrow(
                          right: 10,
                          icon: Icons.chevron_right,
                          onTap: () => _carouselController.nextPage(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildIndicator(gallery.length),
                  ],
                ),

                // Tombol Back
                Positioned(
                  top: 55,
                  left: 20,
                  child: _buildCircleBtn(
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            // --- KARTU 1: INFO UTAMA (DENGAN IKON POJOK) ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Container Kartu Utama
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.wisata['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.favorite, color: Color(0xFF8E24AA)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.wisata['location'] ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRatingSection(),
                          // Bento Price Label
                          _buildPriceTag("Rp ${widget.wisata['price']}"),
                        ],
                      ),
                    ],
                  ),
                ),
                // Ikon Kunci di Pojok Kiri Atas Kartu
                Positioned(
                  top: 10, // Disesuaikan agar pas di garis kartu
                  left: 15,
                  child: _buildBadgeIcon(Icons.lock_outline),
                ),
                // Ikon Love di Pojok Kanan Atas Kartu
                Positioned(
                  top: 10,
                  right: 15,
                  child: _buildBadgeIcon(Icons.favorite_border),
                ),
              ],
            ),

            // --- KARTU 2: DESKRIPSI & FASILITAS ---
            // --- KARTU 2: DESKRIPSI, FASILITAS, GALERI & GMAPS ---
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 0,
              ), // Vertical 0 agar lebih rapat ke atas
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Deskripsi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.wisata['description'] ?? 'Tidak ada deskripsi.',
                    style: const TextStyle(color: Colors.black87, height: 1.5),
                  ),

                  const Divider(height: 40),

                  const Text(
                    "Fasilitas Populer",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildFacilities(widget.wisata['facilities']),

                  const Divider(height: 40),

                  // --- TAMBAHAN: GALERI FOTO ---
                  const Text(
                    "Galeri Foto",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: gallery.length,
                      itemBuilder: (context, index) => Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(gallery[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- TAMBAHAN: TOMBOL GOOGLE MAPS ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final url = widget.wisata['gmapsUrl'] ?? '';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.map_outlined,
                        color: Color(0xFF6A1B9A),
                      ),
                      label: const Text(
                        "Lihat di Google Maps",
                        style: TextStyle(
                          color: Color(0xFF6A1B9A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6A1B9A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tombol Pesan Tiket Sesuai Desain
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Pesan Tiket Sekarang",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- KOMPONEN UI PENUNJANG ---

  Widget _buildNavArrow({
    double? left,
    double? right,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      right: right,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFF333333),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xFF333333),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBadgeIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Color(0xFF333333),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildPriceTag(String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1BEE7)),
      ),
      child: Text(
        price,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            5,
            (i) => const Icon(Icons.star, color: Colors.amber, size: 18),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "4.8 (1.2k Review)",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFacilities(List? facilities) {
    if (facilities == null) return const SizedBox();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: facilities
          .map(
            (f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                f.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // --- TAMBAHKAN INI DI BAGIAN BAWAH BERSAMA HELPER LAINNYA ---

  Widget _buildSmallGallery(List<String> images) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: images.length,
        itemBuilder: (context, index) => Container(
          width: 70,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            image: DecorationImage(
              image: NetworkImage(images[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

