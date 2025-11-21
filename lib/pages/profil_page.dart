import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../api/api_service.dart';

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
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  // Header Profile dengan data dinamis
  Widget _buildProfileHeader() {
    return FutureBuilder(
      future: Future.wait([
        AuthService.checkLoginStatus(),
        AuthService.getUsername(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final isLoggedIn = snapshot.data?[0] as bool? ?? false;
        final username = snapshot.data?[1] as String? ?? '';

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLoggedIn ? Colors.blue : Colors.grey,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: isLoggedIn
                      ? const AssetImage('assets/icon/tobareads_icon.png')
                      : null,
                  child: !isLoggedIn
                      ? const Icon(Icons.person, color: Colors.grey, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isLoggedIn ? username : 'Belum Login',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isLoggedIn ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLoggedIn ? 'Pengguna Aktif' : 'Silakan login terlebih dahulu',
                style: TextStyle(
                  fontSize: 14,
                  color: isLoggedIn ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Stats Section dengan data dari API
  Widget _buildStatsSection() {
    if (!AuthService.isLoggedIn) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(number: '0', label: 'Dafita Beasan'),
            _StatItem(number: '0', label: 'Pengibut'),
          ],
        ),
      );
    }

    return FutureBuilder(
      future: ApiService.getUserProfile(AuthService.userName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final profileData = snapshot.data;
        final dafita = profileData?['dafita_beasan']?.toString() ?? '0';
        final pengibut = profileData?['pengibut']?.toString() ?? '0';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(number: dafita, label: 'Dafita Beasan'),
              _StatItem(number: pengibut, label: 'Pengibut'),
            ],
          ),
        );
      },
    );
  }

  // Menu Section dengan conditional
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
                    if (!AuthService.isLoggedIn) {
                      _showLoginPrompt(context);
                      return;
                    }
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
                    if (!AuthService.isLoggedIn) {
                      _showLoginPrompt(context);
                      return;
                    }
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
                    // Kuis bisa diakses tanpa login
                    Navigator.pushNamed(context, '/kuis');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Menu Kelola Cerita - hanya untuk user login
          if (AuthService.isLoggedIn) ...[
            _MenuListTile(
              icon: Icons.edit_note,
              title: 'Kelola Cerita',
              onTap: () {
                // Aksi ketika Kelola Cerita ditekan
              },
            ),
            const SizedBox(height: 8),
          ],

          // Menu Akun Saya - hanya untuk user login
          if (AuthService.isLoggedIn) ...[
            _MenuListTile(
              icon: Icons.person_outline,
              title: 'Akun Saya',
              onTap: () {
                // Aksi ketika Akun Saya ditekan
              },
            ),
            const SizedBox(height: 8),
          ],

          // Menu Login/Logout - Conditional
          _MenuListTile(
            icon: AuthService.isLoggedIn ? Icons.logout : Icons.login,
            title: AuthService.isLoggedIn ? 'Keluar' : 'Login',
            titleColor: AuthService.isLoggedIn ? Colors.red : Colors.blue,
            onTap: () {
              if (AuthService.isLoggedIn) {
                _showLogoutDialog(context);
              } else {
                _navigateToLogin(context);
              }
            },
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
                // Logic logout
                AuthService.logout();
                Navigator.of(context).pop();
                // Refresh page atau navigasi ke home
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Prompt untuk login
  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Diperlukan'),
          content: const Text('Anda perlu login untuk mengakses fitur ini.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Nanti'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToLogin(context);
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  // Navigasi ke login page
  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/');
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: number == '0' ? Colors.grey : Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

// Widget untuk menu button
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

// Widget untuk menu list tile
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
