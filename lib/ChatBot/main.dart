//import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:demo1/Chatbot/themes/my_theme.dart';
import 'package:demo1/Chatbot/providers/chat_provider.dart';
import 'package:demo1/Chatbot/providers/settings_provider.dart';
import 'package:demo1/Chatbot/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load .env file
    await dotenv.load(fileName: ".env");
    
    // Initialize Hive
    await ChatProvider.initHive();
  } catch (e) {
    debugPrint('Error during initialization: $e');
  }

  runApp(
    DevicePreview(
      enabled: true, // Enable only in debug mode and not on web
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ChatProvider()),
          ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ],
        child: const ChatBot(),
      ),
    ),
  );
}

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  @override
  void initState() {
    super.initState();
    setTheme();
  }

  void setTheme() {
    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.getSavedSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Required for device_preview
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Flutter Demo',
      theme:
          context.watch<SettingsProvider>().isDarkMode ? darkTheme : lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
