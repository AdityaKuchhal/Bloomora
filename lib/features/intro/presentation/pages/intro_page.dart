import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroScreenData> _introScreens = [
    // Screen 1: Primary Dark Blue
    IntroScreenData(
      title: 'Welcome to Bloomora',
      subtitle: 'Your Child\'s Development Partner',
      description:
          'Personalized support for your child\'s unique developmental journey with AI-powered assessments.',
      icon: Icons.child_care,
      color: const Color(0xFF1E3A8A), // Primary Dark Blue
    ),
    // Screen 2: Secondary Blue
    IntroScreenData(
      title: 'Early Detection',
      subtitle: 'Identify Milestones',
      description:
          'Comprehensive assessments identify developmental delays early for your child\'s success.',
      icon: Icons.psychology,
      color: const Color(0xFF3B82F6), // Secondary Blue
    ),
    // Screen 3: Light Blue
    IntroScreenData(
      title: 'Personalized Activities',
      subtitle: 'Tailored to Your Child',
      description:
          'Customized activities designed for your child\'s age, abilities, and developmental goals.',
      icon: Icons.extension,
      color: const Color(0xFF60A5FA), // Light Blue
    ),
    // Screen 4: Accent Blue
    IntroScreenData(
      title: 'Track Progress',
      subtitle: 'Celebrate Achievements',
      description:
          'Monitor growth with detailed progress reports and celebrate milestones along the journey.',
      icon: Icons.trending_up,
      color: const Color(0xFF1D4ED8), // Accent Blue
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _introScreens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToSignup();
    }
  }

  void _skipIntro() {
    _goToSignup();
  }

  void _goToSignup() {
    context.go('/child-profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color(
              0xFFFFFEFE), // Very light, almost pure white background
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _skipIntro,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: const Color(
                                0xFF666666), // Soft gray (secondary text)
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _introScreens.length,
                  itemBuilder: (context, index) {
                    return _buildIntroScreen(_introScreens[index]);
                  },
                ),
              ),

              // Bottom Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _introScreens.length,
                        (index) => _buildPageIndicator(index),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Next/Get Started Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFF1E3A8A), // Sophisticated muted green
                          foregroundColor:
                              const Color(0xFFFFFFFF), // White (button text)
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Text(
                          _currentPage == _introScreens.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Already have an account? Sign In
                    GestureDetector(
                      onTap: () {
                        context.go('/email-verification');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontFamily: 'SF Pro Text',
                            ),
                          ),
                          Text(
                            'Sign In',
                            style: const TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro Text',
                            ),
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
      ),
    );
  }

  Widget _buildIntroScreen(IntroScreenData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white
                  .withOpacity(0.3), // White with glassmorphism effect
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.5), // White border for glassmorphism
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 50,
              color: const Color(0xFF000000), // Black (icons)
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000), // Black
              letterSpacing: -0.8,
              height: 1.1,
              fontFamily: 'SF Pro Display',
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            data.subtitle,
            style: TextStyle(
              fontSize: 18,
              color: const Color(0xFF666666), // Soft gray (secondary text)
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
              height: 1.2,
              fontFamily: 'SF Pro Text',
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            data.description,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF666666)
                  .withOpacity(0.9), // Soft gray (secondary text)
              height: 1.4,
              letterSpacing: -0.2,
              fontWeight: FontWeight.w400,
              fontFamily: 'SF Pro Text',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF1E3A8A) // Sophisticated muted green (active)
            : const Color(0xFF666666).withOpacity(0.3), // Soft gray (inactive)
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class IntroScreenData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  IntroScreenData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
