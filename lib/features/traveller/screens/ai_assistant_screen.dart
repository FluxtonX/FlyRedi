import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../shared/services/api_service.dart';
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
    final response = await ApiService.post(
      '/api/assistant/chat',
      body: {
        'message': text,
        'history': history,
      },
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final reply = decoded is Map<String, dynamic> ? decoded['reply'] : null;
      if (reply is String && reply.trim().isNotEmpty) {
        return reply.trim();
      }
      throw Exception('Assistant returned an empty reply.');
    }

    final message = decoded is Map<String, dynamic> ? decoded['message'] : null;
    throw Exception(message is String ? message : 'Assistant request failed.');
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
      final response = await _sendAssistantMessage(cleanText, history);
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
    return Scaffold(
       // Premium dark theme matching screenshot
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.surface,
                width: 0.8,
              ),
            ),
          ),
          padding: EdgeInsets.only(top: 40, bottom: 12),
          child: Row(
            children: [
              SizedBox(width: 20),
              // Circular icon container with golden sparkle icon
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFFC229),
                  size: 22,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Assistant',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Always here to help',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                tooltip: 'Reset Conversation',
                onPressed: _resetChat,
              ),
              IconButton(
                icon: Icon(Icons.folder_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                tooltip: 'View Claims',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ResolveDashboardScreen()),
                  );
                },
              ),
              SizedBox(width: 8),
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
                ..._messages.map((msg) => _buildMessageBubble(msg)),

                // Bouncing/Analyzing Loading State
                if (_isTyping)
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFFFC229),
                            size: 14,
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Theme.of(context).colorScheme.outline),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Assistant is typing...',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
            color: Theme.of(context).colorScheme.surface,
          ),

          // Input Bar Area
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Ask a question...',
                          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), fontSize: 15),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) => _handleSubmitted(value),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _handleSubmitted(_textController.text),
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFC229), // Gold amber Send button
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded, // Styled paper plane send icon
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
      bottomNavigationBar:
          widget.showBottomNav ? const TravellerBottomNav(activeIndex: 3) : null,
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isAI = !msg.isUser;
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAI) ...[
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFFFFC229),
                size: 14,
              ),
            ),
            SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: msg.isUser ? const Color(0xFFFFC229) : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: msg.isUser ? const Radius.circular(20) : Radius.zero,
                  bottomRight: msg.isUser ? Radius.zero : const Radius.circular(20),
                ),
                border: msg.isUser
                    ? null
                    : Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: msg.isUser ? Colors.black : Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (msg.isUser) ...[
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                size: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
