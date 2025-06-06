// ignore_for_file: library_private_types_in_public_api, file_names, deprecated_member_use

import 'package:demo1/Translate/Translator_Screen.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const TranslationApp());
}

class TranslationApp extends StatelessWidget {
  const TranslationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Language Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TranslationScreen(),
    );
  }
}

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _textController = TextEditingController();

  String _srcLang = 'en';
  String _tgtLang = 'ar';
  String _translatedText = '';

  final Map<String, String> supportedLanguages = {
    "en": "English",
    "fr": "French",
    "es": "Spanish",
    "de": "German",
    "it": "Italian",
    "ru": "Russian",
    "zh": "Chinese",
    "ar": "Arabic",
    "hi": "Hindi",
    "ja": "Japanese",
    "ko": "Korean",
    "pt": "Portuguese",
    "nl": "Dutch",
    "sv": "Swedish",
    "pl": "Polish",
    "tr": "Turkish",
    "vi": "Vietnamese",
    "th": "Thai",
    "he": "Hebrew",
    "id": "Indonesian"
  };

  void _translate() async {
    final text = _textController.text;
    if (text.isEmpty) return;
    final result = await _apiService.translateText(_srcLang, _tgtLang, text);
    if (result != null) {
      setState(() {
        _translatedText = result;
      });
    }
  }

  void _switchLanguages() {
    setState(() {
      final temp = _srcLang;
      _srcLang = _tgtLang;
      _tgtLang = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text('T'),
            ),
            SizedBox(width: 10),
            Text('Language Translator'),
          ],
        ),
        backgroundColor: const Color(0xFF295F98),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.9, -0.5), // Adjusted to approximate -137 degrees
            end: Alignment(-0.9, 0.5),
            colors: [
              Color(0xFFE1D7C6),
              Color(0xFF295F98),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLanguageDropdown(_srcLang, (String? newLang) {
                  setState(() {
                    _srcLang = newLang!;
                  });
                }),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: Colors.white),
                  onPressed: _switchLanguages,
                ),
                _buildLanguageDropdown(_tgtLang, (String? newLang) {
                  setState(() {
                    _tgtLang = newLang!;
                  });
                }),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextBox('Enter text to translate', _textController, true),
            const SizedBox(height: 10),
            _buildTranslateButton(),
            const SizedBox(height: 20),
            _buildTextBox('Translation',
                TextEditingController(text: _translatedText), false),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
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
              _buildBottomNavItem(Icons.chat, 'Chat'),
              _buildBottomNavItem(Icons.history, 'History'),
              _buildBottomNavItem(Icons.favorite_border, 'Favourite'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(
      String selectedLang, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: selectedLang,
      items: supportedLanguages.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black),
      underline: Container(),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
    );
  }

  Widget _buildTextBox(
      String label, TextEditingController controller, bool editable) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            enabled: editable,
            maxLines: null,
            decoration: const InputDecoration.collapsed(hintText: 'Enter text'),
          ),
          if (!editable)
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.copy, color: Colors.grey),
                SizedBox(width: 10),
                Icon(Icons.share, color: Colors.grey),
                SizedBox(width: 10),
                Icon(Icons.star_border, color: Colors.grey),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTranslateButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: _translate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('Translate', style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Chat') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const TranslatorScreen(), // Replace with the Chat screen if needed
            ),
          );
        } else if (label == 'History') {
          // Add History screen navigation here if needed
        } else if (label == 'Favourite') {
          // Add Favourite screen navigation here if needed
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
