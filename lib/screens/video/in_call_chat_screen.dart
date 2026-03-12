import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:realtimekit_core/realtimekit_core.dart';
import '../../utils/app_colors.dart';

class InCallChatScreen extends StatefulWidget {
  final RealtimekitClient? meeting;
  final String? doctorName;

  const InCallChatScreen({super.key, this.meeting, this.doctorName});

  @override
  State<InCallChatScreen> createState() => _InCallChatScreenState();
}

class _InCallChatScreenState extends State<InCallChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late final RtkChatEventListener _chatListener;

  @override
  void initState() {
    super.initState();

    _chatListener = _InCallChatEventListener(
      onLatest: (messages) {
        setState(() {
          _messages
            ..clear()
            ..addAll(messages);
        });
      },
      onNew: (message) {
        setState(() {
          _messages.add(message);
        });
      },
    );

    if (widget.meeting != null) {
      widget.meeting!.addChatEventListener(_chatListener);
      final existing = widget.meeting!.chat.messages;
      if (existing.isNotEmpty) {
        _messages.addAll(existing);
      }
    }
  }

  @override
  void dispose() {
    if (widget.meeting != null) {
      widget.meeting!.removeChatEventListener(_chatListener);
    }
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || widget.meeting == null) return;

    try {
      widget.meeting!.chat.sendTextMessage(text);
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send chat message: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = widget.doctorName ?? 'Dr. Sarah Johnson';
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                doctorName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'In call - Chat',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 16,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                    onPressed: () {
                      // Handle attachment (image/file)
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Material(
                    color: AppColors.primaryColor,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _sendMessage,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isOwn =
        widget.meeting != null &&
        message.userId == widget.meeting!.localUser.userId;

    String messageText;
    if (message is TextMessage) {
      messageText = message.message;
    } else if (message is ImageMessage) {
      messageText = '📷 Image: ${message.link}';
    } else if (message is FileMessage) {
      messageText = '📎 File: ${message.name}';
    } else {
      messageText = message.toString();
    }

    final timestamp = message.time.isNotEmpty ? message.time : 'Now';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isOwn
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isOwn
                  ? AppColors.primaryColor
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              messageText,
              style: TextStyle(
                color: isOwn ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: isOwn ? 0 : 8, right: isOwn ? 8 : 0),
            child: Text(
              timestamp,
              style: TextStyle(
                color: isOwn
                    ? Colors.grey[600]
                    : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InCallChatEventListener extends RtkChatEventListener {
  final void Function(List<ChatMessage>) onLatest;
  final void Function(ChatMessage) onNew;

  _InCallChatEventListener({required this.onLatest, required this.onNew});

  @override
  void onChatUpdates(List<ChatMessage> messages) {
    onLatest(messages);
  }

  @override
  void onNewChatMessage(ChatMessage message) {
    onNew(message);
  }
}
