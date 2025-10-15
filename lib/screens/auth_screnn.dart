import 'package:flutter/material.dart';
import 'package:rhapsody_tv/screens/sign_in_screen.dart';
import 'package:rhapsody_tv/screens/sign_up_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

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

          // Foreground content
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

                // Sign In button
                Container(
                  width: screenWidth * 0.65, // Responsive width
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
                      padding: EdgeInsets.symmetric(vertical: buttonHeight),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Register button
                Container(
                  width: screenWidth * 0.65, // Responsive width
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
                      padding: EdgeInsets.symmetric(vertical: buttonHeight),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(
                      Colors.white,
                      width: 10,
                      shadowColor: Colors.black.withOpacity(0.6),
                      blur: 5,
                      offset: const Offset(0, 2),
                    ),
                    const SizedBox(width: 8),
                    _dot(
                      Colors.yellow,
                      width: 24,
                      shadowColor: Colors.black.withOpacity(0.6),
                      blur: 5,
                      offset: const Offset(0, 2),
                    ),
                    const SizedBox(width: 8),
                    _dot(
                      Colors.white,
                      shadowColor: Colors.black.withOpacity(0.6),
                      blur: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
