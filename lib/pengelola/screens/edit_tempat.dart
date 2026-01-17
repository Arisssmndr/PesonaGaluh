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
  late TextEditingController _gmapsUrlController;
  late TextEditingController _priceController;
  late TextEditingController _opHoursController;
  late TextEditingController _descController;

  List<TextEditingController> _imageControllers = [];
  int _mainImageIndex = 0;

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
    _gmapsUrlController = TextEditingController(text: widget.place['gmapsUrl'] ?? '');
    _priceController = TextEditingController(text: widget.place['price']?.toString());
    _opHoursController = TextEditingController(text: widget.place['operationalHours'] ?? '');
    _descController = TextEditingController(text: widget.place['description']);
    _selectedCategory = widget.place['category'] ?? 'Danau';

    if (widget.place['imagePaths'] != null) {
      List<dynamic> savedImages = widget.place['imagePaths'];
      String? mainUrl = widget.place['imagePath'];

      for (int i = 0; i < savedImages.length; i++) {
        String url = savedImages[i].toString();
        _imageControllers.add(TextEditingController(text: url));
        if (url == mainUrl) {
          _mainImageIndex = i;
        }
      }
    } else if (widget.place['imagePath'] != null) {
      _imageControllers.add(TextEditingController(text: widget.place['imagePath']));
    }

    if (_imageControllers.isEmpty) _imageControllers.add(TextEditingController());

    if (widget.place['facilities'] != null) {
      List<dynamic> savedFacilities = widget.place['facilities'];
      for (var f in savedFacilities) {
        if (_facilities.containsKey(f)) _facilities[f] = true;
      }
    }
  }

  Future<void> _handleUpdate() async {
    if (_imageControllers[_mainImageIndex].text.isEmpty) {
      _showSnackBar('Gambar utama tidak boleh kosong!');
      return;
    }

    setState(() => _isLoading = true);

    String mainImageUrl = _imageControllers[_mainImageIndex].text;
    List<String> finalImagePaths = [];

    // Pastikan gambar utama di urutan ke-0
    finalImagePaths.add(mainImageUrl);
    for (int i = 0; i < _imageControllers.length; i++) {
      String url = _imageControllers[i].text;
      if (url.isNotEmpty && i != _mainImageIndex) {
        finalImagePaths.add(url);
      }
    }

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
        'gmapsUrl': _gmapsUrlController.text,
        'category': _selectedCategory,
        'price': _priceController.text,
        'operationalHours': _opHoursController.text,
        'facilities': selectedFacilities,
        'description': _descController.text,
        'imagePath': mainImageUrl,
        'imagePaths': finalImagePaths,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSnackBar('Perubahan berhasil disimpan!');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Gagal update: $e');
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
        title: const Text('Edit Destinasi', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const Text("* Klik 'Jadikan Utama' agar gambar tampil di dashboard",
                style: TextStyle(fontSize: 11, color: Colors.orange, fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            _buildImagePreview(),

            _sectionTitle("Deskripsi"),
            _buildTextField(_descController, 'Deskripsi', Icons.description, maxLines: 4),

            const SizedBox(height: 30),
            _updateButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

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
                      if (_mainImageIndex >= _imageControllers.length) {
                        _mainImageIndex = 0;
                      }
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
          label: const Text("Tambah Gambar Baru"),
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
                  final String url = value.text;

                  return Column(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isMain ? const Color(0xFF6A1B9A) : Colors.purple.withAlpha(25),
                              width: isMain ? 3 : 1
                          ),
                        ),
                        child: url.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.red),
                          ),
                        )
                            : const Icon(Icons.image_search, color: Colors.purple),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 130,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ElevatedButton(
                            onPressed: () => setState(() => _mainImageIndex = index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isMain ? const Color(0xFF6A1B9A) : const Color(0xFFF3E5F5),
                              foregroundColor: isMain ? Colors.white : const Color(0xFF6A1B9A),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: isMain ? BorderSide.none : const BorderSide(color: Color(0xFF6A1B9A), width: 0.5),
                              ),
                            ),
                            child: Text(
                                isMain ? "UTAMA" : "Jadikan Utama",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 16),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _updateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleUpdate,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6A1B9A),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _isLoading
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
          : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
}