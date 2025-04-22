// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, unused_import, avoid_web_libraries_in_flutter, avoid_print, deprecated_member_use, unused_local_variable, unused_element, unused_field, prefer_const_declarations

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true, // Enable DevicePreview only in debug mode.
      builder: (context) => const LandMark(),
    ),
  );
}

class LandMark extends StatelessWidget {
  const LandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Landmark Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _error;
  String _selectedLanguage = 'English';
  final Map<String, String> _languageMap = {
    'English': 'en',
    'French': 'fr',
    'Spanish': 'es',
    'German': 'de',
    'Arabic': 'ar',
  };

  Future<Map<String, dynamic>?> _captureAndSendImage() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Capture image
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        setState(() {
          _isLoading = false;
          _error = 'No image captured';
        });
        return null;
      }

      // Prepare multipart request
      final baseUrl =
          kIsWeb ? 'http://localhost:5001' : 'http://192.168.1.10:5001';
      final uri = Uri.parse('$baseUrl/recognize');
      var request = http.MultipartRequest('POST', uri);
      request.fields['language'] = _languageMap[_selectedLanguage]!;

      // Add image to request
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: 'image.jpg',
        ));
      } else {
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

      // Send request
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        if (data['error'] != null) {
          setState(() {
            _isLoading = false;
            _error = data['error'];
          });
          return null;
        }
        return {'data': data, 'baseUrl': baseUrl};
      } else {
        setState(() {
          _error =
              'Server error: ${response.statusCode}, Reason: ${response.reasonPhrase}';
        });
        return null;
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Landmark Explorer',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Select Language',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButton<String>(
                          value: _selectedLanguage,
                          items: _languageMap.keys.map((String language) {
                            return DropdownMenuItem<String>(
                              value: language,
                              child: Text(language),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedLanguage = newValue!;
                            });
                          },
                          isExpanded: true,
                          style: GoogleFonts.lato(fontSize: 16),
                          dropdownColor: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else if (_error != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          Text(
                            'Capture or select a landmark image',
                            style: GoogleFonts.lato(fontSize: 16),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  final result = await _captureAndSendImage();
                                  if (result != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResultScreen(
                                          data: result['data'],
                                          baseUrl: result['baseUrl'],
                                          selectedLanguage: _selectedLanguage,
                                          languageMap: _languageMap,
                                        ),
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Capture/Select Image'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String baseUrl;
  final String selectedLanguage;
  final Map<String, String> languageMap;

  const ResultScreen({
    super.key,
    required this.data,
    required this.baseUrl,
    required this.selectedLanguage,
    required this.languageMap,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final AudioPlayer _player = AudioPlayer();
  final ImagePicker _picker = ImagePicker();
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  bool _isLoadingNewImage = false;
  String? _audioError;
  String? _imageError;
  double _opacity = 0.0;
  late Map<String, dynamic> _currentData;
  late String _currentBaseUrl;
  String? _newError;

  @override
  void initState() {
    super.initState();
    _currentData = widget.data;
    _currentBaseUrl = widget.baseUrl;
    _player.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  Future<void> _playPauseAudio() async {
    try {
      setState(() {
        _isLoadingAudio = true;
        _audioError = null;
      });

      final audioUrl = '$_currentBaseUrl${_currentData['audio_url']}';

      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play(UrlSource(audioUrl));
      }
    } catch (e) {
      setState(() {
        _audioError = 'Audio error: $e';
      });
    } finally {
      setState(() {
        _isLoadingAudio = false;
      });
    }
  }

  Future<void> _captureNewImage() async {
    try {
      setState(() {
        _isLoadingNewImage = true;
        _newError = null;
        _imageError = null;
        _audioError = null;
      });

      // Stop current audio
      await _player.stop();

      // Capture image
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        setState(() {
          _isLoadingNewImage = false;
          _newError = 'No image captured';
        });
        return;
      }

      // Prepare multipart request
      final uri = Uri.parse('$_currentBaseUrl/recognize');
      var request = http.MultipartRequest('POST', uri);
      request.fields['language'] = widget.languageMap[widget.selectedLanguage]!;

      // Add image to request
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: 'image.jpg',
        ));
      } else {
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

      // Send request
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        if (data['error'] != null) {
          setState(() {
            _newError = data['error'];
          });
          return;
        }
        setState(() {
          _currentData = data;
          _opacity = 0.0; // Reset animation
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            _opacity = 1.0; // Trigger fade-in
          });
        });
      } else {
        setState(() {
          _newError =
              'Server error: ${response.statusCode}, Reason: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _newError = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoadingNewImage = false;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = '$_currentBaseUrl${_currentData['image_url']}';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _currentData['landmark'] ?? 'Result',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Full-screen gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 500),
              child: SingleChildScrollView(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              width: 320,
                              height: 180,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const CircularProgressIndicator();
                              },
                              errorBuilder: (context, error, stackTrace) {
                                setState(() {
                                  _imageError = 'Error loading image: $error';
                                });
                                return Text(_imageError!);
                              },
                            ),
                          ),
                        ),
                        if (_imageError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _imageError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Landmark name
                        Text(
                          _currentData['landmark'] ?? 'Unknown Landmark',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Description
                        Text(
                          _currentData['information'] ??
                              'No information available',
                          style: GoogleFonts.lato(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        // Audio controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isLoadingAudio
                                ? const CircularProgressIndicator()
                                : ElevatedButton.icon(
                                    onPressed: _playPauseAudio,
                                    icon: Icon(_isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow),
                                    label: Text(
                                        _isPlaying ? 'Pause' : 'Play Audio'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        if (_audioError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _audioError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // New image button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isLoadingNewImage
                                ? const CircularProgressIndicator()
                                : ElevatedButton.icon(
                                    onPressed: _captureNewImage,
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('Capture New Image'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        if (_newError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _newError!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
