import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mylifepair_matrimony/core/constants/app_constants.dart';
import 'package:mylifepair_matrimony/core/services/firebase_service.dart';
import 'package:mylifepair_matrimony/screens/splash_screen.dart';
import 'package:mylifepair_matrimony/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}