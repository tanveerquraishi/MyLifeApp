import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mylifepair_matrimony/core/constants/app_constants.dart';
import 'package:mylifepair_matrimony/screens/home_screen.dart';
import 'package:mylifepair_matrimony/utils/app_rating.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Starting...';

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('SplashScreen: initState called');
    }
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _status = 'Initializing app...';
      });
      if (kDebugMode) {
        print('SplashScreen: Starting initialization');
      }

      // Increment launch count for rating
      setState(() {
        _status = 'Setting up rating...';
      });
      await AppRating.incrementLaunchCount();
      if (kDebugMode) {
        print('SplashScreen: Rating count incremented');
      }
      
      // Wait for splash duration
      setState(() {
        _status = 'Loading...';
      });
      await Future.delayed(const Duration(seconds: AppConstants.splashDuration));
      if (kDebugMode) {
        print('SplashScreen: Splash duration completed');
      }
      
      setState(() {
        _status = 'Navigating to home...';
      });
      if (kDebugMode) {
        print('SplashScreen: Navigating to HomeScreen');
      }
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('SplashScreen error: $e');
      }
      setState(() {
        _status = 'Error: $e';
      });
      
      // Even if there's an error, try to navigate to home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                size: 60,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            
            // App name
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Tagline
            const Text(
              'Aapka Sahi Sathi - Hamari Zimedari',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            
            // Status text
            Text(
              _status,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}