import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_screnn.dart';
import 'discover_screen.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Check authentication status and navigate accordingly
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Get auth provider first
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Wait for animation AND user data to load (whichever takes longer)
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      Future.delayed(const Duration(milliseconds: 500)), // Give time for storage to load
    ]);

    if (!mounted) return;

    // Check if user is already logged in
    final isAuthenticated = authProvider.isAuthenticated;

    if (!mounted) return;

    // Navigate based on authentication status
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => isAuthenticated
            ? const DiscoverScreen()  // Auto-login: Go directly to Discover
            : const AuthScreen(),      // Not logged in: Go to Sign In
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0033FF),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo/logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 10),
              const Text(
                'RhapsodyTV',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
