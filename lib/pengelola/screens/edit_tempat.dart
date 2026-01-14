import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class EditTempatScreen extends StatefulWidget {
  final Map<String, dynamic> place; // Ubah ke dynamic
  final String docId; // Tambahkan docId untuk referensi database

  const EditTempatScreen({super.key, required this.place, required this.docId});

  @override
  State<EditTempatScreen> createState() => _EditTempatScreenState();
}

class _EditTempatScreenState extends State<EditTempatScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late String _selectedCategory;
  bool _isLoading = false; // Untuk indikator loading

  @override
  void initState() {
    super.initState();
    // Mengisi data awal dari Firebase
    _nameController = TextEditingController(text: widget.place['name']);
    _locationController = TextEditingController(text: widget.place['location']);
    _priceController = TextEditingController(text: widget.place['price']);
    _descController = TextEditingController(text: widget.place['description']);
    _selectedCategory = widget.place['category'] ?? 'Danau';
  }

  // Fungsi untuk update data ke Firebase
  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.docId) // Menuju dokumen yang spesifik berdasarkan ID
          .update({
        'name': _nameController.text,
        'location': _locationController.text,
        'category': _selectedCategory,
        'price': _priceController.text,
        'description': _descController.text,
        'updatedAt': FieldValue.serverTimestamp(), // Catat waktu perubahan
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan!')),
        );
        Navigator.pop(context); // Kembali ke Dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Destinasi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Nama Tempat'),
            _buildTextField(_locationController, 'Lokasi'),
            _buildTextField(_priceController, 'Harga Tiket'),
            _buildTextField(_descController, 'Deskripsi', maxLines: 4),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Simpan Perubahan',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.purple.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}