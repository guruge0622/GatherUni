import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final ChatService _chatService = ChatService();
  bool _isTyping = false;

  void sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    controller.clear();

    setState(() {
      messages.add({"role": "user", "text": text});
      _isTyping = true;
    });

    try {
      final reply = await _chatService.sendMessage(text, includeEvents: true);
      setState(() {
        messages.add({"role": "bot", "text": reply});
      });
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "text": 'Error: ${e.toString()}'});
      });
    } finally {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Assistant")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: messages.map((msg) {
                final isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: const [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 8),
                  Text('AI is typing...'),
                ],
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
                      hintText: "Ask about events...",
                      contentPadding: EdgeInsets.all(12),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
