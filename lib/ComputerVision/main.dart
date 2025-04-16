// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, unused_import, avoid_web_libraries_in_flutter, avoid_print, deprecated_member_use, unused_local_variable, unused_element, unused_field
/*
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:typed_data'; // For handling bytes on the web
import 'dart:html' as html; // For web-specific speech synthesis
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import for SpinKit widgets

void main() {
  runApp(const LandmarkDetectorApp());
}

// Main application widget with a custom theme
class LandmarkDetectorApp extends StatelessWidget {
  const LandmarkDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Landmark Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Elegant font
        scaffoldBackgroundColor: Colors.blueGrey[50], // Subtle background
      ),
      home: const LandmarkHomePage(),
    );
  }
}

// Stateful widget for the landmark detection home page
class LandmarkHomePage extends StatefulWidget {
  const LandmarkHomePage({super.key});

  @override
  _LandmarkHomePageState createState() => _LandmarkHomePageState();
}

class _LandmarkHomePageState extends State<LandmarkHomePage> {
  XFile?
      _image; // Stores the captured image (still photo, not video) for both web and mobile
  String? _landmarkName; // Stores the detected landmark name
  String? _wikiInfo; // Stores Wikipedia information about the landmark
  bool _isLoading = false; // Tracks loading state during processing
  String _selectedLanguage = 'en'; // Default language for display and audio
  late dynamic
      _speech; // Dynamic variable for text-to-speech (FlutterTts for mobile, SpeechSynthesis for web)
  final ImagePicker _picker =
      ImagePicker(); // Image picker instance for capturing photos

  final Map<String, String> knownLandmarks = {
    'Pyramid': 'أهرامات الجيزة',
    'Eiffel Tower': 'برج إيفل',
    'Statue of Liberty': 'تمثال الحرية',
    'Great Wall': 'سور الصين العظيم',
    'Colosseum': 'الكولوسيوم',
    'Taj Mahal': 'تاج محل',
    'Machu Picchu': 'ماتشو بيتشو',
    'Christ the Redeemer': 'تمثال المسيح الفادي',
    'Big Ben': 'ساعة بيج بن',
    'Leaning Tower of Pisa': 'برج بيزا المائل',
    'Sydney Opera House': 'دار أوبرا سيدني',
    'Mount Rushmore': 'جبل راشمور',
    'Burj Khalifa': 'برج خليفة',
  };

  @override
  void initState() {
    super.initState();
    _initializeSpeech(); // Initialize speech system based on platform
    if (!kIsWeb) {
      _requestPermissions(); // Request camera and storage permissions on mobile
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeSpeech() {
    try {
      if (!kIsWeb) {
        _speech = FlutterTts(); // Initialize FlutterTts for mobile audio
        _configureTts(); // Configure TTS settings
      } else {
        // Web uses browser SpeechSynthesis for audio
        _speech = html.window.speechSynthesis;
        if (_speech == null) {
          print('Warning: SpeechSynthesis is not available on this browser.');
          _speech = Object(); // Fallback to avoid null
        }
      }
    } catch (e) {
      print('Error initializing speech: $e');
      _speech = Object(); // Fallback to avoid null
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request(); // Request camera permission on mobile
    await Permission.storage.request(); // Request storage permission on mobile
  }

  Future<void> _configureTts() async {
    if (!kIsWeb && _speech is FlutterTts) {
      String ttsLang = _selectedLanguage == 'ar' ? 'ar-SA' : 'en-US';
      try {
        await (_speech as FlutterTts)
            .setLanguage(ttsLang); // Set language for TTS
      } catch (e) {
        await (_speech as FlutterTts)
            .setLanguage('en-US'); // Fallback to English
      }
      await (_speech as FlutterTts).setSpeechRate(0.5); // Set speech rate
      await (_speech as FlutterTts).setVolume(1.0); // Set volume
      await (_speech as FlutterTts).setPitch(1.0); // Set pitch
    }
  }

  // Capture a still image from the camera (not video)
  Future<void> _captureImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera, // Uses camera to capture a single photo
        preferredCameraDevice: CameraDevice.rear, // Prefers rear camera
      );
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile; // Store the captured image
          _landmarkName = null; // Reset landmark name
          _wikiInfo = null; // Reset Wikipedia info
        });
        await _processImage(); // Process the captured image
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing image: $e'),
          backgroundColor: Colors.redAccent,
        ), // Show error if capture fails
      );
    }
  }

  // Process the captured image to detect landmark and fetch info
  Future<void> _processImage() async {
    if (_image == null) return;
    setState(() => _isLoading = true); // Show loading indicator

    try {
      final landmark = await _detectLandmark(); // Detect landmark from image
      setState(
          () => _landmarkName = landmark); // Update UI with detected landmark

      /* if (_landmarkName != null) {
        final info = await _getWikipediaInfo(_landmarkName!); // Fetch Wikipedia info
        setState(() => _wikiInfo = info); // Update UI with info

        await _speak(info); // Speak the information
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No landmark detected.')),
        );
      } */
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ), // Show error if processing fails
      );
    } finally {
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  // Detect landmark by sending image to backend
  Future<String?> _detectLandmark() async {
    try {
      final uri = Uri.parse(
          'http://192.168.1.9:5001/recognize'); // Backend endpoint for landmark detection
      final request = http.MultipartRequest('POST', uri);

      final bytes = await _image!.readAsBytes(); // Read image bytes
      img.Image? image = img.decodeImage(bytes); // Decode image
      if (image != null) {
        // Enhance image for better detection
        image = img.adjustColor(image, contrast: 1.5); // Increase contrast
        final sharpenKernel = [
          0,
          -1,
          0,
          -1,
          5,
          -1,
          0,
          -1,
          0
        ]; // Sharpening kernel
        image =
            img.convolution(image, filter: sharpenKernel); // Apply sharpening
        final enhancedBytes = img.encodeJpg(image); // Encode enhanced image

        request.files.add(http.MultipartFile.fromBytes(
          'image', // Field name expected by backend
          enhancedBytes,
          filename: 'image.jpg', // Filename for the request
        ));

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 30), // Timeout after 30 seconds
          onTimeout: () {
            throw Exception(
                'Request timed out. Check your internet or backend server.');
          },
        );

        if (streamedResponse.statusCode != 200) {
          String errorMessage;
          switch (streamedResponse.statusCode) {
            case 400:
              errorMessage = 'Bad request. Please check the image file.';
              break;
            case 500:
              errorMessage = 'Server error. Please try again later.';
              break;
            default:
              errorMessage = 'HTTP error: ${streamedResponse.statusCode}';
          }
          throw Exception(errorMessage);
        }

        final responseData = await streamedResponse.stream.bytesToString();
        final json = jsonDecode(responseData) as Map<String, dynamic>;

        if (json.containsKey('error')) {
          throw Exception('Backend error: ${json['error']}');
        }

        return json['landmark'] as String?; // Return detected landmark
      }
      return null;
    } catch (e) {
      throw Exception('Failed to detect landmark: $e');
    }
  }

  /* // Fetch Wikipedia information for the detected landmark
  Future<String> _getWikipediaInfo(String landmark) async {
    final query = knownLandmarks[landmark] ?? landmark; // Use known landmark name or original
    try {
      final uri = Uri.parse('https://$_selectedLanguage.wikipedia.org/w/api.php'
          '?action=query&format=json&prop=extracts&exintro&explaintext'
          '&titles=${Uri.encodeComponent(query)}'); // Wikipedia API endpoint
      final response = await http.get(uri);
      final json = jsonDecode(response.body);
      final pages = json['query']['pages'] as Map<String, dynamic>;
      final page = pages.values.first;
      return page['extract']?.substring(0, 600) ?? 'No information found.'; // Return first 600 characters
    } catch (e) {
      return 'Failed to fetch information: $e';
    }
  }

  // Speak the Wikipedia information using platform-specific TTS
  Future<void> _speak(String text) async {
    if (_speech == null) {
      print('Speech system not available.');
      return;
    }

    if (!kIsWeb && _speech is FlutterTts) {
      await (_speech as FlutterTts).speak(text); // Speak on mobile
    } else if (kIsWeb && _speech is html.SpeechSynthesis) {
      if (_speech.speaking) {
        _speech.cancel(); // Cancel ongoing speech on web
      }
      final utterance = html.SpeechSynthesisUtterance(text);
      utterance.lang = _selectedLanguage == 'ar' ? 'ar-SA' : 'en-US'; // Set language
      utterance.rate = 0.8; // Set speech rate
      _speech.speak(utterance); // Speak on web
    }
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF4B5EAA)
            ], // Deep blue gradient
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced AppBar with gradient and logo placeholder
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF4B5EAA)],
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.landscape, color: Colors.white, size: 40),
                    const SizedBox(width: 10),
                    Text(
                      'Landmark Explorer',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: const Offset(2.0, 2.0),
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Language selection with styled dropdown
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white70,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            isExpanded: true,
                            dropdownColor: Colors.white70,
                            icon: const Icon(Icons.language,
                                color: Colors.blueAccent),
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 16),
                            underline: Container(),
                            items: const [
                              DropdownMenuItem(
                                  value: 'ar', child: Text('العربية')),
                              DropdownMenuItem(
                                  value: 'en', child: Text('English')),
                              DropdownMenuItem(
                                  value: 'fr', child: Text('Français')),
                              DropdownMenuItem(
                                  value: 'es', child: Text('Español')),
                              DropdownMenuItem(
                                  value: 'de', child: Text('Deutsch')),
                              DropdownMenuItem(
                                  value: 'it', child: Text('Italiano')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedLanguage = value!;
                                if (!kIsWeb) {
                                  _configureTts(); // Update TTS language on mobile
                                } else {
                                  // Update web speech language if needed (handled in _speak)
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stable enhanced capture button
                      Center(
                        child: ElevatedButton(
                          onPressed: _captureImage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 20),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10, // Add shadow for depth
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFD4AF37),
                                  Color(0xFFF4E4BC)
                                ], // Rich gold gradient
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5), // Vertical shadow
                                ),
                              ],
                            ),
                            child: Container(
                              constraints: const BoxConstraints(
                                  minWidth: 200, minHeight: 60),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.camera_alt,
                                      color: Colors.black87, size: 28),
                                  SizedBox(width: 12),
                                  Text(
                                    'Capture Image',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Image display with card
                      if (_isLoading)
                        Center(
                          child: SpinKitFadingCircle(
                            color: Colors.white,
                            size: 50.0,
                          ), // Custom loading animation
                        )
                      else if (_image != null)
                        Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: FutureBuilder<Uint8List>(
                              future: _image!
                                  .readAsBytes(), // Asynchronously read image bytes
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  img.Image? decodedImage = img.decodeImage(
                                      snapshot.data!); // Decode image
                                  if (decodedImage != null) {
                                    // Enhance image for detection
                                    decodedImage = img.adjustColor(decodedImage,
                                        contrast: 1.5); // Increase contrast
                                    final sharpenKernel = [
                                      0,
                                      -1,
                                      0,
                                      -1,
                                      5,
                                      -1,
                                      0,
                                      -1,
                                      0
                                    ]; // Sharpening kernel
                                    decodedImage = img.convolution(decodedImage,
                                        filter:
                                            sharpenKernel); // Apply sharpening
                                    Uint8List enhancedBytes = img.encodeJpg(
                                        decodedImage); // Encode enhanced image
                                    return Image.memory(
                                      enhancedBytes, // Display the enhanced captured image
                                      height: 300,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Text(
                                        'Failed to load image',
                                        style:
                                            TextStyle(color: Colors.redAccent),
                                      ), // Fallback if image fails
                                    );
                                  }
                                }
                                return const Center(
                                    child: Text('Loading image...',
                                        style: TextStyle(color: Colors.white)));
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      // Landmark display
                      if (_landmarkName != null)
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.white70,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Landmark: $_landmarkName', // Display detected landmark name
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37), // Gold color
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      /* if (_wikiInfo != null)
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.white70,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _wikiInfo!, // Display Wikipedia information
                              style: const TextStyle(fontSize: 18, color: Colors.black87),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ), */
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:typed_data'; // For handling bytes on the web
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import for SpinKit widgets

