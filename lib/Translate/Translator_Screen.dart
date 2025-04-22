// ignore_for_file: file_names, unused_element, use_build_context_synchronously, avoid_print, deprecated_member_use

/*import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  final TextEditingController _textController = TextEditingController();
  String _detectedText = "Hello, how are you?";
  String _translatedText = "مرحبا كيف حالك؟";
  bool _isListening = false;
  String _selectedLanguage = 'English'; // Language selection

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts
          .setLanguage(_selectedLanguage == 'English' ? "en-US" : "ar");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(onResult: (result) {
        setState(() {
          _detectedText = result.recognizedWords;
          _textController.text =
              _detectedText; // Update text field with recognized text
          // Simulate translation logic
          _translatedText = _selectedLanguage == 'English'
              ? "مرحبا كيف حالك؟" // Translation of "Hello, how are you?" in Arabic
              : "Hello, how are you?"; // Translation in English
        });
      });
    } else {
      // Handle speech recognition not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speech recognition is not available.")),
      );
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
      _speechToText.stop();
    });
  }

  void _toggleLanguage() {
    setState(() {
      _selectedLanguage = _selectedLanguage == 'English' ? 'Arabic' : 'English';
      _textController.clear(); // Clear the text field when switching languages
      _detectedText = '';
      _translatedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 92, 105, 127),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.translate, color: Colors.blueAccent),
            ),
            SizedBox(width: 10),
            Text(
              "Language Translator",
              style: TextStyle(
                color: Color.fromARGB(255, 193, 201, 224),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 221, 227, 237),
              Color.fromARGB(255, 49, 89, 164)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Language Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _toggleLanguage,
                  child: _languageButton(_selectedLanguage),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.swap_horiz,
                      color: Color.fromARGB(255, 24, 21, 21)),
                ),
                GestureDetector(
                  onTap: _toggleLanguage,
                  child: _languageButton(
                      _selectedLanguage == 'English' ? "Arabic" : "English"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Detected Text (Speech-to-Text result)
            _buildDetectedTextBox(),

            const SizedBox(height: 20),

            // Translated Text (Text-to-Speech)
            _buildTranslatedTextBox(),

            const SizedBox(height: 30),

            // Speech Input Button
            AvatarGlow(
              animate: _isListening,
              glowColor: Colors.white,
              child: GestureDetector(
                onTapDown: (_) => _startListening(),
                onTapUp: (_) => _stopListening(),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 35,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: const Color.fromARGB(255, 31, 29, 29),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Press to Talk",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageButton(String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Text(
        language,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDetectedTextBox() {
    return Row(
      children: [
        _buildTextLabel("Detected Text"),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Text(
              _detectedText,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.volume_up,
              color: Color.fromARGB(255, 31, 54, 91)),
          onPressed: () => _speak(_detectedText),
        ),
      ],
    );
  }

  Widget _buildTranslatedTextBox() {
    return Row(
      children: [
        _buildTextLabel("Translated Text"),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Text(
              _translatedText,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.volume_up,
              color: Color.fromARGB(255, 31, 54, 91)),
          onPressed: () => _speak(_translatedText),
        ),
      ],
    );
  }

  Widget _buildTextLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Text(
        label,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
    );
  }
}*/

/*import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  final TextEditingController _textController = TextEditingController();
  String _detectedText = "Hello, how are you?";
  String _translatedText = "مرحبا كيف حالك؟";
  bool _isListening = false;
  String _selectedLanguage = 'English'; // Language selection

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts
          .setLanguage(_selectedLanguage == 'English' ? "en-US" : "ar");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(onResult: (result) {
        setState(() {
          _detectedText = result.recognizedWords;
          _textController.text =
              _detectedText; // Update text field with recognized text
          // Simulate translation logic
          _translatedText = _selectedLanguage == 'English'
              ? "مرحبا كيف حالك؟" // Translation of "Hello, how are you?" in Arabic
              : "Hello, how are you?"; // Translation in English
        });
      });
    } else {
      // Handle speech recognition not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speech recognition is not available.")),
      );
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
      _speechToText.stop();
    });
  }

  void _toggleLanguage() {
    setState(() {
      _selectedLanguage = _selectedLanguage == 'English' ? 'Arabic' : 'English';
      _textController.clear(); // Clear the text field when switching languages
      _detectedText = '';
      _translatedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 92, 105, 127),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.translate, color: Colors.blueAccent),
            ),
            SizedBox(width: 10),
            Text(
              "Language Translator",
              style: TextStyle(
                color: Color.fromARGB(255, 193, 201, 224),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE1D7C6),
              Color(0xFF295F98),
            ],
            begin: Alignment(0.9, -0.5), // Adjusted to approximate -137 degrees
            end: Alignment(-0.9, 0.5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Language Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _toggleLanguage,
                  child: _languageButton(_selectedLanguage),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.swap_horiz,
                      color: Color.fromARGB(255, 24, 21, 21)),
                ),
                GestureDetector(
                  onTap: _toggleLanguage,
                  child: _languageButton(
                      _selectedLanguage == 'English' ? "Arabic" : "English"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Detected Text (Speech-to-Text result)
            _buildTextBox(_detectedText, () => _speak(_detectedText)),

            const SizedBox(height: 20),

            // Translated Text (Text-to-Speech)
            _buildTextBox(_translatedText, () => _speak(_translatedText)),

            const SizedBox(height: 30),

            // Speech Input Button
            AvatarGlow(
              animate: _isListening,
              glowColor: Colors.white,
              child: GestureDetector(
                onTapDown: (_) => _startListening(),
                onTapUp: (_) => _stopListening(),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 35,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: const Color.fromARGB(255, 31, 29, 29),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Press to Talk",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageButton(String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        language,
        style: const TextStyle(
          color: Color(0xFF295F98),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTextBox(String text, VoidCallback onSpeak) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Color(0xFF295F98)),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.volume_up, color: Color(0xFF295F98)),
          onPressed: onSpeak,
        ),
      ],
    );
  }
}*/

