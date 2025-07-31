import 'package:flutter_test/flutter_test.dart';
import 'package:cargo_app/core/models/chat_model.dart';

void main() {
  group('ChatMessage', () {
    test('constructor creates correct instance', () {
      final message = ChatMessage(
        id: 'msg1',
        bookingId: 'b1',
        senderId: 'u1',
        senderName: 'Alice',
        content: 'Hello',
        type: MessageType.text,
        timestamp: DateTime(2024, 1, 1),
      );
      expect(message.id, 'msg1');
      expect(message.bookingId, 'b1');
      expect(message.senderId, 'u1');
      expect(message.senderName, 'Alice');
      expect(message.content, 'Hello');
      expect(message.type, MessageType.text);
      expect(message.timestamp, DateTime(2024, 1, 1));
      expect(message.isRead, false);
    });
  });
}
