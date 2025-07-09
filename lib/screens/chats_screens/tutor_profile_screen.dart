import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorProfileScreen extends StatelessWidget {
  const TutorProfileScreen({super.key});

  final String tutorName = 'Ali Santiago Zuhun';
  final String phoneNumber = '+52 9614389077';
  final String email = 'Ali@gids.upchiapas.edu.mx';
  final String imageUrl = 'https://i.pravatar.cc/150?img=1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Información del Tutor', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF5CC9C0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(height: 16),
              Text(
                'Información del tutor',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(tutorName, style: const TextStyle(color: Colors.white)),
              Text(phoneNumber, style: const TextStyle(color: Colors.white)),
              Text(email, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final uri = Uri.parse('https://wa.me/${phoneNumber.replaceAll(' ', '').replaceAll('+', '')}');
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                    ),
                    child: const Text('Whatsapp →'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final uri = Uri.parse('mailto:$email');
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                    ),
                    child: const Text('Correo →'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
