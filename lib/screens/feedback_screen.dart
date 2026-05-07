import 'package:flutter/material.dart';
import '../src/theme/design_system.dart';
// shared not used here

enum FeedbackType { general, bug, feature }

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  FeedbackType _type = FeedbackType.general;
  int _rating = 0;
  final _feedbackCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _category;
  bool _submitting = false;

  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  Map<FeedbackType, List<String>> get _categories => {
    FeedbackType.general: ['Other', 'UX', 'Content'],
    FeedbackType.bug: ['App crash', 'UI issue', 'Login issue'],
    FeedbackType.feature: ['UI improvement', 'New feature', 'Integration'],
  };

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    _emailCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  String get _ratingLabel {
    if (_rating >= 5) return 'Awesome!';
    if (_rating >= 4) return 'Great';
    if (_rating >= 3) return 'Good';
    if (_rating >= 2) return 'Could be better';
    if (_rating == 1) return 'Needs improvement';
    return '';
  }

  void _setType(FeedbackType t) {
    setState(() {
      _type = t;
      _category = null;
    });
  }

  void _submit() async {
    if ((_feedbackCtrl.text.trim().isEmpty && _rating == 0) || _submitting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add feedback or a rating')),
      );
      return;
    }
    setState(() => _submitting = true);
    // Simulate network
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _submitting = false);
    _animCtrl.forward(from: 0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 72,
                    color: GatherColors.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Thank you for your feedback!',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).maybePop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GatherColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeSelector() {
    Widget pill(String label, FeedbackType t, IconData icon) {
      final selected = _type == t;
      return GestureDetector(
        onTap: () => _setType(t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF6B4A2A), Color(0xFFD4AF37)],
                  )
                : null,
            color: selected ? null : const Color(0xFF141416),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected ? Colors.transparent : Colors.white12,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        pill('General', FeedbackType.general, Icons.star_border),
        pill('Report a Bug', FeedbackType.bug, Icons.bug_report_outlined),
        pill('Suggest Feature', FeedbackType.feature, Icons.lightbulb_outline),
      ],
    );
  }

  Widget _buildStars() {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < _rating;
        return GestureDetector(
          onTap: () => setState(() => _rating = i + 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.only(right: 8),
            child: Icon(
              Icons.star,
              size: 36,
              color: filled ? const Color(0xFFD4AF37) : Colors.white12,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catOptions = _categories[_type]!;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Feedback'),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Help us improve GatherUni',
              style: TextStyle(
                color: GatherColors.withOpacity(Colors.white, .6),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          // outer card
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F1113),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: GatherColors.withOpacity(Colors.black, .6),
                  blurRadius: 8,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // type selector
                _buildTypeSelector(),
                const SizedBox(height: 18),
                const Text(
                  'How was your experience?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStars(),
                const SizedBox(height: 8),
                if (_rating > 0)
                  Text(
                    _ratingLabel,
                    style: const TextStyle(color: Colors.white70),
                  ),
                const SizedBox(height: 16),
                // feedback input card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141416),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _feedbackCtrl,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          'Tell us what you liked or what we can improve…',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // attachments + category + email
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Attachment picker not implemented in preview',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_a_photo,
                        color: Colors.white70,
                      ),
                      label: const Text(
                        'Add Screenshot',
                        style: TextStyle(color: Colors.white70),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _category,
                        items: catOptions
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _category = v),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          filled: true,
                          fillColor: Color(0xFF0F1113),
                        ),
                        dropdownColor: const Color(0xFF0F1113),
                        style: const TextStyle(color: Colors.white),
                        hint: const Text(
                          'Category',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Email (optional)',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your feedback is सुरक्षित and used only for improvements',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B4A2A), Color(0xFFD4AF37)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        height: 48,
                        child: _submitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Submit Feedback',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
