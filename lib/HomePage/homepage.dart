// ignore_for_file: deprecated_member_use, unused_import

import 'package:demo1/Booking/booking.dart';
import 'package:demo1/ChatBot/providers/chat_provider.dart';
import 'package:demo1/ChatBot/providers/settings_provider.dart';
import 'package:demo1/ComputerVision/main.dart';
import 'package:demo1/Translate/HomeTranslate.dart';
import 'package:demo1/Weather/forecast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Begain/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: MaterialApp(
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/profile': (context) => const ProfileScreen(
                name: '',
                email: '',
                phone: '',
              ), // Placeholder route
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track the selected tab (0 for Home, 1 for Profile)

  Future<Map<String, String>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'Guest',
      'email': prefs.getString('user_email') ?? '',
      'phone': prefs.getString('user_phone') ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final userData = snapshot.data!;
        final userName = userData['name'] ?? 'Guest';
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
                    _buildAppBar(userName),
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
                            const Color(0xFF295F98),
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
                              Navigator.pushNamed(context, '/chatbot');
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
                child: _buildCustomBottomNavigationBar(context, userData),
              ),
            ],
          ),
        );
      },
    );
  }

  // Custom AppBar with dynamic user name
  Widget _buildAppBar(String userName) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Hello, $userName',
          style: const TextStyle(
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
  Widget _buildCustomBottomNavigationBar(
      BuildContext context, Map<String, String> userData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // White background
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              Icons.home,
              'Home',
              isActive: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0; // Set Home as active
                });
              },
            ),
            _buildBottomNavItem(
              Icons.person,
              'Profile',
              isActive: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1; // Set Profile as active
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      name: userData['name'] ?? 'Guest',
                      email: userData['email'] ?? '',
                      phone: userData['phone'] ?? '',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Navigation Item
  Widget _buildBottomNavItem(IconData icon, String label,
      {required bool isActive, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xff356899) : Colors.grey, // Active/Inactive color
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xff356899) : Colors.grey,
              fontSize: 12,
              fontFamily: 'RobotoMono',
            ),
          ),
        ],
      ),
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