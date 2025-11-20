import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan nama user
              _buildHeader(),

              // Section "Kamu Mungkin Suka"
              _buildRecommendedSection(),

              // Section "Cerita Paling Banyak Dibaca"
              _buildPopularStoriesSection(),

              // Section "Terakhir Dibaca"
              _buildLastReadSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
      ), // PASS CONTEXT KE SINI
    );
  }

  // Header dengan nama user
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://via.placeholder.com/40'),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo,', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(
                'Carl Judul',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Spacer(),
          Icon(Icons.notifications_outlined, size: 28, color: Colors.grey),
        ],
      ),
    );
  }

  // Section "Kamu Mungkin Suka"
  Widget _buildRecommendedSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kamu Mungkin Suka',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _StoryCard(
                  title: 'Legenda Danau Toba',
                  author: 'Celine Bellen',
                  imageUrl: 'https://via.placeholder.com/120x150',
                ),
                SizedBox(width: 12),
                _StoryCard(
                  title: 'Bertang',
                  author: 'Tamara Arnault',
                  imageUrl: 'https://via.placeholder.com/120x150',
                ),
                SizedBox(width: 12),
                _StoryCard(
                  title: 'Bertuan',
                  author: 'Geraldine',
                  imageUrl: 'https://via.placeholder.com/120x150',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section "Cerita Paling Banyak Dibaca"
  Widget _buildPopularStoriesSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cerita Paling Banyak Dibaca',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: const [
              _StoryListItem(title: 'Bertang', author: 'Author 1'),
              SizedBox(height: 8),
              _StoryListItem(title: 'Bertang', author: 'Author 2'),
              SizedBox(height: 8),
              _StoryListItem(title: 'Bertuan', author: 'Author 3'),
            ],
          ),
        ],
      ),
    );
  }

  // Section "Terakhir Dibaca"
  Widget _buildLastReadSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terakhir Dibaca',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: const [
              _StoryListItem(title: 'Bertang', author: 'Author A'),
              SizedBox(height: 8),
              _StoryListItem(title: 'Bertang', author: 'Author B'),
              SizedBox(height: 8),
              _StoryListItem(title: 'Bertuan', author: 'Author C'),
            ],
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar - TERIMA PARAMETER CONTEXT
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0, // Home selected
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        // PANGGIL METHOD _onItemTapped DENGAN CONTEXT
        _onItemTapped(index, context);
      },
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

  // Method untuk menangani tap pada bottom navigation - PASTIKAN DI DALAM CLASS
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        // Already on home page, do nothing
        break;
      case 1:
        // Navigate to search page
        // Navigator.pushNamed(context, '/search');
        break;
      case 2:
        // Navigate to quiz page
        Navigator.pushNamed(context, '/kuis');
        break;
      case 3:
        // Navigate to profile page
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}

// Widget untuk card story horizontal
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
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar cover buku
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Image.network(
              imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          // Info buku
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

// Widget untuk list item story vertikal
class _StoryListItem extends StatelessWidget {
  final String title;
  final String author;

  const _StoryListItem({required this.title, required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Placeholder untuk gambar kecil
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.book, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
