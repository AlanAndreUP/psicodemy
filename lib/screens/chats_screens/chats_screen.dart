import 'package:flutter/material.dart';
import '../../components/footer_nav_bar.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<Map<String, String>> chats = const [
    {'name': 'Mtro Ali', 'image': 'https://i.pravatar.cc/150?img=1'},
    {'name': 'Mtro Diana', 'image': 'https://i.pravatar.cc/150?img=2'},
    {'name': 'Mtro Rob', 'image': 'https://i.pravatar.cc/150?img=3'},
    {'name': 'Dr Horacio', 'image': 'https://i.pravatar.cc/150?img=4'},
    {'name': 'IA', 'image': 'https://i.pravatar.cc/150?img=5'},
  ];

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.chat_bubble_outline, size: 100, color: Colors.black87),
            const SizedBox(height: 12),
            const Text(
              'Chat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Elige con quién quieres hablar',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(chat['image']!),
                      ),
                      title: Text(
                        chat['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      onTap: () {
                        if (chat['name'] == 'Mtro Ali') {
                          Navigator.pushNamed(context, '/chat-detail');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Chat con ${chat['name']} aún no está disponible.'),
                              backgroundColor: Colors.grey[800],
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
}
