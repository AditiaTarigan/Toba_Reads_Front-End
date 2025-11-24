import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  bool isLoading = true;
  bool isLoggedIn = false;
  String userName = 'Guest';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final nama = prefs.getString('nama');
    final token = prefs.getString('token');

    setState(() {
      if (nama != null && token != null) {
        isLoggedIn = true;
        userName = nama; // ini ambil dari login
      } else {
        isLoggedIn = false;
        userName = "Guest";
      }

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF457B9D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A486B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya (home)
          },
        ),
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // HEADER PROFILE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2A486B),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // FOTO PROFILE
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // NAMA USER
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // STATUS
                        Text(
                          isLoggedIn ? 'Member Toba Reads' : 'Guest User',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),

                        // TOMBOL LOGIN JIKA GUEST
                        if (!isLoggedIn) ...[
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6DADE7),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text('Login Sekarang'),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Kembali ke home
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: const Text('Kembali ke Home'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // STATISTIK (HANYA UNTUK USER LOGIN)
                  if (isLoggedIn) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Buku Dibaca', '0'),
                          _buildStatItem('Kuis Diselesaikan', '0'),
                          _buildStatItem('Rating', '0'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // MENU PROFIL
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        if (isLoggedIn) ...[
                          _buildMenuTile(
                            icon: Icons.edit,
                            title: 'Edit Profil',
                            onTap: () {
                              // Navigate to edit profile
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.history,
                            title: 'Riwayat Baca',
                            onTap: () {
                              // Navigate to reading history
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.quiz,
                            title: 'Riwayat Kuis',
                            onTap: () {
                              Navigator.pushNamed(context, '/kuis');
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.settings,
                            title: 'Pengaturan',
                            onTap: () {
                              // Navigate to settings
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.logout,
                            title: 'Keluar',
                            titleColor: Colors.red,
                            onTap: _logout,
                          ),
                        ] else ...[
                          // MENU UNTUK GUEST
                          _buildMenuTile(
                            icon: Icons.login,
                            title: 'Login / Daftar',
                            onTap: () {
                              Navigator.pushNamed(context, '/');
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.info,
                            title: 'Tentang Aplikasi',
                            onTap: () {
                              _showAboutDialog(context);
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.help,
                            title: 'Bantuan',
                            onTap: () {
                              _showHelpDialog(context);
                            },
                          ),
                          _buildMenuTile(
                            icon: Icons.home,
                            title: 'Kembali ke Home',
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF457B9D)),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout(); // ❗ hapus semua data login

              setState(() {
                isLoggedIn = false;
                userName = 'Guest';
              });

              Navigator.pop(context);

              // Kembali ke home dan refresh
              Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Aplikasi'),
        content: const Text(
          'Toba Reads adalah aplikasi perpustakaan digital yang menyediakan berbagai buku bacaan dan kuis edukatif.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bantuan'),
        content: const Text(
          'Untuk bantuan lebih lanjut, silakan hubungi customer service kami atau kunjungi website resmi Toba Reads.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
