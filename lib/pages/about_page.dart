import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // YouTube demo URL
  final String youtubeUrl = 'https://youtu.be/etwaqQ06sfM';

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(youtubeUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $youtubeUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4FC3F7), // Light blue
              Color(0xFF7E57C2), // Purple
              Color(0xFFAB47BC), // Light purple
              Color(0xFFEC407A), // Pink
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tentang Aplikasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
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
                    children: [
                      // Logo Section
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Color(0xFFAB47BC),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Calm Reminder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // About Card
                      _buildInfoCard(
                        title: 'Tentang CalmReminder',
                        content: 'CalmReminder adalah aplikasi smart mental health monitoring '
                            'yang dikembangkan untuk membantu pengguna memantau kondisi '
                            'kesehatan mental melalui data detak jantung dan suhu tubuh '
                            'secara real-time.',
                      ),
                      const SizedBox(height: 12),

                      // Theme Card
                      _buildInfoCard(
                        title: 'Tema Aplikasi',
                        content: 'Kesehatan (Mental Health Monitoring)',
                      ),
                      const SizedBox(height: 12),

                      // Technology Card
                      _buildInfoCard(
                        title: 'Platform & Teknologi',
                        content: '• Flutter (Mobile Client)\n'
                            '• Firebase (Backend & Database)\n'
                            '• MQTT & HTTP JSON\n'
                            '• ESP32 (IoT Device)',
                      ),
                      const SizedBox(height: 12),

                      // Developer Card
                      _buildInfoCard(
                        title: 'Developer',
                        content: '• 152023006 – Nasywa Adita Zain (Admin)\n'
                            '• 152023038 – Taras Al Fariz (User)',
                      ),
                      const SizedBox(height: 12),

                      // YouTube Demo Button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Demo Aplikasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7E57C2),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _launchURL,
                              icon: const Icon(Icons.play_circle_fill, size: 24),
                              label: const Text(
                                'Lihat Demo di YouTube',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7E57C2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}