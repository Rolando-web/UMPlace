import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Get or create a chat room between two users for a specific listing
  Future<String> getOrCreateChatRoom(String otherUserId, String otherUserName, Map<String, dynamic> listingInfo, String listingId) async {
    final List<String> participants = [currentUserId, otherUserId]..sort();
    final String chatRoomId = '${participants.join('_')}_$listingId';

    final roomDoc = await _firestore.collection('chat_rooms').doc(chatRoomId).get();

    if (!roomDoc.exists) {
      await _firestore.collection('chat_rooms').doc(chatRoomId).set({
        'participants': participants,
        'participantNames': {
          currentUserId: _auth.currentUser?.displayName ?? 'User',
          otherUserId: otherUserName,
        },
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'listingInfo': listingInfo,
        'listingId': listingId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update listing info and ensure both names are updated/present
      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'listingInfo': listingInfo,
        'listingId': listingId,
        'participantNames.$otherUserId': otherUserName,
        'participantNames.$currentUserId': _auth.currentUser?.displayName ?? 'User',
      });
    }

    return chatRoomId;
  }

  // Send a message
  Future<void> sendMessage(String chatRoomId, String receiverId, String text) async {
    if (text.trim().isEmpty) return;

    final messageData = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    // Add message to sub-collection
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);

    // Update last message in room
    await _firestore.collection('chat_rooms').doc(chatRoomId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // Stream messages for a chat room
  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  // Stream chat rooms for current user
  Stream<List<ChatRoom>> getChatRooms() {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
          final rooms = snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList();
          // Sort manually by lastMessageTime descending
          rooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
          return rooms;
        });
  }

  // Delete a chat room
  Future<void> deleteChatRoom(String chatRoomId) async {
    // Delete messages sub-collection first (Firebase doesn't do this automatically if you delete parent doc via client SDK)
    final messages = await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').get();
    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete the room doc
    batch.delete(_firestore.collection('chat_rooms').doc(chatRoomId));
    
    await batch.commit();
  }
}
