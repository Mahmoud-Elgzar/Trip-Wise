// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, unused_import, avoid_web_libraries_in_flutter, avoid_print, deprecated_member_use, unused_local_variable, unused_element, unused_field, prefer_const_declarations
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