import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  String _detectedText = "";
  String _translatedText = "";
  bool _isListening = false;

  final String _baseUrl = 'http://localhost:8000'; // Update with FastAPI URL

  // Language mappings
  final Map<String, String> _languageCodes = {
    'English': 'en',
    'Arabic': 'ar',
    'French': 'fr',
    'Spanish': 'es',
  };

  String _sourceLanguage = 'English';
  String _targetLanguage = 'Arabic';

  Future<void> _speak(String text, String language) async {
    if (text.isNotEmpty) {
      await _flutterTts.setLanguage(_languageCodes[language]!);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
  }

  Future<void> _translateText(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'src_lang': _languageCodes[_sourceLanguage],
          'tgt_lang': _languageCodes[_targetLanguage],
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _translatedText = data['translated_text'] ?? "Translation failed.";
        });
      } else {
        throw Exception("Translation failed: ${response.body}");
      }
    } catch (e) {
      print(e);
      setState(() {
        _translatedText = "Error occurred while translating.";
      });
    }
  }

  Future<void> _startListening() async {
    setState(() => _isListening = true);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/recognize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'language': _languageCodes[_sourceLanguage]}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _detectedText = data['recognized_text'] ?? "No speech detected.";
          _textController.text = _detectedText;
        });

        // Automatically translate after recognizing speech
        await _translateText(_detectedText);
      } else {
        throw Exception("Speech recognition failed: ${response.body}");
      }
    } catch (e) {
      print(e);
      setState(() {
        _detectedText = "Error occurred during speech recognition.";
      });
    } finally {
      setState(() => _isListening = false);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 92, 105, 127),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.translate, color: Colors.blueAccent),
            ),
            SizedBox(width: 10),
            Text(
              "Language Translator",
              style: TextStyle(
                color: Color.fromARGB(255, 193, 201, 224),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE1D7C6), Color(0xFF295F98)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Source and Target Language Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: _sourceLanguage,
                  items: _languageCodes.keys
                      .map((lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _sourceLanguage = value!;
                      _detectedText = "";
                      _translatedText = "";
                    });
                  },
                ),
                const Icon(Icons.swap_horiz, color: Colors.black),
                DropdownButton<String>(
                  value: _targetLanguage,
                  items: _languageCodes.keys
                      .map((lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _targetLanguage = value!;
                      _detectedText = "";
                      _translatedText = "";
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Detected Text Box
            _buildTextBox("Detected Text", _detectedText,
                () => _speak(_detectedText, _sourceLanguage)),

            const SizedBox(height: 20),

            // Translated Text Box
            _buildTextBox("Translated Text", _translatedText,
                () => _speak(_translatedText, _targetLanguage)),

            const SizedBox(height: 30),

            // Speech Input Button
            AvatarGlow(
              animate: _isListening,
              glowColor: Colors.white,
              child: GestureDetector(
                onTapDown: (_) async {
                  await _startListening(); // Start listening when the button is pressed
                },
                onTapUp: (_) {
                  setState(() {
                    _isListening = false;
                  });
                  _stop(); // Stop listening when the button is released
                },
                onTapCancel: () {
                  setState(() {
                    _isListening = false;
                  });
                  _stop(); // Stop listening if the touch is canceled
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 35,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: const Color.fromARGB(255, 31, 29, 29),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Press to Talk",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBox(String label, String text, VoidCallback onSpeak) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.blueAccent),
                onPressed: onSpeak,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
