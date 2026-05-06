import 'package:flutter/material.dart';
import '../../../services/chat_service.dart';
import '../../../models/chat.dart';
import '../widgets/messages_widgets.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB11A23), // UM Maroon
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/LOGO.png', width: 32, height: 32, errorBuilder: (c,e,s) => const Icon(Icons.school, color: Colors.white)),
            const SizedBox(width: 8),
            const Text('Messages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: chatService.getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.data ?? [];

          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No conversations yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Messages from sellers will appear here.', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final room = rooms[index];
              
              // Find the other participant
              final otherUserId = room.participants.firstWhere(
                (uid) => uid != chatService.currentUserId,
                orElse: () => '',
              );
              
              final otherUserName = room.participantNames[otherUserId] ?? 'User';

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatRoomId: room.id,
                        receiverId: otherUserId,
                        receiverName: otherUserName,
                        listingInfo: room.listingInfo,
                      ),
                    ),
                  );
                },
                child: MessageTile(
                  senderName: otherUserName,
                  itemTitle: room.listingInfo?['title'] ?? 'Listing',
                  itemImageUrl: room.listingInfo?['imageUrl'],
                  message: room.lastMessage.isNotEmpty ? room.lastMessage : 'Start chatting...',
                  time: _formatTime(room.lastMessageTime),
                  unreadCount: 0, // Implement unread logic later if needed
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remove Conversation'),
                        content: const Text('Are you sure you want to remove this conversation? All messages will be deleted.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true), 
                            child: const Text('Remove', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await chatService.deleteChatRoom(room.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Conversation removed')),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
