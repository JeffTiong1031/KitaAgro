import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/services/gemini_api_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  
  late GeminiApiService _geminiService;
  String? _userLocation;
  double? _currentTemp;
  String? _weatherCondition;
  List<String> _userPlants = [];

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiApiService('AIzaSyBkgljGd-zVO4lV5Cqpfipo0Br8pKwBe-k');
    _loadUserContext();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserContext() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Load user's location
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        _userLocation = userDoc.data()?['address'] as String?;
      }

      // Load user's plants
      final plantations = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('plantations')
          .get();
      
      _userPlants = plantations.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();

      setState(() {});
    } catch (e) {
      print('Error loading user context: $e');
    }
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: "🌱 Hello! I'm your AI Plantation Assistant. I can help you with:\n\n"
            "• Plant care advice\n"
            "• Pest & disease diagnosis\n"
            "• Growing tips for your region\n"
            "• Watering & fertilizer guidance\n"
            "• Weather-based recommendations\n\n"
            "What would you like to know?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final response = await _getAIResponse(message);
      
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Sorry, I encountered an error: $e\n\nPlease try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<String> _getAIResponse(String userMessage) async {
    // Build context-aware system prompt
    String contextInfo = "";
    
    if (_userLocation != null && _userLocation!.isNotEmpty) {
      contextInfo += "User location: $_userLocation\n";
    }
    
    if (_userPlants.isNotEmpty) {
      contextInfo += "User's garden plants: ${_userPlants.join(', ')}\n";
    }
    
    if (_currentTemp != null) {
      contextInfo += "Current temperature: ${_currentTemp!.toStringAsFixed(1)}°C\n";
    }
    
    if (_weatherCondition != null) {
      contextInfo += "Current weather: $_weatherCondition\n";
    }

    final String systemPrompt = '''
You are an expert plantation and agricultural advisor with deep knowledge of:
- Plant biology and cultivation techniques
- Pest and disease management
- Soil health and fertilization
- Climate-appropriate growing practices
- Organic and sustainable farming methods
- Regional agricultural conditions in Malaysia

$contextInfo

Provide helpful, accurate, and practical advice. Format your responses clearly with:
- Use bullet points for lists
- Use **bold** for important terms
- Keep advice concise but informative
- Always consider the user's local context when giving recommendations
- If the user asks about plants in their garden, reference them specifically

Answer the user's question:''';

    final String urlString =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${_geminiService.apiKey}';

    final Uri url = Uri.parse(urlString);

    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": "$systemPrompt\n\n$userMessage"},
          ],
        },
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 1024,
      },
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final text = jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? "I couldn't generate a response. Please try again.";
      } else {
        return "Server error (${response.statusCode}). Please try again later.";
      }
    } catch (e) {
      return "Connection error: $e";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'AI Plantation Assistant',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Thinking...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.green[600] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.smart_toy,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Assistant',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            if (message.isUser)
              Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              )
            else
              MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  strong: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  listBullet: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about your plants...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.green[600],
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: _isLoading ? null : _sendMessage,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
