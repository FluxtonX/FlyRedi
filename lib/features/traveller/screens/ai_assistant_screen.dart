import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/firestore_constants.dart';
import '../widgets/traveller_bottom_nav.dart';
import 'resolve_dashboard_screen.dart';

class AiAssistantScreen extends StatefulWidget {
  final bool showBottomNav;

  const AiAssistantScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
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

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  static const String _geminiApiKey = 'AIzaSyA0TdiAQhzaEyndq_gznLcuI-Ib5ofYJkQ'; // Insert your Gemini API key here
  
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _showQuickQuestions = true;

  final List<String> _quickQuestions = [
    'What compensation can I get?',
    'What should I do if my flight is delayed?',
    'Can I claim for cancellation?',
    'How long does claim processing take?',
  ];

  @override
  void initState() {
    super.initState();
    // Add initial greeting message
    _messages.add(
      ChatMessage(
        text: "Hello! I'm your AI travel assistant. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    _loadChatHistory();
  }

  void _loadChatHistory() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection('ai_chats')
        .orderBy('timestamp', descending: false)
        .get()
        .then((snap) {
      if (snap.docs.isNotEmpty && mounted) {
        setState(() {
          _messages.clear();
          for (final doc in snap.docs) {
            final data = doc.data();
            _messages.add(ChatMessage(
              text: data['text'] as String? ?? '',
              isUser: data['isUser'] as bool? ?? true,
              timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            ));
          }
          _showQuickQuestions = false;
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<Map<String, String>> _buildChatHistory() {
    return _messages
        .skip(1)
        .where((message) => message.text.trim().isNotEmpty)
        .map((message) => {
              'role': message.isUser ? 'user' : 'assistant',
              'text': message.text,
            })
        .toList();
  }

  Future<String> _sendAssistantMessage(
    String text,
    List<Map<String, String>> history,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated.');
    }

    final userMsgDoc = {
      'text': text,
      'isUser': true,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // 1. Write user message to Firestore
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection('ai_chats')
        .add(userMsgDoc);

    String reply = '';

    // 2. Gemini Live AI Assistant Call
    if (_geminiApiKey.isNotEmpty) {
      try {
        final List<Map<String, dynamic>> geminiContents = [];
        const systemPrompt = "You are a professional travel assistant. Help the traveler with questions about flight delays, cancellations, passenger compensation rights, claims, and travel advice. Please be concise, professional, and helpful.\n\n";

        for (int i = 0; i < history.length; i++) {
          final item = history[i];
          final isUser = item['role'] == 'user';
          var textVal = item['text'] ?? '';
          if (i == 0 && isUser) {
            textVal = systemPrompt + textVal;
          }
          geminiContents.add({
            'role': isUser ? 'user' : 'model',
            'parts': [
              {'text': textVal}
            ]
          });
        }

        var currentQuery = text;
        if (geminiContents.isEmpty) {
          currentQuery = systemPrompt + currentQuery;
        }
        geminiContents.add({
          'role': 'user',
          'parts': [
            {'text': currentQuery}
          ]
        });

        final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_geminiApiKey');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': geminiContents,
          }),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final firstCand = candidates.first as Map<String, dynamic>;
            final content = firstCand['content'] as Map<String, dynamic>?;
            if (content != null) {
              final parts = content['parts'] as List<dynamic>?;
              if (parts != null && parts.isNotEmpty) {
                final firstPart = parts.first as Map<String, dynamic>;
                final replyText = firstPart['text'] as String?;
                if (replyText != null && replyText.trim().isNotEmpty) {
                  reply = replyText.trim();
                  
                  // Save assistant response to Firestore
                  final assistantMsgDoc = {
                    'text': reply,
                    'isUser': false,
                    'timestamp': FieldValue.serverTimestamp(),
                  };
                  await FirebaseFirestore.instance
                      .collection(FirestoreConstants.usersCollection)
                      .doc(uid)
                      .collection('ai_chats')
                      .add(assistantMsgDoc);

                  return reply;
                }
              }
            }
          }
        }
        debugPrint('[AiAssistantScreen] Gemini API call returned status ${response.statusCode}: ${response.body}');
      } catch (e) {
        debugPrint('[AiAssistantScreen] Gemini API request failed: $e');
      }
    }

    // 3. Generate local smart response based on keywords (Local Fallback)
    final lowerText = text.toLowerCase();

    if (lowerText.contains('compensation') || lowerText.contains('payout') || lowerText.contains('refund')) {
      reply = 'Under EU Regulation 261/2004 or US DOT rules, you may be entitled to up to €600 (or equivalent) in compensation for flight delays over 3 hours, cancellations, or denied boarding, unless caused by extraordinary circumstances (e.g., extreme weather).';
    } else if (lowerText.contains('delay') || lowerText.contains('late')) {
      reply = 'If your flight is delayed:\n1. Keep your boarding pass.\n2. Ask the airline staff for the official reason.\n3. Request food and drink vouchers if the delay exceeds 2 hours.\n4. If delayed over 3 hours at your final destination, you may be eligible for financial compensation.';
    } else if (lowerText.contains('cancel') || lowerText.contains('cancellation')) {
      reply = 'If your flight is cancelled:\n1. The airline must offer you a full refund or re-routing.\n2. If you choose re-routing, they must provide meals, refreshments, and accommodation if overnight.\n3. If notified less than 14 days before departure, you might also claim compensation up to €600.';
    } else if (lowerText.contains('claim') || lowerText.contains('file')) {
      reply = 'To file a claim:\n1. Navigate to the "Claim Centre" tab in FlyRedi.\n2. Submit your flight details, airline, and disruption details.\n3. Our system will file the claim directly and track its progress with the relevant authorities.';
    } else if (lowerText.contains('status') || lowerText.contains('track') || lowerText.contains('monitor')) {
      reply = 'To monitor flight status, add the flight code to your home dashboard. The Flight Monitor card will automatically poll real-time status, delays, and gate details directly from AirLabs.';
    } else if (lowerText.contains('hello') || lowerText.contains('hi') || lowerText.contains('hey')) {
      reply = "Hello! I'm your AI travel assistant. I can answer questions about flight delays, cancellations, passenger compensation rights, and claim status. What can I do for you?";
    } else {
      reply = "I'm here to help with your travel questions. You can ask about flight delays, cancellations, passenger compensation rights, or how to file a claim. Let me know how I can assist you!";
    }

    final assistantMsgDoc = {
      'text': reply,
      'isUser': false,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Write assistant response to Firestore
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .collection('ai_chats')
        .add(assistantMsgDoc);

    return reply;
  }

  Future<void> _handleSubmitted(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _isTyping) return;
    final history = _buildChatHistory();
    _textController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: cleanText,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
      _showQuickQuestions = false;
    });
    _scrollToBottom();

    try {
      final startTime = DateTime.now();
      final response = await _sendAssistantMessage(cleanText, history);
      
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      if (elapsed < 800) {
        await Future.delayed(Duration(milliseconds: 800 - elapsed));
      }

      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: 'Sorry, I could not reach the AI assistant right now. Please check your connection and try again.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _resetChat() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .collection('ai_chats')
          .get()
          .then((snap) {
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        batch.commit();
      });
    }

    setState(() {
      _messages.clear();
      _messages.add(
        ChatMessage(
          text: "Hello! I'm your AI travel assistant. How can I help you today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _showQuickQuestions = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 0.8,
              ),
            ),
          ),
          padding: const EdgeInsets.only(top: 40, bottom: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFFC229),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Assistant',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Always here to help',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.54),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Message Area
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.all(24),
              children: [
                // Render message feed
                ..._messages.asMap().entries.map((entry) => _buildMessageBubble(entry.value, entry.key)),

                // Bouncing/Analyzing Loading State
                if (_isTyping)
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.outline),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFFC229)),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Assistant is typing...',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                  fontSize: 14,
                               ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Quick Questions Section (matches requested image layout perfectly!)
                if (_showQuickQuestions) ...[
                  SizedBox(height: 12),
                  Text(
                    'Quick questions:',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),
                  ..._quickQuestions.map((question) => Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: () => _handleSubmitted(question),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              question,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ],
            ),
          ),

          // Divider above Input Bar
          Container(
            height: 0.8,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
          ),

          // Input Bar Area (Matches Figma layout exactly)
          Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(
              bottom: isKeyboardOpen ? 10 : 24,
              left: 16,
              right: 16,
              top: 12,
            ),
            child: SafeArea(
              top: false,
              bottom: !isKeyboardOpen,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1.2,
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Ask a question...',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                              fontSize: 15),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 14),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) => _handleSubmitted(value),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _handleSubmitted(_textController.text),
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFC229), // Gold send button
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: (widget.showBottomNav && !isKeyboardOpen)
          ? const TravellerBottomNav(activeIndex: 3)
          : null,
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? const Color(0xFFFFC229)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft:
                      msg.isUser ? const Radius.circular(20) : Radius.zero,
                  bottomRight:
                      msg.isUser ? Radius.zero : const Radius.circular(20),
                ),
                border: msg.isUser
                    ? null
                    : Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: msg.isUser
                      ? Colors.black
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
