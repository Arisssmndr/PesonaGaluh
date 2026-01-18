import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_wisata_screen.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna utama yang selaras dengan dashboard kamu
    const Color primaryPurple = Color(0xFF6A1B9A);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F7), // Ungu sangat muda untuk background
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // --- TAMBAHAN REFRESH INDICATOR ---
      body: RefreshIndicator(
        color: primaryPurple,
        onRefresh: () async {
          // Memberikan efek loading selama 1 detik
          await Future.delayed(const Duration(seconds: 1));
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('places')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: primaryPurple));
            var docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              // Dibungkus ListView agar Empty State bisa ditarik ke bawah (Refreshable)
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  _buildEmptyState(primaryPurple),
                ],
              );
            }

            return ListView.builder(
              // Physics ini wajib agar layar bisa ditarik meski data sedikit
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var data = docs[index].data() as Map<String, dynamic>;
                
                // Proteksi jika createdAt null
                DateTime dateTime = data['createdAt'] != null 
                    ? (data['createdAt'] as Timestamp).toDate() 
                    : DateTime.now();
                
                bool isNew = DateTime.now().difference(dateTime).inHours < 24;

                return _buildNotificationItem(context, data, dateTime, isNew, primaryPurple);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> data, DateTime time, bool isNew, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isNew ? Border.all(color: primaryColor.withOpacity(0.3), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                data['imagePath'] ?? '',
                width: 65,
                height: 65,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 65, height: 65, 
                  color: Colors.grey[200], 
                  child: const Icon(Icons.image, color: Colors.grey)
                ),
              ),
            ),
            if (isNew)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber, // Warna kontras untuk label 'Baru'
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Text("Baru", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              )
          ],
        ),
        title: Text(
          data['name'] ?? 'Destinasi Wisata',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isNew ? primaryColor : Colors.black87,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              "Telah hadir destinasi baru di ${data['location'] ?? 'Ciamis'}. Cek yuk!",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: primaryColor.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM, HH:mm').format(time),
                  style: TextStyle(fontSize: 11, color: primaryColor.withOpacity(0.7)),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => DetailWisataScreen(wisata: data),
          ));
        },
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 100, color: primaryColor.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(
            "Belum Ada Kabar Baru",
            style: TextStyle(color: primaryColor.withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const Text("Notifikasi wisata terbaru akan muncul di sini", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}