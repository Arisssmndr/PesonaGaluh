import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_wisata_screen.dart';

class daftartempat extends StatefulWidget {
  // 1. Tambahkan parameter ini
  final String? kategoriAwal; 

  // 2. Update Constructor
  const daftartempat({super.key, this.kategoriAwal}); 

  @override
  State<daftartempat> createState() => _daftartempatState();
}

class _daftartempatState extends State<daftartempat> {
  // 3. Ubah inisialisasi kategoriDipilih
  late String kategoriDipilih;

  @override
  void initState() {
    super.initState();
    // Jika ada kiriman dari dashboard, pakai itu. Jika tidak, "Semua".
    kategoriDipilih = widget.kategoriAwal ?? "Semua";
  }

  final List<String> categories = [
    "Semua",
    "Danau",
    "Air Terjun",
    "Puncak",
    "Hutan",
    "Sungai",
    "Pegunungan",
  ];

  @override
  Widget build(BuildContext context) {
    // Sisanya tetap sama, karena variabel kategoriDipilih sudah otomatis terisi
    Query query = FirebaseFirestore.instance.collection('places');
    if (kategoriDipilih != "Semua") {
      query = query.where('category', isEqualTo: kategoriDipilih);
    }
    // ... sisa kode build sama seperti sebelumnya

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Semua Destinasi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // --- BAGIAN KATEGORI (DI ATAS) ---
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = kategoriDipilih == categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      kategoriDipilih =
                          categories[index]; // Ganti kategori saat diklik
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6A1B9A)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- BAGIAN GRID DATA (DI BAWAH) ---
          Expanded(
            child: StreamBuilder(
              stream: query.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Data tidak tersedia"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    return _buildGridCard(context, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI UNTUK MEMBUAT CARD ---
  Widget _buildGridCard(BuildContext context, DocumentSnapshot data) {
    // Ambil data sebagai Map untuk pengecekan aman
    Map<String, dynamic> item = data.data() as Map<String, dynamic>;

    // Logika pengecekan field image agar tidak Error Merah
    String imageUrl = item.containsKey('image')
        ? item['image']
        : (item.containsKey('imagePath')
              ? item['imagePath']
              : 'https://via.placeholder.com/150');

    // Pastikan link bukan "blob:", jika blob ganti ke placeholder
    if (imageUrl.startsWith('blob')) {
      imageUrl = 'https://via.placeholder.com/150';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailWisataScreen(
              wisata: item, // 'item' adalah data dari Firestore yang diklik
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Destinasi
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Informasi Destinasi
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Tanpa Nama',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item['location'] ?? 'Lokasi tidak ada',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Rp ${item['price'] ?? '0'}",
                    style: const TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
