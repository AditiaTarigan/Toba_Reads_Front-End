import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/karya_helper.dart';

class KaryaFormDialog extends StatefulWidget {
  final String title;
  final dynamic karya;
  final Future<bool> Function(
    String judul,
    String sinopsis,
    String isi,
    String? imagePath,
  )
  onSave; // PERBAIKAN: 4 PARAMETERS

  const KaryaFormDialog({
    Key? key,
    required this.title,
    this.karya,
    required this.onSave,
  }) : super(key: key);

  @override
  State<KaryaFormDialog> createState() => _KaryaFormDialogState();
}

class _KaryaFormDialogState extends State<KaryaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _sinopsisController = TextEditingController();
  final _isiController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.karya != null) {
      _judulController.text =
          KaryaHelper.getProperty(widget.karya, 'judul') ?? '';
      _sinopsisController.text =
          KaryaHelper.getProperty(widget.karya, 'sinopsis') ?? '';
      _isiController.text = KaryaHelper.getProperty(widget.karya, 'isi') ?? '';
      _currentImageUrl = KaryaHelper.getImageUrl(widget.karya);
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _sinopsisController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() {
        _selectedImage = File(image.path);
        _currentImageUrl = null;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _currentImageUrl = null;
    });
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context); // Close form dialog

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // PERBAIKAN: Panggil dengan 4 parameter
        final success = await widget.onSave(
          _judulController.text,
          _sinopsisController.text,
          _isiController.text,
          _selectedImage?.path,
        );

        if (!mounted) return;
        Navigator.pop(context); // Close loading

        Navigator.pop(context, success); // Return result
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gambar
              if (_currentImageUrl != null || _selectedImage != null)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : NetworkImage(_currentImageUrl!) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pilih Gambar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A486B),
                      ),
                    ),
                  ),
                  if (_currentImageUrl != null || _selectedImage != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: _removeImage,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Judul
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Karya',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 1,
                validator: KaryaHelper.validateJudul,
              ),

              const SizedBox(height: 16),

              // Sinopsis - PERBAIKAN: TAMBAH FIELD SINTOPSIS
              TextFormField(
                controller: _sinopsisController,
                decoration: const InputDecoration(
                  labelText: 'Sinopsis',
                  hintText: 'Ringkasan singkat karya Anda',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
                validator: KaryaHelper.validateSinopsis,
              ),

              const SizedBox(height: 16),

              // Isi
              TextFormField(
                controller: _isiController,
                decoration: const InputDecoration(
                  labelText: 'Isi Karya',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 5,
                validator: KaryaHelper.validateIsi,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => _submitForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2A486B),
          ),
          child: const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