void main() {
  runApp(
    DevicePreview(
      enabled: true, // Enable DevicePreview only in debug mode.
      builder: (context) => const LandmarkDetectorApp(),
    ),
  );
  runApp(const LandmarkDetectorApp());
}

// Main application widget with a custom theme
class LandmarkDetectorApp extends StatelessWidget {
  const LandmarkDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Landmark Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Elegant font
        scaffoldBackgroundColor: Colors.transparent, // Allow background to show
      ),
      home: const LandmarkHomePage(),
    );
  }
}

// Stateful widget for the landmark detection home page
class LandmarkHomePage extends StatefulWidget {
  const LandmarkHomePage({super.key});

  @override
  _LandmarkHomePageState createState() => _LandmarkHomePageState();
}

class _LandmarkHomePageState extends State<LandmarkHomePage> {
  XFile?
      _image; // Stores the captured image (still photo, not video) for both web and mobile
  String? _landmarkName; // Stores the detected landmark name
  String? _wikiInfo; // Stores Wikipedia information about the landmark
  bool _isLoading = false; // Tracks loading state during processing
  String _selectedLanguage = 'en'; // Default language for display and audio
  late FlutterTts _speech; // Use FlutterTts for all platforms
  final ImagePicker _picker =
      ImagePicker(); // Image picker instance for capturing photos

