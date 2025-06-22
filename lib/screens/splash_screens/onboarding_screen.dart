import 'package:flutter/material.dart';
import '../login_screens/sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      image: 'lib/src/splash_imgs/01.png',
      title: 'Elige a tus tutores',
      subtitle: 'En ** puedes elegir al docente con cual te sientas mas comodo',
    ),
    _OnboardingPageData(
      image: 'lib/src/shared_imgs/chat.png', // Usaremos un icono para el chat
      title: 'Chat IA',
      subtitle: 'Ten un IA para poder platicar cuando necesites',
    ),
    _OnboardingPageData(
      image: 'lib/src/splash_imgs/02.png',
      title: 'Siente comodo\nde expresarte',
      subtitle:
          'Amet mínim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit.',
    ),
  ];

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Splash screen',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  TextButton(
                    onPressed: _goToLogin,
                    child: const Text('Skip', style: TextStyle(color: Colors.black54)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          '${index + 1}/3',
                          style: TextStyle(color: Colors.grey[600], fontSize: 15),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 16),
                        if (page.image != null)
                          Image.asset(
                            page.image!,
                            height: 180,
                            fit: BoxFit.contain,
                          )
                        else
                          Icon(Icons.chat_bubble_outline, size: 120, color: Colors.black87),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.subtitle,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == i ? Colors.black : Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _currentPage == 0
                                  ? null
                                  : () {
                                      _controller.previousPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    },
                              child: Text(
                                'Prev',
                                style: TextStyle(
                                  color: _currentPage == 0 ? Colors.grey[400] : Colors.black54,
                                ),
                              ),
                            ),
                            if (_currentPage < _pages.length - 1)
                              TextButton(
                                onPressed: () {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                },
                                child: const Text('Next', style: TextStyle(color: Colors.red)),
                              )
                            else
                              TextButton(
                                onPressed: _goToLogin,
                                child: const Text('Inicia', style: TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String? image;
  final String title;
  final String subtitle;
  _OnboardingPageData({this.image, required this.title, required this.subtitle});
} 