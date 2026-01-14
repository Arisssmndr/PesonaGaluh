import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_wisata_screen.dart';

class daftartempat extends StatelessWidget {
  const daftartempat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Semua Destinasi", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder(
        // Mengambil data dari koleksi 'places' di Firebase
        stream: FirebaseFirestore.instance.collection('places').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];
              return _buildListCard(context, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildListCard(BuildContext context, DocumentSnapshot data) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailWisataScreen())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1604223190546-a43e4c7f29d7'), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Ambil field 'name'
                Text(data['location'], style: const TextStyle(color: Colors.grey, fontSize: 12)), // Ambil field 'location'
                Text("Rp ${data['price']}", style: const TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold)), // Ambil field 'price'
              ],
            ),
          ],
        ),
      ),
    );
  }
}