import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

abstract class ChatRepository {
  Future<String> sendMessage(ChatMessage message);
  Future<List<ChatMessage>> getMessagesForBooking(String bookingId);
  Stream<List<ChatMessage>> getMessagesStreamForBooking(String bookingId);
  Future<void> markMessagesAsRead(String bookingId, String userId);
  Future<int> getUnreadMessageCount(String bookingId, String userId);
}

class FirebaseChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'chat_messages';

  @override
  Future<String> sendMessage(ChatMessage message) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(message.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getMessagesForBooking(String bookingId) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('bookingId', isEqualTo: bookingId)
          .orderBy('timestamp', descending: false)
          .get();

      return query.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Stream<List<ChatMessage>> getMessagesStreamForBooking(String bookingId) {
    return _firestore
        .collection(_collectionName)
        .where('bookingId', isEqualTo: bookingId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatMessage.fromFirestore(doc))
        .toList());
  }

  @override
  Future<void> markMessagesAsRead(String bookingId, String userId) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('bookingId', isEqualTo: bookingId)
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  @override
  Future<int> getUnreadMessageCount(String bookingId, String userId) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('bookingId', isEqualTo: bookingId)
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return query.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread message count: $e');
    }
  }
}