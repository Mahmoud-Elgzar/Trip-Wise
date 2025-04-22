// ignore_for_file: deprecated_member_use

import 'package:demo1/Booking/booking.dart';
import 'package:demo1/ChatBot/main.dart';
import 'package:demo1/ChatBot/providers/chat_provider.dart';
import 'package:demo1/ChatBot/providers/settings_provider.dart';
import 'package:demo1/ComputerVision/main.dart';
import 'package:demo1/Translate/HomeTranslate.dart';
import 'package:demo1/Weather/forecast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE1D7C6),
                  Color(0xFF295F98),
                ],
                begin: Alignment(0.9, -0.5),
                end: Alignment(-0.9, 0.5),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildAppBar(),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _buildGradientButton(
                        context,
                        'Translate',
                        Icons.translate,
                        const Color(0XFF295F98),
                        const Color(0xFF295F98),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TranslationApp()),
                          );
                        },
                      ),
                      _buildGradientButton(
                        context,
                        'Chatbot',
                        Icons.chat_bubble,
                        const Color(0xFF195B6D),
                        const Color(0xFF195B6D),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MultiProvider(
                                providers: [
                                  ChangeNotifierProvider.value(
                                    value: Provider.of<ChatProvider>(context,
                                        listen: false),
                                  ),
                                  ChangeNotifierProvider.value(
                                    value: Provider.of<SettingsProvider>(
                                        context,
                                        listen: false),
                                  ),
                                ],
                                child: const ChatBot(),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildGradientButton(
                        context,
                        'Computer Vision',
                        Icons.remove_red_eye,
                        const Color(0xFFA76060),
                        const Color(0xFFA76060),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LandMark()),
                          );
                        },
                      ),
                      _buildGradientButton(
                        context,
                        'Booking',
                        Icons.airplane_ticket,
                        const Color(0xFF51472B),
                        const Color(0xFF51472B),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeBooking()),
                          );
                        },
                      ),
                      _buildGradientButton(
                        context,
                        'Forecast',
                        Icons.cloud,
                        const Color(0xFFE1D0B3),
                        const Color(0xFFE1D0B3),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Forecast()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Custom Bottom Navigation Bar positioned at the bottom
          Positioned(
            left: 10,
            right: 10,
            bottom: 0,
            child: _buildCustomBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  // Custom AppBar
  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Hello, Elgzar',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono',
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  // Custom Bottom Navigation Bar with gradient background
  Widget _buildCustomBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE1D7C6),
            Color(0xFF295F98),
          ],
          begin: Alignment(0.9, -0.5),
          end: Alignment(-0.9, 0.5),
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, 'Home'),
            _buildBottomNavItem(Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  // Bottom Navigation Item
  Widget _buildBottomNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'RobotoMono',
          ),
        ),
      ],
    );
  }

  // Gradient Button
  Widget _buildGradientButton(BuildContext context, String title, IconData icon,
      Color startColor, Color endColor,
      {required Function() onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPressed(),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: startColor.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
