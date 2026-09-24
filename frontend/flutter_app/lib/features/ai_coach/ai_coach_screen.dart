import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String source; // "edge" or "cloud"
  final DateTime timestamp;
  final String? action;
  final String? actionLabel;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.source = "edge",
    DateTime? timestamp,
    this.action,
    this.actionLabel,
  }) : timestamp = timestamp ?? DateTime.now();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isSpeaking = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello Shivam! I'm your FitSync AI Coach. I process your real-time workout tracking locally on your device for absolute privacy, while connecting to cloud reasoning for advanced planning. How can I help you today?",
      isUser: false,
      source: "edge",
    ),
  ];

  final List<String> _suggestedPrompts = [
    "What workout should I do today?",
    "I slept only 5 hours.",
    "My knees hurt during squats.",
    "How much protein should I eat?",
    "Plan a 20-minute home workout.",
    "What should I eat after this workout?",
  ];

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate Edge or Cloud AI response
    await Future.delayed(const Duration(milliseconds: 900));

    String reply = "";
    String source = "edge";
    String? action;
    String? actionLabel;

    final lower = text.toLowerCase();
    if (lower.contains("slept") || lower.contains("hours") || lower.contains("tired")) {
      reply = "Since you slept only 5 hours, your central nervous system needs active recovery. I've adjusted your plan: instead of high intensity, let's do a 20-minute mobility and light strength routine to prevent injury.";
      action = "START_WORKOUT";
      actionLabel = "Start 20-Min Mobility Routine";
      source = "cloud";
    } else if (lower.contains("knee") || lower.contains("hurt")) {
      reply = "Please halt deep squats immediately. Common causes are knees caving inward (valgus collapse) or shifting weight onto your toes. Let's switch to glute bridges and reverse lunges, and have the camera form tracker inspect your knee angle.";
      source = "edge";
    } else if (lower.contains("protein")) {
      reply = "Based on your 70kg weight and muscle gain goal, aim for 100g - 115g of protein daily. You can easily achieve this with 2 bowls of dal, 100g paneer, curd, and roasted chana.";
      source = "cloud";
    } else if (lower.contains("start") || lower.contains("today")) {
      reply = "Your recovery is moderate (72%) today. Let's do 4 sets of bodyweight squats, lunges, and pushups. Camera pose tracking will count your reps automatically.";
      action = "START_WORKOUT";
      actionLabel = "Launch Workout Camera";
      source = "edge";
    } else {
      reply = "I'm tracking your progress! Focus on slow, controlled eccentric reps (3 seconds down, 1 second up). That will optimize hypertrophy without joint strain.";
      source = "edge";
    }

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: reply,
        isUser: false,
        source: source,
        action: action,
        actionLabel: actionLabel,
      ));
    });
    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.psychology_rounded, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("AI Fitness Coach", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Hybrid Edge + Cloud", style: TextStyle(fontSize: 11, color: Colors.green)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isSpeaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded),
            tooltip: _isSpeaking ? "Stop voice playback" : "Voice playback ready",
            onPressed: () => setState(() => _isSpeaking = !_isSpeaking),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: "Clear Conversation",
            onPressed: () => setState(() => _messages.clear()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Suggested Prompts Horizontal Bar
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _suggestedPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final prompt = _suggestedPrompts[idx];
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () => _sendMessage(prompt),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Message Stream
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                return _buildMessageBubble(theme, msg);
              },
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 10),
                  Text("Coach is adapting your response...", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),

          // Input Bar with Mic & Send
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mic_rounded, color: Colors.blue),
                  tooltip: "Hands-Free Voice Query",
                  onPressed: () => _sendMessage("Start today's workout."),
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Ask anything about training or nutrition...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.arrow_upward_rounded),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ThemeData theme, ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: msg.isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant.withOpacity(0.6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            if (msg.action != null) ...[
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () => context.push('/workout'),
                icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                label: Text(msg.actionLabel ?? "Execute Action"),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!msg.isUser) ...[
                  Icon(
                    msg.source == "edge" ? Icons.phone_android_rounded : Icons.cloud_done_rounded,
                    size: 11,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    msg.source == "edge" ? "Edge AI (Private)" : "Cloud Gemini",
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

