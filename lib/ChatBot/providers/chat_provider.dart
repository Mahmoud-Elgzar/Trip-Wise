import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb; // Added for web detection
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: unused_import
import 'package:demo1/ChatBot/api/api_service.dart';
import 'package:demo1/ChatBot/constants.dart';
import 'package:demo1/ChatBot/hive/boxes.dart';
import 'package:demo1/ChatBot/hive/chat_history.dart';
import 'package:demo1/ChatBot/hive/settings.dart';
import 'package:demo1/ChatBot/hive/user_model.dart';
import 'package:demo1/ChatBot/models/message.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  // List of messages
  final List<Message> _inChatMessages = [];

  // Page controller
  final PageController _pageController = PageController();

  // Images file list
  List<XFile>? _imagesFileList = [];

  // Index of the current screen
  int _currentIndex = 0;

  // Current chatId
  String _currentChatId = '';

  // Initialize generative model
  GenerativeModel? _model;

  // Initialize text model
  GenerativeModel? _textModel;

  // Initialize vision model
  GenerativeModel? _visionModel;

  // Current model type
  String _modelType = 'gemini-2.0-flash';

  // Loading bool
  bool _isLoading = false;

  // Getters
  List<Message> get inChatMessages => _inChatMessages;
  PageController get pageController => _pageController;
  List<XFile>? get imagesFileList => _imagesFileList;
  int get currentIndex => _currentIndex;
  String get currentChatId => _currentChatId;
  GenerativeModel? get model => _model;
  GenerativeModel? get textModel => _textModel;
  GenerativeModel? get visionModel => _visionModel;
  String get modelType => _modelType;
  bool get isLoading => _isLoading;

  // Set inChatMessages
  Future<void> setInChatMessages({required String chatId}) async {
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);
    for (var message in messagesFromDB) {
      if (_inChatMessages.contains(message)) {
        log('Message already exists');
        continue;
      }
      _inChatMessages.add(message);
    }
    notifyListeners();
  }

  // Load messages from DB
  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');
    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      return Message.fromMap(Map<String, dynamic>.from(message));
    }).toList();
    notifyListeners();
    return newData;
  }

  // Set file list
  void setImagesFileList({required List<XFile> listValue}) {
    _imagesFileList = listValue;
    notifyListeners();
  }

  // Set the current model
  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  // Function to set the model based on isTextOnly
  Future<void> setModel({required bool isTextOnly}) async {
    final apiKey = getApiKey();
    if (apiKey.isEmpty) {
      log('Error: GEMINI_API_KEY is missing in .env file');
      throw Exception('GEMINI_API_KEY is missing');
    }

    if (isTextOnly) {
      _model = _textModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-2.0-flash'),
            apiKey: apiKey,
            generationConfig: GenerationConfig(
              temperature: 0.4,
              topK: 32,
              topP: 1,
              maxOutputTokens: 4096,
            ),
            safetySettings: [
              SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
              SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
            ],
          );
    } else {
      _model = _visionModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-1.5-flash'),
            apiKey: apiKey,
            generationConfig: GenerationConfig(
              temperature: 0.4,
              topK: 32,
              topP: 1,
              maxOutputTokens: 4096,
            ),
            safetySettings: [
              SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
              SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
            ],
          );
    }
    notifyListeners();
  }

  String getApiKey() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    return apiKey;
  }

  // Set current page index
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  // Set current chat id
  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  // Set loading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  // Delete chat
  Future<void> deletChatMessages({required String chatId}) async {
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    } else {
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    }

    if (currentChatId.isNotEmpty && currentChatId == chatId) {
      setCurrentChatId(newChatId: '');
      _inChatMessages.clear();
      notifyListeners();
    }
  }

  // Prepare chat room
  Future<void> prepareChatRoom({
    required bool isNewChat,
    required String chatID,
  }) async {
    if (!isNewChat) {
      final chatHistory = await loadMessagesFromDB(chatId: chatID);
      _inChatMessages.clear();
      _inChatMessages.addAll(chatHistory);
      setCurrentChatId(newChatId: chatID);
    } else {
      _inChatMessages.clear();
      setCurrentChatId(newChatId: chatID);
    }
  }

  // Send message to Gemini and get the streamed response
  Future<void> sendMessage({
    required String message,
    required bool isTextOnly,
  }) async {
    try {
      await setModel(isTextOnly: isTextOnly);
      setLoading(value: true);
      String chatId = getChatId();
      List<Content> history = await getHistory(chatId: chatId);
      final messagesBox =
          await Hive.openBox('${Constants.chatMessagesBox}$chatId');
      final userMessageId = messagesBox.keys.length;
      final assistantMessageId = messagesBox.keys.length + 1;

      final userMessage = Message(
        messageId: userMessageId.toString(),
        chatId: chatId,
        role: Role.user,
        message: StringBuffer(message),
        imagesUrls: getImagesUrls(isTextOnly: isTextOnly),
        timeSent: DateTime.now(),
      );

      _inChatMessages.add(userMessage);
      notifyListeners();

      if (currentChatId.isEmpty) {
        setCurrentChatId(newChatId: chatId);
      }

      await sendMessageAndWaitForResponse(
        message: message,
        chatId: chatId,
        isTextOnly: isTextOnly,
        history: history,
        userMessage: userMessage,
        modelMessageId: assistantMessageId.toString(),
        messagesBox: messagesBox,
      );
    } catch (e) {
      log('Error sending message: $e');
      setLoading(value: false);
      notifyListeners();
    }
  }

  // Send message to the model and wait for the response
  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required Message userMessage,
    required String modelMessageId,
    required Box messagesBox,
  }) async {
    final chatSession = _model!.startChat(
      history: history.isEmpty || !isTextOnly ? null : history,
    );

    final content = await getContent(
      message: message,
      isTextOnly: isTextOnly,
    );

    final assistantMessage = userMessage.copyWith(
      messageId: modelMessageId,
      role: Role.assistant,
      message: StringBuffer(),
      timeSent: DateTime.now(),
    );

    _inChatMessages.add(assistantMessage);
    notifyListeners();

    try {
      await for (final event in chatSession.sendMessageStream(content)) {
        _inChatMessages
            .firstWhere((element) =>
                element.messageId == assistantMessage.messageId &&
                element.role.name == Role.assistant.name)
            .message
            .write(event.text);
        log('Event: ${event.text}');
        notifyListeners();
      }
      log('Stream done');
      await saveMessagesToDB(
        chatID: chatId,
        userMessage: userMessage,
        assistantMessage: assistantMessage,
        messagesBox: messagesBox,
      );
      setLoading(value: false);
    } catch (e) {
      log('Error in sendMessageAndWaitForResponse: $e');
      setLoading(value: false);
    }
  }

  // Save messages to Hive DB
  Future<void> saveMessagesToDB({
    required String chatID,
    required Message userMessage,
    required Message assistantMessage,
    required Box messagesBox,
  }) async {
    await messagesBox.add(userMessage.toMap());
    await messagesBox.add(assistantMessage.toMap());

    final chatHistoryBox = Boxes.getChatHistory();
    final chatHistory = ChatHistory(
      chatId: chatID,
      prompt: userMessage.message.toString(),
      response: assistantMessage.message.toString(),
      imagesUrls: userMessage.imagesUrls,
      timestamp: DateTime.now(),
    );
    await chatHistoryBox.put(chatID, chatHistory);
    await messagesBox.close();
  }

  Future<Content> getContent({
    required String message,
    required bool isTextOnly,
  }) async {
    if (isTextOnly) {
      return Content.text(message);
    } else {
      final imageFutures =
          _imagesFileList?.map((imageFile) => imageFile.readAsBytes()).toList();
      final imageBytes = await Future.wait(imageFutures!);
      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
          .toList();
      return Content.multi([prompt, ...imageParts]);
    }
  }

  List<String> getImagesUrls({required bool isTextOnly}) {
    List<String> imagesUrls = [];
    if (!isTextOnly && imagesFileList != null) {
      for (var image in imagesFileList!) {
        imagesUrls.add(image.path);
      }
    }
    return imagesUrls;
  }

  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> history = [];
    if (currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);
      for (var message in inChatMessages) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }
    return history;
  }

  String getChatId() {
    return currentChatId.isEmpty ? const Uuid().v4() : currentChatId;
  }

  // Init Hive box
  static Future<void> initHive() async {
    if (kIsWeb) {
      // For web, initialize Hive without path_provider
      await Hive.initFlutter(Constants.geminiDB);
    } else {
      // For mobile/desktop, use path_provider
      final dir = await path.getApplicationDocumentsDirectory();
      Hive.init(dir.path);
      await Hive.initFlutter(Constants.geminiDB);
    }

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      await Hive.openBox<UserModel>(Constants.userBox);
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }
}