  final Map<String, String> knownLandmarks = {
    'Pyramid': 'أهرامات الجيزة',
    'Eiffel Tower': 'برج إيفل',
    'Statue of Liberty': 'تمثال الحرية',
    'Great Wall': 'سور الصين العظيم',
    'Colosseum': 'الكولوسيوم',
    'Taj Mahal': 'تاج محل',
    'Machu Picchu': 'ماتشو بيتشو',
    'Christ the Redeemer': 'تمثال المسيح الفادي',
    'Big Ben': 'ساعة بيج بن',
    'Leaning Tower of Pisa': 'برج بيزا المائل',
    'Sydney Opera House': 'دار أوبرا سيدني',
    'Mount Rushmore': 'جبل راشمور',
    'Burj Khalifa': 'برج خليفة',
  };

  @override
  void initState() {
    super.initState();
    _speech = FlutterTts(); // Initialize FlutterTts for all platforms
    _configureTts(); // Configure TTS settings
    if (!kIsWeb) {
      _requestPermissions(); // Request camera and storage permissions on mobile
    }
  }

  @override
  void dispose() {
    _speech.stop(); // Stop any ongoing speech
    super.dispose();
  }

  void _initializeSpeech() {
    // No longer needed as _speech is directly initialized with FlutterTts
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request(); // Request camera permission on mobile
    await Permission.storage.request(); // Request storage permission on mobile
  }

