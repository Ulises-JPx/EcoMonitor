import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/presentation/images/team_images.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = [
      {
        'name': 'Ulises Jaramillo Portilla',
        'role': 'Application Software Engineer',
        'matricula': 'A01798380',
        'image': TeamImages.ulises,
        'github': 'https://github.com/Ulises-JPx',
      },
      {
        'name': 'Jesús Ángel Guzmán Ortega',
        'role': 'Hardware Engineer',
        'matricula': 'A01799257',
        'image': TeamImages.jesus,
        'github': 'https://github.com/JesusAGO24',
      },
      {
        'name': 'Sebastian Espinoza Farías',
        'role': 'Software QA Engineer',
        'matricula': 'A01750311',
        'image': TeamImages.sebas,
        'github': 'https://github.com/Sebastian-Espinoza-25',
      },
      {
        'name': 'Santiago Villazón Ponce de León',
        'role': 'Embedded Systems Engineer',
        'matricula': 'A01746396',
        'image': TeamImages.santiago,
        'github': 'https://github.com/SantiagoVilla09',
      },
      {
        'name': 'Luis Ubaldo Balderas Sanchez',
        'role': 'Data Scientist',
        'matricula': 'A01751150',
        'image': TeamImages.luis,
        'github': 'https://github.com/Luiss1715',
      },
      {
        'name': 'José Antonio Moreno Tahuilán',
        'role': 'Backend Engineer',
        'matricula': 'A01747922',
        'image': TeamImages.jose,
        'github': 'https://github.com/pepemt',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const Text('Development Team', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final m = members[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(children: [
                      // Avatar from local images (falls back to initial)
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: m['image'] != null ? AssetImage(m['image'] as String) : null,
                        child: m['image'] == null ? Text(m['name']!.toString()[0]) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(m['role'] ?? '', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('Matrícula: ${m['matricula'] ?? ''}'),
                        ]),
                      ),
                      // Github logo button (local asset)
                      IconButton(
                        icon: Image.asset('lib/presentation/images/github.png', width: 28, height: 28),
                        onPressed: () {
                          final url = m['github'] as String?;
                          if (url != null && url.isNotEmpty) _openUrl(url);
                        },
                      )
                    ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
