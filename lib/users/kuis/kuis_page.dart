import 'package:flutter/material.dart';

class KuisPage extends StatelessWidget {
  const KuisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context), // PASS CONTEXT KE SINI
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    _buildTitleSection(),

                    const SizedBox(height: 30),

                    // Quiz Grid
                    _buildQuizGrid(context), // PASS CONTEXT KE SINI
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header dengan back button - TERIMA CONTEXT
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              onPressed: () {
                Navigator.pop(context); // SEKSUDAH BISA PAKAI CONTEXT
              },
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'KUIS',
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

  // Title Section
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uji Pengetahuanmu',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tentang Budaya Batak',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // Quiz Grid - TERIMA CONTEXT
  Widget _buildQuizGrid(BuildContext context) {
    final quizTopics = [
      _QuizTopic(
        title: 'Legenda Danau Toba',
        subtitle: 'Misteri Danau Terbesar',
        icon: Icons.water_drop,
        color: Colors.blue,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F6BED), Color(0xFF3B4FCF)],
        ),
      ),
      _QuizTopic(
        title: 'Si Gale-Gale',
        subtitle: 'Puppet Tradisional',
        icon: Icons.person_outline,
        color: Colors.orange,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9D4D), Color(0xFFFF7B2C)],
        ),
      ),
      _QuizTopic(
        title: 'Pusuk Buhit',
        subtitle: 'Gunung Keramat',
        icon: Icons.landscape,
        color: Colors.green,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
        ),
      ),
      _QuizTopic(
        title: 'Batu Parsidangan',
        subtitle: 'Sejarah Peradilan',
        icon: Icons.gavel,
        color: Colors.purple,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
        ),
      ),
      _QuizTopic(
        title: 'Batu Gantung',
        subtitle: 'Legenda Cinta',
        icon: Icons.favorite,
        color: Colors.pink,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
        ),
      ),
      _QuizTopic(
        title: 'Ulos Batak',
        subtitle: 'Kain Tradisional',
        icon: Icons.style,
        color: Colors.red,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: quizTopics.length,
      itemBuilder: (context, index) {
        return _QuizCard(
          quizTopic: quizTopics[index],
          context: context, // PASS CONTEXT KE _QuizCard
        );
      },
    );
  }
}

// Model untuk data quiz topic
class _QuizTopic {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Gradient gradient;

  _QuizTopic({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}

// Widget untuk card quiz
class _QuizCard extends StatelessWidget {
  final _QuizTopic quizTopic;
  final BuildContext context; // TAMBAH PARAMETER CONTEXT

  const _QuizCard({required this.quizTopic, required this.context});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Aksi ketika quiz dipilih
        _showQuizDialog(quizTopic.title);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: quizTopic.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: quizTopic.color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: -10,
              right: -10,
              child: Icon(
                quizTopic.icon,
                size: 80,
                color: Colors.white.withOpacity(0.2),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(quizTopic.icon, color: Colors.white, size: 24),
                  ),

                  const Spacer(),

                  // Title
                  Text(
                    quizTopic.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    quizTopic.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Start Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Mulai',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog konfirmasi mulai quiz - HAPUS PARAMETER CONTEXT
  void _showQuizDialog(String quizTitle) {
    showDialog(
      context: context, // SEKARANG PAKAI CONTEXT YANG SUDAH DITERIMA
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.quiz, size: 40, color: Colors.blue[700]),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  'Mulai $quizTitle?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  'Kuis ini berisi 10 pertanyaan tentang $quizTitle. Siap untuk menguji pengetahuan Anda?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Nanti'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigasi ke halaman quiz detail
                          // Navigator.pushNamed(context, '/quiz-detail');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Mulai',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
