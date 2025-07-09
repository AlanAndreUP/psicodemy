import 'package:flutter/material.dart';
import 'package:flutter_application_1_a/screens/chats_screens/tutor_profile_screen.dart';
import 'package:flutter_application_1_a/components/footer_nav_bar.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=6'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.home, size: 16),
                SizedBox(width: 4),
                Text(">", style: TextStyle(color: Colors.grey)),
                SizedBox(width: 4),
                Text("Chat", style: TextStyle(color: Colors.grey)),
                SizedBox(width: 4),
                Text(">", style: TextStyle(color: Colors.grey)),
                SizedBox(width: 4),
                Text("Chat con Mtro Ali", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Mtro Ali',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TutorProfileScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMessageBubble(
                  isSentByMe: false,
                  message: 'Te espero en..',
                  timestamp: 'Enviado 10/20/25 13:59 PM',
                ),
                const SizedBox(height: 12),
                _buildMessageBubble(
                  isSentByMe: true,
                  message: 'Hola!',
                ),
              ],
            ),
          ),
          _buildMessageInput(),
        ],
      ),
      bottomNavigationBar: FooterNavBar(
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/citas');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/chats');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/foros');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  },
),
    );
  }

  Widget _buildMessageBubble({required bool isSentByMe, required String message, String? timestamp}) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSentByMe ? Colors.blue : Colors.pink[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (timestamp != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                timestamp,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Profe, quería pregunt--',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.orange),
              onPressed: () {
                // Acción de enviar mensaje
              },
            ),
          ],
        ),
      ),
    );
  }
}
