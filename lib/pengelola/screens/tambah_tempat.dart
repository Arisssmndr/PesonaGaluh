import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahTempatScreen extends StatefulWidget {
  const TambahTempatScreen({super.key});

  @override
  State<TambahTempatScreen> createState() => _TambahTempatScreenState();
}

class _TambahTempatScreenState extends State<TambahTempatScreen> {
  // Controller untuk input data
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _gmapsUrlController = TextEditingController();
  final _priceController = TextEditingController();
  final _opHoursController = TextEditingController();
  final _descController = TextEditingController();

  // Pengaturan gambar (bisa banyak gambar)
  List<TextEditingController> _imageControllers = [TextEditingController()];
  int _mainImageIndex = 0;

  String _selectedCategory = 'Danau';
  bool _isLoading = false;

  // Fasilitas destinasi
  final Map<String, bool> _facilities = {
    'Area Parkir': false,
    'Toilet': false,
    'Warung': false,
    'Mushola': false,
  };

  Future<void> _handleSave() async {
    // Validasi dasar
    if (_nameController.text.isEmpty || _imageControllers[_mainImageIndex].text.isEmpty) {
      _showSnackBar('Nama dan Gambar Utama wajib diisi!');
      return;
    }

    setState(() => _isLoading = true);

    // Proses list gambar (Gambar utama dipaksa di urutan pertama)
    String mainImageUrl = _imageControllers[_mainImageIndex].text;
    List<String> finalImagePaths = [];
    finalImagePaths.add(mainImageUrl);

    for (int i = 0; i < _imageControllers.length; i++) {
      String url = _imageControllers[i].text;
      if (url.isNotEmpty && i != _mainImageIndex) {
        finalImagePaths.add(url);
      }
    }

    // Ambil fasilitas yang dicentang
    List<String> selectedFacilities = _facilities.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    try {
      await FirebaseFirestore.instance.collection('places').add({
        'name': _nameController.text,
        'location': _locationController.text,
        'address': _addressController.text,
        'gmapsUrl': _gmapsUrlController.text,
        'category': _selectedCategory,
        'price': _priceController.text,
        'operationalHours': _opHoursController.text,
        'facilities': selectedFacilities,
        'description': _descController.text,
        'imagePath': mainImageUrl,      // Untuk Thumbnail Dashboard
        'imagePaths': finalImagePaths, // Untuk Carousel Detail
        'views': 0,                    // Inisialisasi jumlah views
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSnackBar('Destinasi berhasil ditambahkan!');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Destinasi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Informasi Utama"),
            _buildTextField(_nameController, 'Nama Tempat', Icons.place),
            _buildTextField(_locationController, 'Lokasi Singkat', Icons.map),
            _buildTextField(_addressController, 'Alamat Lengkap', Icons.location_on, maxLines: 2),
            _buildTextField(_gmapsUrlController, 'Link Google Maps', Icons.location_searching),

            _sectionTitle("Detail Operasional"),
            _buildTextField(_opHoursController, 'Jam Operasional', Icons.access_time),
            _buildTextField(_priceController, 'Harga Tiket', Icons.confirmation_number),
            _buildCategoryDropdown(),

            _sectionTitle("Fasilitas"),
            _buildFacilitiesCheckbox(),

            _sectionTitle("Media Gambar"),
            _buildMultiImageInput(),
            const SizedBox(height: 10),
            const Text("* Gambar pertama atau 'Utama' akan tampil di dashboard",
                style: TextStyle(fontSize: 11, color: Colors.orange, fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            _buildImagePreview(),

            _sectionTitle("Deskripsi"),
            _buildTextField(_descController, 'Deskripsi', Icons.description, maxLines: 4),

            const SizedBox(height: 30),
            _saveButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildMultiImageInput() {
    return Column(
      children: List.generate(_imageControllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: _buildTextField(_imageControllers[index], 'URL Gambar ${index + 1}', Icons.link),
              ),
              if (_imageControllers.length > 1)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _imageControllers.removeAt(index);
                      if (_mainImageIndex >= _imageControllers.length) _mainImageIndex = 0;
                    });
                  },
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => setState(() => _imageControllers.add(TextEditingController())),
          icon: const Icon(Icons.add_photo_alternate, color: Color(0xFF6A1B9A)),
          label: const Text("Tambah URL Gambar"),
        ),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageControllers.length,
            itemBuilder: (context, index) {
              return ValueListenableBuilder(
                valueListenable: _imageControllers[index],
                builder: (context, value, child) {
                  final bool isMain = _mainImageIndex == index;
                  return Column(
                    children: [
                      Container(
                        width: 130, height: 130,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isMain ? const Color(0xFF6A1B9A) : Colors.grey.shade300, width: isMain ? 3 : 1),
                        ),
                        child: value.text.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.network(value.text, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.red)),
                        )
                            : const Icon(Icons.image_search, color: Colors.purple),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => setState(() => _mainImageIndex = index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMain ? const Color(0xFF6A1B9A) : Colors.white,
                          foregroundColor: isMain ? Colors.white : const Color(0xFF6A1B9A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFF6A1B9A))),
                        ),
                        child: Text(isMain ? "UTAMA" : "Set Utama", style: const TextStyle(fontSize: 10)),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (val) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6A1B9A), size: 20),
          filled: true,
          fillColor: const Color(0xFF6A1B9A).withAlpha(12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
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
          fillColor: const Color(0xFF6A1B9A).withAlpha(12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        items: ['Danau', 'Air Terjun', 'Hutan', 'Pegunungan', 'Sungai']
            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
            .toList(),
        onChanged: (val) => setState(() => _selectedCategory = val!),
      ),
    );
  }

  Widget _buildFacilitiesCheckbox() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF6A1B9A).withAlpha(12), borderRadius: BorderRadius.circular(12)),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 16),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6A1B9A),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Simpan Destinasi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}