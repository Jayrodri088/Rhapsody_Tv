import 'package:flutter/material.dart';
import 'package:rhapsody_tv/screens/sign_in_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF0FF), // light overall background
      body: Stack(
        children: [
          // Yellow overlay shape
          Positioned(
            top: screenHeight * 0.09,
            right: 0,
            child: Image.asset(
              'assets/images/home_shape_2.png',
              width: screenWidth * 0.73,
              fit: BoxFit.cover,
            ),
          ),

          // Blue shape overlay
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

          // Scrollable content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.06,
                right: screenWidth * 0.06,
                top: screenHeight * 0.07,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo + title
                  const Image(
                    image: AssetImage('assets/logo/logo.png'),
                    width: 90,
                    height: 90,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome to Rhapsody TV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),

                  // White Card Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.04,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color(0xFF0033FF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          height: 3,
                          width: 60,
                          color: const Color(0xFFD2CF2B),
                        ),

                        const SizedBox(height: 20),

                        // Email field
                        _inputField('Email address', screenHeight: screenHeight),
                        const SizedBox(height: 16),

                        // Password field
                        _inputField('Password', obscure: true, screenHeight: screenHeight),
                        const SizedBox(height: 16),

                        _inputField('Confirm Password', obscure: true, screenHeight: screenHeight),

                        // Checkbox for terms and conditions
                        Row(
                          children: [
                            Checkbox(
                              value: false, // Handle the state accordingly
                              onChanged: (value) {},
                              activeColor: const Color(0xFFD2CF2B),
                            ),
                            const Text(
                              'Accept terms and conditions',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7C7C7C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        // REGISTER Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0033FF),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD2CF2B).withOpacity(0.7),
                                blurRadius: 4,
                                spreadRadius: 0.3,
                                offset: const Offset(2, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0033FF),
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'REGISTER',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Register section (Clickable link)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Already have an account? Sign In",
                      style: TextStyle(
                        color: Color(0xFF7C7C7C),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom input field builder
  Widget _inputField(String hint, {bool obscure = false, required double screenHeight}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02, // Responsive padding
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0033FF), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0033FF), width: 2),
        ),
      ),
    );
  }
}
