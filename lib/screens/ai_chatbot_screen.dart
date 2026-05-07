import 'package:flutter/material.dart';
import 'dart:async';
import '../src/shared.dart';
import '../src/theme/design_system.dart';
import 'event_detail_screen.dart';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final _messageCtrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        text: 'Hi — I\'m your event assistant. Ask me about events.',
        fromUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _simulateAIResponse(String userText) async {
    setState(() => _typing = true);
    _scrollToBottom();
    await Future.delayed(const Duration(milliseconds: 900));
    // Example: if user asks for tech, show smart card(s)
    if (userText.toLowerCase().contains('tech')) {
      setState(() {
        _messages.add(
          _ChatMessage(text: 'Here are trending tech events:', fromUser: false),
        );
        _messages.add(_ChatMessage.smartCard(event: sampleEvents[0]));
      });
    } else {
      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                'Try ${sampleEvents.first.title} — it\'s on ${sampleEvents.first.date}.',
            fromUser: false,
          ),
        );
      });
    }
    setState(() => _typing = false);
    _scrollToBottom();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), fromUser: true));
      _messageCtrl.clear();
    });
    _scrollToBottom();
    _simulateAIResponse(text);
  }

  Widget _buildQuickChips() {
    final chips = [
      'Find events today',
      'Academic events',
      'Fun events',
      'Nearby events',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: chips
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  label: Text(c),
                  onPressed: () => _sendMessage(c),
                  backgroundColor: Colors.white10,
                  labelStyle: const TextStyle(color: Colors.white),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GatherColors.withOpacity(Colors.white, .04),
            GatherColors.withOpacity(Colors.white, .02),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: GatherColors.withOpacity(Colors.black, .4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white),
          ),
          Expanded(
            child: TextField(
              controller: _messageCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Ask me about events',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mic, color: Colors.white),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: () => _sendMessage(_messageCtrl.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: GatherColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.w800)),
            SizedBox(height: 2),
            Text('Ask me about events', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                itemCount: _messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: _typing
                          ? Row(
                              children: const [
                                SizedBox(width: 12),
                                _TypingIndicator(),
                              ],
                            )
                          : const SizedBox.shrink(),
                    );
                  }
                  final m = _messages[index];
                  if (m.isCard && m.event != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _SmartEventCard(
                        event: m.event!,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(event: m.event!),
                          ),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Align(
                      alignment: m.fromUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!m.fromUser) ...[
                            Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Colors.purple, Colors.blue],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: GatherColors.withOpacity(
                                      Colors.blue,
                                      .3,
                                    ),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.smart_toy,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                          Container(
                            constraints: const BoxConstraints(maxWidth: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: m.fromUser
                                  ? LinearGradient(
                                      colors: [
                                        Color(0xFF6B4A2A),
                                        Color(0xFFD4AF37),
                                      ],
                                    )
                                  : null,
                              color: m.fromUser
                                  ? null
                                  : const Color(0xFF151618),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(
                                  m.fromUser ? 16 : 4,
                                ),
                                bottomRight: Radius.circular(
                                  m.fromUser ? 4 : 16,
                                ),
                              ),
                              boxShadow: [
                                if (!m.fromUser)
                                  BoxShadow(
                                    color: GatherColors.withOpacity(
                                      Colors.white,
                                      .02,
                                    ),
                                    blurRadius: 8,
                                  ),
                              ],
                            ),
                            child: Text(
                              m.text,
                              style: TextStyle(
                                color: m.fromUser
                                    ? Colors.white
                                    : Colors.white70,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // quick chips
            Container(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
              child: _buildQuickChips(),
            ),
            // input area
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: _buildInputBar(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  _ChatMessage({required this.text, required this.fromUser})
    : event = null,
      isCard = false;

  _ChatMessage.smartCard({required this.event})
    : text = '',
      fromUser = false,
      isCard = true;

  final String text;
  final bool fromUser;
  final Event? event;
  final bool isCard;
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF151618),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _Dot(),
          SizedBox(width: 6),
          _Dot(delay: 120),
          SizedBox(width: 6),
          _Dot(delay: 240),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({this.delay = 0});
  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 0.6,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white54,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SmartEventCard extends StatelessWidget {
  const _SmartEventCard({required this.event, this.onTap});
  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF121316),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: event.colors),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${event.date} • ${event.time}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: GatherColors.primary,
              ),
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }
}
