import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/unggah_karya_service.dart';
import 'widgets/karya_card.dart';
import 'widgets/header_widget.dart';
import 'widgets/karya_form.dart';
import 'widgets/karya_detail.dart';
import 'utils/karya_helper.dart'; // TAMBAH INI

class KaryaSayaPage extends StatefulWidget {
  const KaryaSayaPage({Key? key}) : super(key: key);

  @override
  State<KaryaSayaPage> createState() => _KaryaSayaPageState();
}

class _KaryaSayaPageState extends State<KaryaSayaPage> {
  List<dynamic> karyaList = [];
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    _debugAuthCheck();
    _loadUserData();
  }

  Future<void> _debugAuthCheck() async {
    print('🔧 [DEBUG AUTH CHECK] ============================');
    final prefs = await SharedPreferences.getInstance();
    print(
      '🔐 Token: ${prefs.getString('token') != null ? "ADA" : "TIDAK ADA!"}',
    );
    print('👤 User ID: ${prefs.getInt('id_user')}');
    print('👤 Nama: ${prefs.getString('nama')}');
    print('📧 Email: ${prefs.getString('email')}');
    print('🔧 [END DEBUG] ================================');
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nama = prefs.getString('nama') ?? 'User';

      setState(() {
        userName = nama;
      });

      await _loadKaryaData();
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = 'Gagal memuat data pengguna';
      });
    }
  }

  Future<void> _loadKaryaData() async {
    try {
      final List<dynamic> karya = await CeritaService.getKaryaUser();
      setState(() {
        karyaList = karya;
        isLoading = false;
        isError = false;
      });
      print('✅ Loaded ${karya.length} karya');
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = e.toString();
      });
      print('❌ Load karya error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF457B9D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A486B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Karya Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadKaryaData,
          ),
        ],
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTambahKaryaDialog(context),
        backgroundColor: const Color(0xFF2A486B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 60, color: Colors.white.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadKaryaData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2A486B),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        HeaderWidget(userName: userName, karyaCount: karyaList.length),
        Expanded(
          child: karyaList.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadKaryaData,
                  color: const Color(0xFF2A486B),
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: karyaList.length,
                    itemBuilder: (context, index) {
                      final karya = karyaList[index];
                      return KaryaCard(
                        karya: karya,
                        onEdit: () => _editKarya(context, karya),
                        onDelete: () => _confirmDeleteKarya(context, karya),
                        onTap: () => _showDetailKarya(context, karya),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book, size: 80, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Belum ada karya',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan karya pertama Anda!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTambahKaryaDialog(BuildContext context) async {
    print('🎯 [DIALOG] Show tambah karya dialog');

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => KaryaFormDialog(
        title: 'Tambah Karya Baru',
        onSave: (judul, sinopsis, isi, imagePath) async {
          print('📝 [FORM] Submit dengan data:');
          print('📝 Judul: $judul');
          print('📝 Sinopsis: ${sinopsis.length} chars');
          print('📝 Isi: ${isi.length} chars');
          print('🖼️ Image: $imagePath');

          try {
            // Tampilkan loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                content: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Mengupload karya...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            );

            // Panggil service dengan sinopsis
            final response = await CeritaService.uploadKarya(
              judul,
              sinopsis,
              isi,
              imagePath,
            );

            print('📥 [RESPONSE] Service response: $response');

            // Tutup loading dialog
            Navigator.pop(context);

            if (response['success'] == true) {
              print('✅ Upload berhasil');
              return true;
            } else {
              print('❌ Upload gagal: ${response['message']}');

              // Tampilkan error
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal: ${response['message']}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return false;
            }
          } catch (e) {
            // Tutup loading dialog
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            print('❌ [EXCEPTION] Upload error: $e');

            // Tampilkan error
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return false;
          }
        },
      ),
    );

    print('🎯 [DIALOG] Result: $result');

    if (result == true) {
      print('🔄 [RELOAD] Reloading data...');
      await _loadKaryaData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Karya berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _editKarya(BuildContext context, dynamic karya) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => KaryaFormDialog(
        title: 'Edit Karya',
        karya: karya,
        onSave: (judul, sinopsis, isi, imagePath) async {
          final id =
              KaryaHelper.getProperty(karya, 'id_karya') ??
              KaryaHelper.getProperty(karya, 'id') ??
              0;
          final currentImageUrl = KaryaHelper.getImageUrl(karya);

          final success = await CeritaService.updateKarya(
            id,
            judul,
            sinopsis,
            isi,
            imagePath,
            currentImageUrl,
          );

          return success;
        },
      ),
    );

    if (result == true) {
      await _loadKaryaData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Karya berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteKarya(BuildContext context, dynamic karya) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Karya'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${KaryaHelper.getProperty(karya, 'judul') ?? 'Karya ini'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final id =
            KaryaHelper.getProperty(karya, 'id_karya') ??
            KaryaHelper.getProperty(karya, 'id') ??
            0;

        final success = await CeritaService.deleteKarya(id);

        if (!mounted) return;
        Navigator.pop(context);

        if (success) {
          await _loadKaryaData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '"${KaryaHelper.getProperty(karya, 'judul')}" berhasil dihapus',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gagal menghapus karya'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDetailKarya(BuildContext context, dynamic karya) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KaryaDetailSheet(
        karya: karya,
        onEdit: () {
          Navigator.pop(context);
          _editKarya(context, karya);
        },
      ),
    );
  }
}