  Future<void> _configureTts() async {
    String ttsLang = _selectedLanguage == 'ar' ? 'ar-SA' : 'en-US';
    try {
      await _speech.setLanguage(ttsLang); // Set language for TTS
    } catch (e) {
      await _speech.setLanguage('en-US'); // Fallback to English
    }
    await _speech.setSpeechRate(0.5); // Set speech rate
    await _speech.setVolume(1.0); // Set volume
    await _speech.setPitch(1.0); // Set pitch
  }

  // Capture a still image from the camera (not video)
  Future<void> _captureImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera, // Uses camera to capture a single photo
        preferredCameraDevice: CameraDevice.rear, // Prefers rear camera
      );
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile; // Store the captured image
          _landmarkName = null; // Reset landmark name
          _wikiInfo = null; // Reset Wikipedia info
        });
        await _processImage(); // Process the captured image
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing image: $e'),
          backgroundColor: Colors.redAccent,
        ), // Show error if capture fails
      );
    }
  }

  // Process the captured image to detect landmark and fetch info
  Future<void> _processImage() async {
    if (_image == null) return;
    setState(() => _isLoading = true); // Show loading indicator

    try {
      final landmark = await _detectLandmark(); // Detect landmark from image
      setState(
          () => _landmarkName = landmark); // Update UI with detected landmark

      /* if (_landmarkName != null) {
        final info = await _getWikipediaInfo(_landmarkName!); // Fetch Wikipedia info
        setState(() => _wikiInfo = info); // Update UI with info

        await _speak(info); // Speak the information
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No landmark detected.')),
        );
      } */
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ), // Show error if processing fails
      );
    } finally {
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  // Detect landmark by sending image to backend
  Future<String?> _detectLandmark() async {
    try {
      print(
          'Sending request to http://192.168.1.9:5001/recognize'); // Debug log
      final uri = Uri.parse(
          'http://192.168.1.9:5001/recognize'); // Backend endpoint for landmark detection
      final request = http.MultipartRequest('POST', uri);

      final bytes = await _image!.readAsBytes(); // Read image bytes
      img.Image? image = img.decodeImage(bytes); // Decode image
      if (image != null) {
        // Enhance image for better detection
        image = img.adjustColor(image, contrast: 1.5); // Increase contrast
        final sharpenKernel = [
          0,
          -1,
          0,
          -1,
          5,
          -1,
          0,
          -1,
          0
        ]; // Sharpening kernel
        image =
            img.convolution(image, filter: sharpenKernel); // Apply sharpening
        final enhancedBytes = img.encodeJpg(image); // Encode enhanced image

        request.files.add(http.MultipartFile.fromBytes(
          'image', // Field name expected by backend
          enhancedBytes,
          filename: 'image.jpg', // Filename for the request
        ));

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 60), // Increased timeout to 60 seconds
          onTimeout: () {
            print('Request timed out after 60 seconds'); // Debug log
            throw Exception(
                'Request timed out. Check your internet or backend server.');
          },
        );

        print(
            'Received response with status: ${streamedResponse.statusCode}'); // Debug log
        if (streamedResponse.statusCode != 200) {
          String errorMessage;
          switch (streamedResponse.statusCode) {
            case 400:
              errorMessage = 'Bad request. Please check the image file.';
              break;
            case 500:
              errorMessage = 'Server error. Please try again later.';
              break;
            default:
              errorMessage = 'HTTP error: ${streamedResponse.statusCode}';
          }
          throw Exception(errorMessage);
        }

        final responseData = await streamedResponse.stream.bytesToString();
        print('Response data: $responseData'); // Debug log
        final json = jsonDecode(responseData) as Map<String, dynamic>;

        if (json.containsKey('error')) {
          throw Exception('Backend error: ${json['error']}');
        }

        return json['landmark'] as String?; // Return detected landmark
      }
      return null;
    } catch (e) {
      print('Error in _detectLandmark: $e'); // Debug log
      throw Exception('Failed to detect landmark: $e');
    }
  }

  /* // Fetch Wikipedia information for the detected landmark
  Future<String> _getWikipediaInfo(String landmark) async {
    final query = knownLandmarks[landmark] ?? landmark; // Use known landmark name or original
    try {
      final uri = Uri.parse('https://$_selectedLanguage.wikipedia.org/w/api.php'
          '?action=query&format=json&prop=extracts&exintro&explaintext'
          '&titles=${Uri.encodeComponent(query)}'); // Wikipedia API endpoint
      final response = await http.get(uri);
      final json = jsonDecode(response.body);
      final pages = json['query']['pages'] as Map<String, dynamic>;
      final page = pages.values.first;
      return page['extract']?.substring(0, 600) ?? 'No information found.'; // Return first 600 characters
    } catch (e) {
      return 'Failed to fetch information: $e';
    }
  }

  // Speak the Wikipedia information using platform-specific TTS
  Future<void> _speak(String text) async {
    if (_speech == null) {
      print('Speech system not available.');
      return;
    }

    await _speech.speak(text); // Speak on all platforms using FlutterTts
  } */

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final minDimension = size.shortestSide; // Use shortest side for scaling
    final isPortrait = size.height > size.width;
    final isSmallMobile = minDimension < 360; // e.g., iPhone SE
    final isMediumMobile =
        minDimension >= 360 && minDimension < 600; // e.g., Samsung M33
    final isLargeMobile = minDimension >= 600; // e.g., Galaxy S23 Ultra

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF4B5EAA)
                  ], // Deep blue gradient
                ),
              ),
            ),
          ),
          // Centered content
          SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth =
                      minDimension * 1.2; // Limit width based on screen
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(minDimension * 0.04),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // Prevent unnecessary expansion
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Enhanced AppBar with gradient and logo placeholder
                          Container(
                            padding: EdgeInsets.all(minDimension * 0.04),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.landscape,
                                    color: Colors.white,
                                    size: minDimension * 0.1),
                                SizedBox(width: minDimension * 0.03),
                                Text(
                                  'Landmark Explorer',
                                  style: TextStyle(
                                    fontSize: isSmallMobile
                                        ? minDimension * 0.08
                                        : minDimension * 0.06,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 4.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: minDimension * 0.03),
                          // Language selection with styled dropdown
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(minDimension * 0.04),
                            ),
                            color: Colors.white70,
                            child: Padding(
                              padding: EdgeInsets.all(minDimension * 0.03),
                              child: DropdownButton<String>(
                                value: _selectedLanguage,
                                isExpanded: true,
                                dropdownColor: Colors.white70,
                                icon: Icon(Icons.language,
                                    color: Colors.blueAccent,
                                    size: minDimension * 0.06),
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: minDimension * 0.05),
                                underline: Container(),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'ar', child: Text('العربية')),
                                  DropdownMenuItem(
                                      value: 'en', child: Text('English')),
                                  DropdownMenuItem(
                                      value: 'fr', child: Text('Français')),
                                  DropdownMenuItem(
                                      value: 'es', child: Text('Español')),
                                  DropdownMenuItem(
                                      value: 'de', child: Text('Deutsch')),
                                  DropdownMenuItem(
                                      value: 'it', child: Text('Italiano')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                    _configureTts(); // Update TTS language on all platforms
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: minDimension * 0.03),
                          // Stable enhanced capture button
                          Center(
                            child: ElevatedButton(
                              onPressed: _captureImage,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: minDimension * 0.08,
                                  vertical: minDimension * 0.05,
                                ),
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      minDimension * 0.06),
                                ),
                                elevation: 10, // Add shadow for depth
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFFF4E4BC)
                                    ], // Rich gold gradient
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      minDimension * 0.06),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(
                                          0,
                                          minDimension *
                                              0.02), // Vertical shadow
                                    ),
                                  ],
                                ),
                                child: Container(
                                  constraints: BoxConstraints(
                                    minWidth: minDimension * 0.4,
                                    minHeight: minDimension * 0.1,
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.camera_alt,
                                          color: Colors.black87,
                                          size: minDimension * 0.09),
                                      SizedBox(width: minDimension * 0.04),
                                      Text(
                                        'Capture Image',
                                        style: TextStyle(
                                          fontSize: minDimension * 0.06,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: minDimension * 0.03),
                          // Image display with card
                          if (_isLoading)
                            Center(
                              child: SpinKitFadingCircle(
                                color: Colors.white,
                                size: minDimension * 0.15, // Responsive size
                              ),
                            )
                          else if (_image != null)
                            Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(minDimension * 0.04),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(minDimension * 0.04),
                                child: FutureBuilder<Uint8List>(
                                  future: _image!
                                      .readAsBytes(), // Asynchronously read image bytes
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData) {
                                      img.Image? decodedImage = img.decodeImage(
                                          snapshot.data!); // Decode image
                                      if (decodedImage != null) {
                                        // Enhance image for detection
                                        decodedImage = img.adjustColor(
                                            decodedImage,
                                            contrast: 1.5); // Increase contrast
                                        final sharpenKernel = [
                                          0,
                                          -1,
                                          0,
                                          -1,
                                          5,
                                          -1,
                                          0,
                                          -1,
                                          0
                                        ]; // Sharpening kernel
                                        decodedImage = img.convolution(
                                            decodedImage,
                                            filter:
                                                sharpenKernel); // Apply sharpening
                                        Uint8List enhancedBytes = img.encodeJpg(
                                            decodedImage); // Encode enhanced image
                                        return Expanded(
                                          child: Image.memory(
                                            enhancedBytes, // Display the enhanced captured image
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Text(
                                              'Failed to load image',
                                              style: TextStyle(
                                                  color: Colors.redAccent),
                                            ), // Fallback if image fails
                                          ),
                                        );
                                      }
                                    }
                                    return Center(
                                        child: Text('Loading image...',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    minDimension * 0.05)));
                                  },
                                ),
                              ),
                            ),
                          SizedBox(height: minDimension * 0.03),
                          // Landmark display
                          if (_landmarkName != null)
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(minDimension * 0.04),
                              ),
                              color: Colors.white70,
                              child: Padding(
                                padding: EdgeInsets.all(minDimension * 0.05),
                                child: Text(
                                  'Landmark: $_landmarkName', // Display detected landmark name
                                  style: TextStyle(
                                    fontSize: isSmallMobile
                                        ? minDimension * 0.07
                                        : minDimension * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color(0xFFD4AF37), // Gold color
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          SizedBox(height: minDimension * 0.03),
                          /* if (_wikiInfo != null)
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(minDimension * 0.04),
                              ),
                              color: Colors.white70,
                              child: Padding(
                                padding: EdgeInsets.all(minDimension * 0.05),
                                child: Text(
                                  _wikiInfo!, // Display Wikipedia information
                                  style: TextStyle(fontSize: minDimension * 0.05, color: Colors.black87),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ), */
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
