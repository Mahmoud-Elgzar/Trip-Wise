import 'package:demo1/Begain/screens/welcome_screen.dart';
// ignore: unused_import
import 'package:demo1/ChatBot/main.dart' as chatbot_main;
import 'package:demo1/ChatBot/providers/chat_provider.dart';
import 'package:demo1/ChatBot/providers/settings_provider.dart';
import 'package:demo1/HomePage/homepage.dart' as home_main;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:demo1/ChatBot/screens/home_screen.dart' as chatbot_screen;

/*void main() {
  runApp(
    DevicePreview(
      enabled: true, // Enable DevicePreview only in debug mode.
      builder: (context) => const MyApp(),
    ),
  );
}*/
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
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        title: 'Demo Trip Wise',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const WelcomeScreen(),
        routes: {
          '/home': (context) => const home_main.HomeScreen(),
          '/chatbot': (context) => const chatbot_screen.HomeScreen(),
          'welcome': (context) => const WelcomeScreen()
        },
      ),
    );
  }
}
