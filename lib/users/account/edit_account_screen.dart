import 'package:flutter/material.dart'; // Import sudah benar
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_service.dart';

class EditAccountScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditAccountScreen({required this.userData});

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;

  String _selectedGender = 'Perempuan';
  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.userData['nama'] ?? '',
    );
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');
    _phoneController = TextEditingController(
      text: widget.userData['no_hp'] ?? '',
    );
    _selectedGender = widget.userData['jenis_kelamin'] ?? 'Perempuan';

    if (widget.userData['tanggal_lahir'] != null) {
      try {
        _selectedDate = DateTime.parse(widget.userData['tanggal_lahir']);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nama tidak boleh kosong')));
      return;
    }

    setState(() => _isSaving = true);

    final userEmail = widget.userData['email'];

    final updatedData = {
      'nama': _nameController.text,
      'bio': _bioController.text,
      'jenis_kelamin': _selectedGender,
      'tanggal_lahir': _selectedDate?.toIso8601String(),
      'no_hp': _phoneController.text,
    };

    print('🔄 Updating user with email: $userEmail');
    print('📝 Update data: $updatedData');

    final response = await ApiService.updateUserByEmail(userEmail, updatedData);

    setState(() => _isSaving = false);

    if (response['success'] == true) {
      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userBio', _bioController.text);
      await prefs.setString('userGender', _selectedGender);
      await prefs.setString('userPhone', _phoneController.text);
      if (_selectedDate != null) {
        await prefs.setString(
          'userBirthDate',
          _selectedDate!.toIso8601String(),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui profil: ${response['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil'),
        actions: [
          if (_isSaving)
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama
            Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Bio
            Text('Bio', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ceritakan tentang diri Anda',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Jenis Kelamin
            Text(
              'Jenis Kelamin',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Laki-laki'),
                    value: 'Laki-laki',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Perempuan'),
                    value: 'Perempuan',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Tanggal Lahir - PERBAIKAN DI SINI
            Text(
              'Tanggal Lahir',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey),
                    SizedBox(width: 10),
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' // Format manual
                          : 'Pilih tanggal lahir',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // No HP
            Text('No HP', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Masukkan nomor HP',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                child: _isSaving
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
