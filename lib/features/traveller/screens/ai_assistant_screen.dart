import 'dart:async';
import 'package:flutter/material.dart';
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

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
      _showQuickQuestions = false;
    });
    _scrollToBottom();

    // Simulated response logic
    Timer(const Duration(milliseconds: 1500), () {
      String response = "I have received your request. Let me check flight guidelines and regulatory databases to give you the most accurate assistance.";
      
      final cleanText = text.toLowerCase();
      if (cleanText.contains('compensation') || cleanText.contains('what compensation')) {
        response = 'Under air passenger rights regulations (such as EU261 or NCAA), you can get compensation for flight disruptions depending on the length of delay, flight distance, or cancellation notice:\n\n'
            '• **Delays over 3 hours:** up to **\$600 (€600)** depending on distance.\n'
            '• **Cancellations:** up to **\$600** if notified less than 14 days before departure.\n'
            '• **Overbooking / Denied Boarding:** Immediate compensation up to **\$600**.\n\n'
            'Let me know your flight number to check your specific eligibility!';
      } else if (cleanText.contains('delayed') || cleanText.contains('flight is delayed')) {
        response = 'If your flight is delayed, please follow these key steps:\n\n'
            '1. **Keep your boarding pass** and any travel documents.\n'
            '2. **Ask the airline** for the official reason for the delay.\n'
            '3. **Request food & drink vouchers** if the delay is over 2 hours.\n'
            '4. **Keep all receipts** if you incur out-of-pocket expenses (meals, hotels, transport).\n'
            '5. **Check your claim eligibility** using our automated assistant workflow!';
      } else if (cleanText.contains('cancellation') || cleanText.contains('claim for cancellation')) {
        response = 'Yes! You can claim compensation for cancelled flights if:\n\n'
            '• The airline notified you of the cancellation **less than 14 days** before the scheduled departure date.\n'
            '• The cancellation was **within the airline\'s control** (not due to extraordinary circumstances like extreme weather or air traffic control strikes).\n\n'
            'Additionally, the airline must offer you a choice between a full refund or an alternative flight to your destination.';
      } else if (cleanText.contains('how long') || cleanText.contains('processing take')) {
        response = 'Claim processing times vary by airline and case complexity:\n\n'
            '• **Straightforward claims:** Usually take **3 to 8 weeks**.\n'
            '• **Complex cases** (requiring regulatory intervention or legal steps): Can take **3 to 6 months**.\n\n'
            'We track and follow up on your claim in real-time. You can view your active claims anytime under the \'Claims\' tab!';
      }

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
    });
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
      backgroundColor: const Color(0xFF060B16), // Premium dark theme matching screenshot
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF070F24),
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF1E2D4D),
                width: 0.8,
              ),
            ),
          ),
          padding: const EdgeInsets.only(top: 40, bottom: 12),
          child: Row(
            children: [
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              // Circular icon container with golden sparkle icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF161E2E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFFC229),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Always here to help',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white60),
                tooltip: 'Reset Conversation',
                onPressed: _resetChat,
              ),
              IconButton(
                icon: const Icon(Icons.folder_outlined, color: Colors.white60),
                tooltip: 'View Claims',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ResolveDashboardScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
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
              padding: const EdgeInsets.all(24),
              children: [
                // Render message feed
                ..._messages.map((msg) => _buildMessageBubble(msg)),

                // Bouncing/Analyzing Loading State
                if (_isTyping)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF161E2E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFFFC229),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1B35),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC229)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Assistant is typing...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
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
                  const SizedBox(height: 12),
                  const Text(
                    'Quick questions:',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._quickQuestions.map((question) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: () => _handleSubmitted(question),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B1427),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              question,
                              style: const TextStyle(
                                color: Colors.white,
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
            color: const Color(0xFF1E2D4D),
          ),

          // Input Bar Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            color: const Color(0xFF060B16),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1427),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF1E2D4D),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Ask a question...',
                          hintStyle: TextStyle(color: Colors.white30, fontSize: 15),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _handleSubmitted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _handleSubmitted(_textController.text),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC229), // Gold amber Send button
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAI) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF161E2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFFFFC229),
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: msg.isUser ? const Color(0xFFFFC229) : const Color(0xFF0F1B35),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: msg.isUser ? const Radius.circular(20) : Radius.zero,
                  bottomRight: msg.isUser ? Radius.zero : const Radius.circular(20),
                ),
                border: msg.isUser
                    ? null
                    : Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: msg.isUser ? Colors.black : Colors.white,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (msg.isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF161E2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white70,
                size: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
