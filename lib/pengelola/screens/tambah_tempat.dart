import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Tambahkan import Firestore

class TambahTempatScreen extends StatefulWidget {
  const TambahTempatScreen({super.key});

  @override
  State<TambahTempatScreen> createState() => _TambahTempatScreenState();
}

class _TambahTempatScreenState extends State<TambahTempatScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Danau'; // Nilai default kategori
  
  // State untuk indikator loading
  bool _isLoading = false;

  // 2. Fungsi simpan ke Firebase (Async)
  Future<void> _handleSave() async {
    // Validasi input minimal
    if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Lokasi wajib diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true); // Mulai loading

    try {
      // Mengirim data ke koleksi 'places' di Firestore
      await FirebaseFirestore.instance.collection('places').add({
        'name': _nameController.text,
        'location': _locationController.text,
        'category': _selectedCategory,
        'price': _priceController.text,
        'description': _descController.text,
        'createdAt': FieldValue.serverTimestamp(), // Menambah timestamp otomatis
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destinasi berhasil ditambahkan ke Firebase!')),
        );
        Navigator.pop(context); // Tutup halaman setelah berhasil
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Stop loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Destinasi Baru'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _textField(_nameController, 'Nama Tempat'),
                _textField(_locationController, 'Lokasi'),
                _textField(_priceController, 'Harga Tiket (Contoh: Rp 10.000)'),
                _categoryDropdown(), // Tambahan dropdown agar kategori rapi
                _textField(_descController, 'Deskripsi', maxLines: 4),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave, // Disable tombol jika sedang loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text('Simpan Destinasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget tambahan untuk Dropdown Kategori
  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'Kategori',
          filled: true,
          fillColor: Colors.purple.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        items: ['Danau', 'Air Terjun', 'Hutan', 'Pegunungan', 'Kuliner']
            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
            .toList(),
        onChanged: (val) => setState(() => _selectedCategory = val!),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.purple.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}