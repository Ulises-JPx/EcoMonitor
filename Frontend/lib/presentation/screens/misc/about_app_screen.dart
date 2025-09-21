import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('EcoMonitor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('EcoMonitor is an IoT sensor monitoring application that helps farmers and researchers visualize environmental data in real time.'),
          SizedBox(height: 12),
          Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('- Real-time sensor dashboard'),
          Text('- Historical charts'),
          Text('- Device management'),
          SizedBox(height: 16),
          Text(
            'This app was developed for Practice #3 of Module 4: Hardware Integration for Data Science, taught by Professor David Higuera. Team 2, Course: Advanced Artificial Intelligence for Data Science I (Group 101).',
            style: TextStyle(fontSize: 14),
          ),
        ]),
      ),
    );
  }
}
