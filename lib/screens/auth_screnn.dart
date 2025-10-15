import 'package:flutter/material.dart';
import 'package:rhapsody_tv/screens/sign_in_screen.dart';
import 'package:rhapsody_tv/screens/sign_up_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // Start at first page (index 0)

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    // Calculate height ratios for elements
    final logoHeight = screenHeight * 0.1;
    final buttonHeight = screenHeight * 0.01;
    final textSpacing = screenHeight * 0.008;


    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_image.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0, 0.15),
            ),
          ),

          // Yellow shape
          Positioned(
            top: screenHeight * 0.08,
            right: 0,
            child: Image.asset(
              'assets/images/home_shape_2.png',
              width: screenWidth * 0.73,
              fit: BoxFit.cover,
            ),
          ),

          // Blue shape
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/home_shape_1.png',
              fit: BoxFit.cover,
              height: screenHeight * 0.35,
            ),
          ),

          // Foreground content with PageView
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.09,
              left: screenWidth * 0.06,
              right: screenWidth * 0.06,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo and title
                FadeInWidget(
                  duration: Duration(seconds: 2),
                  child: Column(
                    children: [
                      Image(
                        image: AssetImage('assets/logo/logo.png'),
                        width: logoHeight,
                        height: logoHeight,
                      ),
                      SizedBox(height: textSpacing),
                      Text(
                        'RhapsodyTV',
                        style: TextStyle(
                          fontSize: screenWidth * 0.07, // Responsive font size
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.22), // Dynamic spacing

                // PageView for multiple pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      // Page 0 - Get Started welcome page
                      _buildAuthPage(
                        screenWidth: screenWidth,
                        buttonHeight: buttonHeight,
                        title: 'Welcome to RhapsodyTV',
                        description: 'Stream unlimited entertainment',
                        primaryButtonText: 'Get Started',
                        secondaryButtonText: 'Learn More',
                        onPrimaryPressed: () {
                          // Navigate to next page
                          _pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        onSecondaryPressed: () {
                          // Could navigate to an info/about page
                          // For now, just animate to next page
                          _pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      // Page 1 - Sign In and Register page
                      _buildAuthPage(
                        screenWidth: screenWidth,
                        buttonHeight: buttonHeight,
                        title: null,
                        description: null,
                        primaryButtonText: 'Sign In',
                        secondaryButtonText: 'Register',
                        onPrimaryPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                          );
                        },
                        onSecondaryPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Clickable Page indicators (2 dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: _dot(
                        _currentPage == 0 ? Colors.yellow : Colors.white,
                        width: _currentPage == 0 ? 24 : 10,
                        shadowColor: Colors.black.withOpacity(0.6),
                        blur: 5,
                        offset: const Offset(0, 2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: _dot(
                        _currentPage == 1 ? Colors.yellow : Colors.white,
                        width: _currentPage == 1 ? 24 : 10,
                        shadowColor: Colors.black.withOpacity(0.6),
                        blur: 5,
                        offset: const Offset(0, 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthPage({
    required double screenWidth,
    required double buttonHeight,
    String? title,
    String? description,
    required String primaryButtonText,
    required String secondaryButtonText,
    required VoidCallback onPrimaryPressed,
    required VoidCallback onSecondaryPressed,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.08,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (description != null) ...[
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 30),
        ],
        if (title == null && description == null)
          const SizedBox(height: 20),

        // Primary button
        Container(
          width: screenWidth * 0.65,
          decoration: BoxDecoration(
            color: const Color(0xFF0033FF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF6C944).withOpacity(0.5),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(4, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0033FF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onPrimaryPressed,
            child: Text(
              primaryButtonText,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Secondary button
        Container(
          width: screenWidth * 0.65,
          decoration: BoxDecoration(
            color: const Color(0xFFD2CF2B),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0033FF).withOpacity(0.6),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(4, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD2CF2B),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onSecondaryPressed,
            child: Text(
              secondaryButtonText,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dot(
    Color color, {
    double width = 10,
    Color shadowColor = Colors.black,
    double blur = 5,
    Offset offset = const Offset(0, 2),
  }) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: blur,
            spreadRadius: 1,
            offset: offset,
          ),
        ],
      ),
    );
  }
}

// Fade animation (same as before)
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const FadeInWidget({super.key, required this.child, required this.duration});

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}
