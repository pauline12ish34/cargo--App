import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/models/chat_model.dart';
import '../../../providers/auth_provider.dart';
import 'chat_provider.dart';
import 'package:cargo_app/constants.dart';

class ChatScreen extends StatefulWidget {
  final BookingModel booking;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.booking,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  bool _shouldScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _initializeChat() {
    if (_isInitialized) return; // Prevent multiple initializations

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.user != null) {
      chatProvider.loadMessages(widget.booking.id);
      chatProvider.markMessagesAsRead(widget.booking.id, authProvider.user!.uid);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.user != null) {
      final success = await chatProvider.sendMessage(
        bookingId: widget.booking.id,
        senderId: authProvider.user!.uid,
        senderName: authProvider.user!.name,
        content: _messageController.text.trim(),
      );

      if (success) {
        _messageController.clear();
        _shouldScrollToBottom = true; // Set flag instead of immediate scroll
      }
    }
  }

  void _scrollToBottom() {
    if (!_shouldScrollToBottom) return; // Only scroll when needed

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) { // Check if widget is still mounted
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        _shouldScrollToBottom = false; // Reset flag
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( // Add this to control back button behavior
      onWillPop: () async {
        // Clean up any ongoing operations before popping
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        // Add any cleanup logic here if needed
        return true; // Allow pop
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.otherUserName),
              Text(
                widget.booking.cargoDescription,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _showJobDetails();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Job Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: _getStatusColor().withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 16,
                    color: _getStatusColor(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Job Status: ${widget.booking.statusDisplayName}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  return StreamBuilder<List<ChatMessage>>(
                    stream: chatProvider.streamMessages(widget.booking.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !_isInitialized) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Start the conversation!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Only auto-scroll when flag is set
                      if (_shouldScrollToBottom) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return _MessageBubble(
                            message: message,
                            isMe: message.senderId == Provider.of<AuthProvider>(context, listen: false).user?.uid,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Message Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, child) {
                      return CircleAvatar(
                        backgroundColor: primaryGreen,
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: chatProvider.isLoading ? null : _sendMessage,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.booking.status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
      case BookingStatus.inProgress:
        return primaryGreen;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.declined:
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.booking.status) {
      case BookingStatus.pending:
        return Icons.pending;
      case BookingStatus.accepted:
        return Icons.check_circle;
      case BookingStatus.inProgress:
        return Icons.local_shipping;
      case BookingStatus.completed:
        return Icons.check_circle_outline;
      case BookingStatus.declined:
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  void _showJobDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Add this for better modal behavior
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Job Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.inventory,
              label: 'Cargo',
              value: widget.booking.cargoDescription,
            ),
            _DetailRow(
              icon: Icons.location_on,
              label: 'Pickup',
              value: widget.booking.pickupLocation,
            ),
            _DetailRow(
              icon: Icons.flag,
              label: 'Dropoff',
              value: widget.booking.dropoffLocation,
            ),
            _DetailRow(
              icon: Icons.local_shipping,
              label: 'Vehicle Type',
              value: widget.booking.vehicleTypeDisplayName,
            ),
            if (widget.booking.weight != null)
              _DetailRow(
                icon: Icons.scale,
                label: 'Weight',
                value: '${widget.booking.weight}kg',
              ),
            if (widget.booking.estimatedPrice != null)
              _DetailRow(
                icon: Icons.money,
                label: 'Estimated Price',
                value: '${widget.booking.estimatedPrice!.toStringAsFixed(0)} RWF',
              ),
            if (widget.booking.specialInstructions?.isNotEmpty == true)
              _DetailRow(
                icon: Icons.note,
                label: 'Special Instructions',
                value: widget.booking.specialInstructions!,
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.system) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: primaryGreen,
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: isMe ? primaryGreen : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 16,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : 'M',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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