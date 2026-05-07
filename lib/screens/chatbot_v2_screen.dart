import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatbotV2Screen extends StatefulWidget {
  const ChatbotV2Screen({super.key, required this.chatService});

  final ChatService chatService;

  @override
  State<ChatbotV2Screen> createState() => _ChatbotV2ScreenState();
}

class _ChatbotV2ScreenState extends State<ChatbotV2Screen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_Msg> _messages = [];
  bool _sending = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, fromUser: true));
      _controller.clear();
      _sending = true;
    });
    _scrollToBottom();

    try {
      final reply = await widget.chatService.sendMessage(
        text,
        includeEvents: false,
      );
      if (mounted) {
        setState(() {
          _messages.add(
            _Msg(text: reply.isEmpty ? 'No response' : reply, fromUser: false),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_Msg(text: 'Error: ${e.toString()}', fromUser: false));
        });
      }
    }

    if (mounted) {
      setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot (v2)')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (ctx, i) {
                  final m = _messages[i];
                  return Align(
                    alignment: m.fromUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: m.fromUser ? Colors.blue : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        m.text,
                        style: TextStyle(
                          color: m.fromUser ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_sending)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Thinking...',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask about events...',
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _send),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  _Msg({required this.text, required this.fromUser});
  final String text;
  final bool fromUser;
}
