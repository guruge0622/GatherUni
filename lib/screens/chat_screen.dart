import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final ChatService _chatService = ChatService();
  bool _isTyping = false;

  late final AnimationController _dotsController;
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestions = [
    'Tech events this week',
    'Today events',
    'Free events near me',
  ];

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
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

  Future<void> sendMessage([String? preset]) async {
    final text = (preset ?? controller.text).trim();
    if (text.isEmpty) return;
    controller.clear();

    setState(() {
      messages.add({"role": "user", "text": text});
      _isTyping = true;
    });
    _scrollToEnd();

    try {
      final reply = await _chatService.sendMessage(text, includeEvents: true);
      setState(() {
        messages.add({"role": "bot", "text": reply});
      });
      _scrollToEnd();
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "text": 'Error: ${e.toString()}'});
      });
      _scrollToEnd();
    } finally {
      setState(() => _isTyping = false);
    }
  }

  double _dotOpacity(int index, double t) {
    // phase-shifted sine for three dots
    final phase = index * 0.2;
    final value = (math.sin((t + phase) * 2 * math.pi) + 1) / 2;
    return 0.3 + (value * 0.7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Column(
        children: [
          // Quick suggestion chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _suggestions.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(s),
                      onPressed: () => sendMessage(s),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              children: messages.map((msg) {
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Typing dots
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: AnimatedBuilder(
                animation: _dotsController,
                builder: (context, child) {
                  final t = _dotsController.value;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      return Opacity(
                        opacity: _dotOpacity(i, t),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

          // Input
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask about events...',
                      contentPadding: EdgeInsets.all(12),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
