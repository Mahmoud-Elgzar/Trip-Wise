// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:demo1/Begain/screens/welcome_screen.dart';
import 'package:demo1/ChatBot/hive/boxes.dart';
import 'package:demo1/ChatBot/hive/settings.dart';
import 'package:demo1/ChatBot/widgets/build_diaplay_image.dart';
import 'package:demo1/ChatBot/widgets/settings_tile.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _shouldSpeak = false;
  bool _isDarkMode = false;

  bool get shouldSpeak => _shouldSpeak;
  bool get isDarkMode => _isDarkMode;

  void toggleSpeak({required bool value}) {
    _shouldSpeak = value;
    _saveSettings();
    notifyListeners();
  }

  void toggleDarkMode({required bool value}) {
    _isDarkMode = value;
    _saveSettings();
    notifyListeners();
  }

  Future<void> loadSettings() async {
    final box = Boxes.getSettings();
    final settings = box.get('settings');
    if (settings != null) {
      _shouldSpeak = settings.shouldSpeak;
      _isDarkMode = settings.isDarkTheme;
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final box = Boxes.getSettings();
    final settings = Settings(
      shouldSpeak: _shouldSpeak,
      isDarkTheme: _isDarkMode,
    );
    await box.put('settings', settings);
  }

  void reset() {
    _shouldSpeak = false;
    _isDarkMode = false;
    _saveSettings();
    notifyListeners();
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? file;
  String userImage = '';
  String userName = 'Welcome';
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadUserData();
    context.read<SettingsProvider>().loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userImage = prefs.getString('user_image') ?? '';
      userName = prefs.getString('user_name') ?? 'Welcome';
      _nameController.text = userName;
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName);
    if (userImage.isNotEmpty) {
      await prefs.setString('user_image', userImage);
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      if (pickedImage != null) {
        setState(() {
          file = File(pickedImage.path);
          userImage = pickedImage.path;
        });
        await _saveUserData();
      }
    } catch (e) {
      log('error : $e');
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_name') ?? '';

      final response = await http.post(
        Uri.parse('http://tripwiseeeee.runasp.net/api/Auth/logout'),
        headers: {'Content-Type': 'application/json'},
        body: email.isNotEmpty ? jsonEncode({'email': email}) : null,
      );

      if (response.statusCode == 200) {
        // Clear all app data
        await prefs.clear();

        // Reset settings
        final settingsProvider = context.read<SettingsProvider>();
        settingsProvider.reset();

        // Close all Hive boxes
        await Hive.close();

        // Get the root context and navigate
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => const WelcomeScreen(),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${response.body}')),
        );
      }
    } catch (e) {
      log('Logout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during logout')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: BuildDisplayImage(
                  file: file,
                  userImage: userImage,
                  onPressed: pickImage,
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _nameController,
                onChanged: (value) {
                  setState(() => userName = value);
                  _saveUserData();
                },
                decoration: const InputDecoration(
                  labelText: 'User Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40.0),
              ValueListenableBuilder<Box<Settings>>(
                valueListenable: Boxes.getSettings().listenable(),
                builder: (context, box, child) {
                  final settingsProvider = context.read<SettingsProvider>();
                  return Column(
                    children: [
                      SettingsTile(
                        icon: Icons.mic,
                        title: 'Enable AI voice',
                        value: settingsProvider.shouldSpeak,
                        onChanged: (value) {
                          settingsProvider.toggleSpeak(value: value);
                        },
                      ),
                      const SizedBox(height: 10.0),
                      SettingsTile(
                        icon: settingsProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        title: 'Theme',
                        value: settingsProvider.isDarkMode,
                        onChanged: (value) {
                          settingsProvider.toggleDarkMode(value: value);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
