import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'karya_favorite/favorite_page.dart'; // Sesuaikan path import

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  bool isLoading = true;
  bool isLoggedIn = false;
  String userName = 'User';

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
        userName = nama;
      } else {
        isLoggedIn = false;
        userName = "User";
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
          onPressed: () => Navigator.pop(context),
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
                  _buildHeaderProfile(),
                  const SizedBox(height: 20),
                  if (isLoggedIn) _buildStatisticsSection(),
                  _buildMenuSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderProfile() {
    return Container(
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
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 60, color: Colors.grey[600]),
          ),
          const SizedBox(height: 15),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isLoggedIn ? 'Member Toba Reads' : '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      children: [
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
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: isLoggedIn ? _buildLoggedInMenu() : _buildGuestMenu(),
      ),
    );
  }

  List<Widget> _buildLoggedInMenu() {
    return [
      _buildMenuCard(
        icon: Icons.favorite,
        title: 'Cerita Favorit',
        onTap: () {
          // Navigasi langsung tanpa parameter, FavoritePage akan load data sendiri
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritePage()),
          );
        },
      ),
      _buildMenuCard(
        icon: Icons.book,
        title: 'Karya Saya',
        onTap: () => Navigator.pushNamed(context, '/karya_saya'),
      ),
      _buildMenuCard(
        icon: Icons.quiz,
        title: 'Kuis',
        onTap: () => Navigator.pushNamed(context, '/kuis'),
      ),
      _buildMenuCard(
        icon: Icons.person,
        title: 'Akun Saya',
        onTap: () => Navigator.pushNamed(context, '/akun_saya'),
      ),
      _buildMenuCard(
        icon: Icons.swap_horiz,
        title: 'Ganti Akun / Keluar',
        titleColor: Colors.red,
        onTap: _logout,
      ),
    ];
  }

  List<Widget> _buildGuestMenu() {
    return [
      _buildMenuCard(
        icon: Icons.info,
        title: 'Tentang Aplikasi',
        onTap: () => _showAboutDialog(context),
      ),
      _buildMenuCard(
        icon: Icons.help,
        title: 'Bantuan',
        onTap: () => _showHelpDialog(context),
      ),
      _buildMenuCard(
        icon: Icons.login,
        title: 'Login / Daftar',
        onTap: () => Navigator.pushNamed(context, '/'),
      ),
    ];
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

  Widget _buildMenuCard({
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
              await AuthService.logout();
              setState(() {
                isLoggedIn = false;
                userName = 'User';
              });
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
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
          'Hubungi customer service kami atau kunjungi website Toba Reads.',
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
