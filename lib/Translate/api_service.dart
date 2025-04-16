// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:8000'; // FastAPI server URL
  //final String baseUrl = 'https://52.23.168.88:8000'; // FastAPI server URL Deployment AWS

  Future<String?> translateText(
      String srcLang, String tgtLang, String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/translate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'src_lang': srcLang,
        'tgt_lang': tgtLang,
        'text': text,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['translated_text'];
    } else {
      print('Translation error: ${response.body}');
      return null;
    }
  }

  Future<String?> recognizeSpeech(String language) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recognize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'language': language}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['recognized_text'];
    } else {
      print('Recognition error: ${response.body}');
      return null;
    }
  }

  Future<bool> speakText(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/speak'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );
    return response.statusCode == 200;
  }
}
