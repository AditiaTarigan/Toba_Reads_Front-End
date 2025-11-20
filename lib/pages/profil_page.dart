import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'TobaReads',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile
            _buildProfileHeader(),

            // Stats Section
            _buildStatsSection(),

            // Menu Section
            _buildMenuSection(context), // PASS CONTEXT KE SINI
          ],
        ),
      ),
    );
  }

  // Header Profile dengan foto dan nama
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Foto Profil
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 3),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage('https://via.placeholder.com/100'),
            ),
          ),
          const SizedBox(height: 16),
          // Nama User
          const Text(
            'Kesya mutiara',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Stats Section dengan angka
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(number: '12', label: 'Dafita Beasan'),
          _StatItem(number: '100', label: 'Pengibut'),
        ],
      ),
    );
  }

  // Menu Section - TERIMA CONTEXT PARAMETER
  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Baris pertama: Cerita Favorit, Karya Saya, Kuis
          Row(
            children: [
              Expanded(
                child: _MenuButton(
                  icon: Icons.favorite_border,
                  title: 'Cerita Favorit',
                  onTap: () {
                    // Aksi ketika Cerita Favorit ditekan
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MenuButton(
                  icon: Icons.book_outlined,
                  title: 'Karya Saya',
                  onTap: () {
                    // Aksi ketika Karya Saya ditekan
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MenuButton(
                  icon: Icons.quiz_outlined,
                  title: 'Kuis',
                  onTap: () {
                    // Aksi ketika Kuis ditekan
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Menu Kelola Cerita
          _MenuListTile(
            icon: Icons.edit_note,
            title: 'Kelola Cerita',
            onTap: () {
              // Aksi ketika Kelola Cerita ditekan
            },
          ),
          const SizedBox(height: 8),

          // Menu Akun Saya
          _MenuListTile(
            icon: Icons.person_outline,
            title: 'Akun Saya',
            onTap: () {
              // Aksi ketika Akun Saya ditekan
            },
          ),
          const SizedBox(height: 8),

          // Menu Ganti Akun / Keluar - PASS CONTEXT KE SINI
          _MenuListTile(
            icon: Icons.logout,
            title: 'Ganti Akun / Keluar',
            titleColor: Colors.red,
            onTap: () => _showLogoutDialog(context), // PERBAIKAN DI SINI
          ),
        ],
      ),
    );
  }

  // Dialog konfirmasi logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Logic logout di sini
                Navigator.of(context).pop();
                // Navigasi ke login page
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// Widget untuk stat item
class _StatItem extends StatelessWidget {
  final String number;
  final String label;

  const _StatItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

// Widget untuk menu button (Cerita Favorit, Karya Saya, Kuis)
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk menu list tile (Kelola Cerita, Akun Saya, Logout)
class _MenuListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  const _MenuListTile({
    required this.icon,
    required this.title,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: titleColor ?? Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
