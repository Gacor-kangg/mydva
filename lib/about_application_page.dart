import 'package:flutter/material.dart';

class AboutApplicationPage extends StatelessWidget {
  const AboutApplicationPage({super.key});

  final List<Map<String, String>> members = const [
    {'nama': 'Maksima Insan A', 'nim': '25051204438'},
    {'nama': 'najwan', 'nim': '4231'},
    {'nama': 'Geacealsia Shello A', 'nim': '25051204421'},
    {'nama': 'saha', 'nim': '21'},
    {'nama': 'tri', 'nim': '12'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Applications'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.apps, size: 55, color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'About Applications',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Informasi aplikasi dan tim pengembang',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Tentang Aplikasi',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const Text(
              'Aplikasi ini dikembangkan sebagai bagian dari '
              'proyek pembelajaran untuk menerapkan pengetahuan '
              'dan keterampilan dalam bidang pengembangan aplikasi.',
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 30),

            const Text(
              'Tim Pengembang',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            ...List.generate(members.length, (index) {
              final member = members[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    member['nama']!.isEmpty
                        ? 'Nama Anggota ${index + 1}'
                        : member['nama']!,
                  ),
                  subtitle: Text(
                    member['nim']!.isEmpty ? 'NIM: -' : 'NIM: ${member['nim']}',
                  ),
                  trailing: const Icon(Icons.person_outline),
                ),
              );
            }),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                '© 2026 Application Development Team',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
