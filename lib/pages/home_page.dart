import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'upload_page.dart';
import '../services/cerita_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "selamat datang di Tobareads";
  List<dynamic> books = [];
  bool isLoadingBooks = true;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadBooks();
  }

  Future<void> loadUser() async {
    final data = await AuthService.getUserData();
    setState(() {
      username = data?['nama'] ?? "selamat datang di Tobareads";
    });
  }

  Future<void> loadBooks() async {
    try {
      setState(() => isLoadingBooks = true);
      List<dynamic> result = await CeritaService.getBooks();
      setState(() {
        books = result;
        isLoadingBooks = false;
      });
    } catch (e) {
      setState(() => isLoadingBooks = false);
      print('Error loading books: $e');
    }
  }

  Future<void> _navigateToUploadKarya() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UnggahKaryaPage()),
    );

    if (result == true) {
      await loadBooks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Karya berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // ListView utama (vertikal) — mencegah konflik gesture horizontal
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            _buildRecommendedSection(),
            _buildPopularStoriesSection(),
            _buildLastReadSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToUploadKarya,
        backgroundColor: const Color(0xFF2A486B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/icon/tobareads_icon.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Halo,',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.notifications_outlined,
            size: 28,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  // RECOMMENDED SECTION
  Widget _buildRecommendedSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kamu Mungkin Suka',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: isLoadingBooks
                ? const Center(child: CircularProgressIndicator())
                : books.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 16),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final b = books[index];
                      return Container(
                        width: 150,
                        margin: EdgeInsets.only(
                          right: 12,
                          left: index == 0 ? 8 : 0,
                        ),
                        child: _StoryCard(
                          title: b['judul'] ?? 'Tanpa Judul',
                          author: b['user']?['nama'] ?? 'Tidak diketahui',
                          imageUrl:
                              b['gambar_url'] ??
                              'https://via.placeholder.com/120x150',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // POPULAR STORIES SECTION
  Widget _buildPopularStoriesSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cerita Paling Banyak Dibaca',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          isLoadingBooks
              ? const Center(child: CircularProgressIndicator())
              : books.isEmpty
              ? _buildEmptyState()
              : SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 16),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final b = books[index];
                      return Container(
                        width: 150,
                        margin: EdgeInsets.only(
                          right: 12,
                          left: index == 0 ? 8 : 0,
                        ),
                        child: _StoryCard(
                          title: b['judul'] ?? 'Tanpa Judul',
                          author: b['user']?['nama'] ?? 'Tidak diketahui',
                          imageUrl:
                              b['gambar_url'] ??
                              'https://via.placeholder.com/120x150',
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // LAST READ SECTION
  Widget _buildLastReadSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terakhir Dibaca',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Belum ada buku yang kamu baca.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // EMPTY STATE (DITAMBAHKAN — dipanggil ketika books.isEmpty)
  Widget _buildEmptyState() {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'Belum ada cerita',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _navigateToUploadKarya,
              child: const Text(
                'Upload Cerita Pertamamu',
                style: TextStyle(color: Color(0xFF2A486B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION BAR
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) => _onItemTapped(index, context),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Quizz'),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
      case 2:
        Navigator.pushNamed(context, '/kuis');
        break;
      default:
        break;
    }
  }
}

// HORIZONTAL STORY CARD (tidak diubah)
class _StoryCard extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;

  const _StoryCard({
    required this.title,
    required this.author,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Image.network(
              imageUrl,
              width: 150,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.book, color: Colors.grey),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
