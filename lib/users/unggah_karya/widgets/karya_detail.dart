import 'package:flutter/material.dart';
import '../utils/karya_helper.dart';

class KaryaDetailSheet extends StatelessWidget {
  final dynamic karya;
  final VoidCallback onEdit;

  const KaryaDetailSheet({Key? key, required this.karya, required this.onEdit})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final judul = KaryaHelper.getProperty(karya, 'judul') ?? 'Tanpa Judul';
    final sinopsis = KaryaHelper.getProperty(karya, 'sinopsis') ?? '';
    final isi = KaryaHelper.getProperty(karya, 'isi') ?? '';
    final status = KaryaHelper.getProperty(karya, 'status') ?? 'pending';

    final createdAtRaw = KaryaHelper.getProperty(karya, 'created_at');
    final createdAt = KaryaHelper.parseDate(createdAtRaw);

    final gambarUrl = KaryaHelper.getImageUrl(karya);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // App bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: KaryaHelper.getStatusBackgroundColor(status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: KaryaHelper.getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (gambarUrl != null)
                    Container(
                      height: 200,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(gambarUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A486B),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    KaryaHelper.formatDate(createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),

                  const SizedBox(height: 16),

                  // SINTOPSIS SECTION - FIX: TAMBAH SINTOPSIS
                  if (sinopsis.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sinopsis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A486B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(
                            sinopsis,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  const Text(
                    'Isi Karya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A486B),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    isi,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2A486B),
                      side: const BorderSide(color: Color(0xFF2A486B)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A486B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
