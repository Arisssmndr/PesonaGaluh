import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTempatScreen extends StatefulWidget {
  final Map<String, dynamic> place;
  final String docId;

  const EditTempatScreen({super.key, required this.place, required this.docId});

  @override
  State<EditTempatScreen> createState() => _EditTempatScreenState();
}

class _EditTempatScreenState extends State<EditTempatScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _addressController;
  late TextEditingController _gmapsUrlController; // BARU
  late TextEditingController _priceController;
  late TextEditingController _opHoursController;
  late TextEditingController _descController;
  late TextEditingController _imageUrlController;

  late String _selectedCategory;
  bool _isLoading = false;

  final Map<String, bool> _facilities = {
    'Area Parkir': false,
    'Toilet': false,
    'Warung': false,
    'Mushola': false,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.place['name']);
    _locationController = TextEditingController(text: widget.place['location']);
    _addressController = TextEditingController(text: widget.place['address'] ?? '');
    _gmapsUrlController = TextEditingController(text: widget.place['gmapsUrl'] ?? ''); // BARU
    _priceController = TextEditingController(text: widget.place['price']);
    _opHoursController = TextEditingController(text: widget.place['operationalHours'] ?? '');
    _descController = TextEditingController(text: widget.place['description']);
    _imageUrlController = TextEditingController(text: widget.place['imagePath'] ?? '');
    _selectedCategory = widget.place['category'] ?? 'Danau';

    if (widget.place['facilities'] != null) {
      List<dynamic> savedFacilities = widget.place['facilities'];
      for (var f in savedFacilities) {
        if (_facilities.containsKey(f)) {
          _facilities[f] = true;
        }
      }
    }
  }

  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);

    List<String> selectedFacilities = _facilities.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    try {
      await FirebaseFirestore.instance
          .collection('places')
          .doc(widget.docId)
          .update({
        'name': _nameController.text,
        'location': _locationController.text,
        'address': _addressController.text,
        'gmapsUrl': _gmapsUrlController.text, // UPDATE KE FIRESTORE
        'category': _selectedCategory,
        'price': _priceController.text,
        'operationalHours': _opHoursController.text,
        'facilities': selectedFacilities,
        'description': _descController.text,
        'imagePath': _imageUrlController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan!')),
        );
        Navigator.pop(context);
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_nameController, 'Nama Tempat', Icons.place),
            _buildTextField(_locationController, 'Lokasi Singkat', Icons.map),
            _buildTextField(_addressController, 'Alamat Lengkap', Icons.location_on, maxLines: 2),

            // INPUT GMAPS BARU
            _buildTextField(
                _gmapsUrlController,
                'Link Google Maps',
                Icons.location_searching,
                hint: 'Tempel link share Google Maps'
            ),

            _buildTextField(_opHoursController, 'Jam Operasional', Icons.access_time),
            _buildTextField(_priceController, 'Harga Tiket', Icons.confirmation_number),

            _buildCategoryDropdown(),

            const Text("Fasilitas Tersedia:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildFacilitiesCheckbox(),

            const SizedBox(height: 16),
            _buildTextField(_imageUrlController, 'URL Gambar Baru', Icons.link),

            const Text("Preview Gambar:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildImagePreview(),

            const SizedBox(height: 16),
            _buildTextField(_descController, 'Deskripsi', Icons.description, maxLines: 4),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
              )
                  : const Text('Simpan Perubahan',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget helper tetap sama ---
  Widget _buildFacilitiesCheckbox() {
    return Container(
      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: _facilities.keys.map((String key) {
          return CheckboxListTile(
            title: Text(key, style: const TextStyle(fontSize: 14)),
            value: _facilities[key],
            activeColor: const Color(0xFF6A1B9A),
            onChanged: (bool? value) => setState(() => _facilities[key] = value!),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagePreview() {
    return ValueListenableBuilder(
      valueListenable: _imageUrlController,
      builder: (context, value, child) {
        String path = _imageUrlController.text;
        return Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withOpacity(0.1)),
          ),
          child: path.startsWith('http')
              ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(path, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Center(child: Text("URL Gambar Tidak Valid"))),
          )
              : const Center(child: Text("Link tidak valid / Gunakan URL")),
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'Kategori',
          filled: true,
          fillColor: Colors.purple.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        items: ['Danau', 'Air Terjun', 'Hutan', 'Pegunungan', 'Sungai']
            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
            .toList(),
        onChanged: (val) => setState(() => _selectedCategory = val!),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF6A1B9A), size: 20),
          filled: true,
          fillColor: Colors.purple.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}