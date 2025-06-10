// main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'companies.dart';  // استيراد صفحة تسجيل الدخول

void main() {
  runApp(const HomeBooking());
}

class HomeBooking extends StatelessWidget {
  const HomeBooking({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 4),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            'TripWise',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 50,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
