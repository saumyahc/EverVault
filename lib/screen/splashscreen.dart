import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'login.dart'; // Import your login screen

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3000,
      splash: Column(
        mainAxisSize: MainAxisSize.min, // Prevent overflow
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Image.asset(
              'assets/logo.png',
              height: 120,
              fit: BoxFit.contain, // Ensure it scales well
            ),
          ),
          SizedBox(height: 20),
          Text(
            'EverVault',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      nextScreen: LoginPage(), // Navigates to LoginScreen
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      backgroundColor: Colors.black, // Adjust theme color
    );
  }
}
