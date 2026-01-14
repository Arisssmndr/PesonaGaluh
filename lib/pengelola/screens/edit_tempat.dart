import 'package:flutter/material.dart';

class EditTempatScreen extends StatefulWidget {
  final Map<String, String> place;

  const EditTempatScreen({super.key, required this.place});

  @override
  State<EditTempatScreen> createState() => _EditTempatScreenState();
}

class _EditTempatScreenState extends State<EditTempatScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Mengisi data awal sesuai data yang dipilih
    _nameController = TextEditingController(text: widget.place['name']);
    _locationController = TextEditingController(text: widget.place['location']);
    _priceController = TextEditingController(text: widget.place['price']);
    _descController = TextEditingController(text: widget.place['description']);
    _selectedCategory = widget.place['category'] ?? 'Danau';
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
              onPressed: () {
                // Mengirim data baru kembali ke Dashboard
                Navigator.pop(context, {
                  'id': widget.place['id']!,
                  'name': _nameController.text,
                  'location': _locationController.text,
                  'category': _selectedCategory,
                  'price': _priceController.text,
                  'description': _descController.text,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontSize: 16)),
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