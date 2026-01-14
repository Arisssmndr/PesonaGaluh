import 'package:flutter/material.dart';
import 'edit_tempat.dart'; // Pastikan import file edit yang dibuat tadi

class DashboardPengelola extends StatefulWidget {
  const DashboardPengelola({super.key});

  @override
  State<DashboardPengelola> createState() => _DashboardPengelolaState();
}

class _DashboardPengelolaState extends State<DashboardPengelola> {
  bool _showAddForm = false;

  final List<Map<String, String>> _places = [
    {
      'id': '1',
      'name': 'Situ Lengkong Panjalu',
      'location': 'Panjalu, Ciamis',
      'category': 'Danau',
      'price': 'Rp 5.000',
      'description': 'Danau dengan pulau kecil berisi pemakaman leluhur',
    },
    {
      'id': '2',
      'name': 'Curug Tujuh Cigamea',
      'location': 'Cigamea, Ciamis',
      'category': 'Air Terjun',
      'price': 'Rp 10.000',
      'description': 'Air terjun bertingkat dengan tujuh undakan',
    },
  ];

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Danau';

  void _handleAddPlace() {
    if (_nameController.text.isNotEmpty && _locationController.text.isNotEmpty) {
      setState(() {
        _places.add({
          'id': DateTime.now().toString(),
          'name': _nameController.text,
          'location': _locationController.text,
          'category': _selectedCategory,
          'price': _priceController.text,
          'description': _descController.text,
        });
        _nameController.clear();
        _locationController.clear();
        _priceController.clear();
        _descController.clear();
        _showAddForm = false;
      });
    }
  }

  void _handleDelete(int index) {
    setState(() => _places.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            _statsSection(),
            _addToggleButton(),
            if (_showAddForm) _addForm(),
            _placesList(),
            _footerInfo(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Kelola Wisata Ciamis', style: TextStyle(color: Colors.white70)),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.logout, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
          )
        ],
      ),
    );
  }

  Widget _statsSection() {
    return Transform.translate(
      offset: const Offset(0, -25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            _statCard('Total Destinasi', _places.length.toString(), Icons.map_sharp, Colors.purple),
            const SizedBox(width: 16),
            _statCard('Kategori', '3', Icons.list_alt, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _addToggleButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _showAddForm = !_showAddForm),
        icon: Icon(_showAddForm ? Icons.close : Icons.add),
        label: Text(_showAddForm ? 'Tutup Form' : 'Tambah Destinasi Wisata'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _addForm() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tambah Destinasi Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _textField(_nameController, 'Nama Tempat'),
          _textField(_locationController, 'Lokasi'),
          _textField(_priceController, 'Harga Tiket'),
          _textField(_descController, 'Deskripsi', maxLines: 3),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleAddPlace,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan Destinasi'),
          )
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF3E5F5).withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _placesList() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daftar Destinasi Wisata', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _places.length,
            itemBuilder: (context, index) {
              final item = _places[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF6A1B9A), borderRadius: BorderRadius.circular(8)),
                      child: Text(item['category']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    const SizedBox(height: 12),
                    Text(item['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(item['location']!, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item['description']!, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                    const SizedBox(height: 12),
                    Text(item['price']!, style: const TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              // NAVIGASI KE HALAMAN EDIT
                              final updatedData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTempatScreen(place: item),
                                ),
                              );

                              // JIKA ADA DATA KEMBALI, UPDATE LIST
                              if (updatedData != null) {
                                setState(() {
                                  _places[index] = updatedData;
                                });
                              }
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6A1B9A),
                              side: const BorderSide(color: Color(0xFFF3E5F5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleDelete(index),
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text('Hapus'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Color(0xFFFFEBEE)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _footerInfo() {
    return Container(
      // PERBAIKAN ERROR EDGEINSETS DI SINI
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('ℹ️ Panduan Admin', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('• Kelola informasi destinasi wisata Ciamis', style: TextStyle(fontSize: 13, color: Colors.black54)),
          Text('• Tambah, edit, atau hapus destinasi', style: TextStyle(fontSize: 13, color: Colors.black54)),
          Text('• Pastikan informasi harga akurat', style: TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}
