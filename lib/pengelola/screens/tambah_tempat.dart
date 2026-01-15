import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahTempatScreen extends StatefulWidget {
  const TambahTempatScreen({super.key});

  @override
  State<TambahTempatScreen> createState() => _TambahTempatScreenState();
}

class _TambahTempatScreenState extends State<TambahTempatScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController(); // Lokasi singkat (Kota/Kec)
  final _addressController = TextEditingController(); // Alamat Lengkap
  final _gmapsUrlController = TextEditingController(); // Link Google Maps (BARU)
  final _priceController = TextEditingController();
  final _opHoursController = TextEditingController(); // Jam Operasional
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'Danau';
  bool _isLoading = false;

  // === DATA FASILITAS (CHECKBOX) ===
  final Map<String, bool> _facilities = {
    'Area Parkir': false,
    'Toilet': false,
    'Warung': false,
    'Mushola': false,
  };

  Future<void> _handleSave() async {
    // Validasi input: Sekarang menyertakan pengecekan link Maps
    if (_nameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama, Lokasi, Alamat, dan URL Gambar wajib diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Ambil daftar fasilitas yang dicentang saja
    List<String> selectedFacilities = _facilities.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    try {
      await FirebaseFirestore.instance.collection('places').add({
        'name': _nameController.text,
        'location': _locationController.text,
        'address': _addressController.text,
        'gmapsUrl': _gmapsUrlController.text, // Simpan Link Google Maps (BARU)
        'category': _selectedCategory,
        'price': _priceController.text,
        'operationalHours': _opHoursController.text,
        'facilities': selectedFacilities,
        'description': _descController.text,
        'imagePath': _imageUrlController.text,
        'views': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destinasi berhasil ditambahkan!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textField(_nameController, 'Nama Tempat', Icons.place),
            _textField(_locationController, 'Lokasi Singkat (Kecamatan/Kota)', Icons.map),
            _textField(_addressController, 'Alamat Lengkap', Icons.location_on, maxLines: 2),

            // Kolom Input Google Maps (BARU)
            _textField(
                _gmapsUrlController,
                'Link Google Maps',
                Icons.location_searching,
                hint: 'Tempel link share dari Google Maps di sini'
            ),

            _textField(_opHoursController, 'Jam Operasional (Contoh: 08:00 - 17:00)', Icons.access_time),
            _textField(_priceController, 'Harga Tiket (Contoh: Rp 10.000)', Icons.confirmation_number),
            _categoryDropdown(),

            const Text("Fasilitas Tersedia:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildFacilitiesCheckbox(),
            const SizedBox(height: 16),

            _textField(_imageUrlController, 'URL Gambar', Icons.link, hint: 'https://...'),

            const Text("Preview Gambar:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildImagePreview(),
            const SizedBox(height: 16),

            _textField(_descController, 'Deskripsi', Icons.description, maxLines: 4),
            const SizedBox(height: 24),

            _saveButton(),
          ],
        ),
      ),
    );
  }

  // --- Widget helper tetap sama seperti sebelumnya ---
  Widget _buildFacilitiesCheckbox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _facilities.keys.map((String key) {
          return CheckboxListTile(
            title: Text(key, style: const TextStyle(fontSize: 14)),
            value: _facilities[key],
            activeColor: const Color(0xFF6A1B9A),
            dense: true,
            onChanged: (bool? value) {
              setState(() {
                _facilities[key] = value!;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagePreview() {
    return ValueListenableBuilder(
      valueListenable: _imageUrlController,
      builder: (context, value, child) {
        return Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.shade100, width: 2),
          ),
          child: value.text.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              value.text,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _emptyPreview(Icons.broken_image, "URL tidak valid"),
            ),
          )
              : _emptyPreview(Icons.image_search, "Masukkan URL untuk preview"),
        );
      },
    );
  }

  Widget _emptyPreview(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: Colors.purple.shade200),
        Text(label, style: TextStyle(color: Colors.purple.shade300, fontSize: 12)),
      ],
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _isLoading
          ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
      )
          : const Text('Simpan Destinasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'Kategori',
          prefixIcon: const Icon(Icons.category, color: Color(0xFF6A1B9A)),
          filled: true,
          fillColor: Colors.purple.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        items: ['Danau', 'Air Terjun', 'Hutan', 'Pegunungan','Sungai']
            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
            .toList(),
        onChanged: (val) => setState(() => _selectedCategory = val!),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF6A1B9A)),
          filled: true,
          fillColor: Colors.purple.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}