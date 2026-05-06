import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final String senderName;
  final String itemTitle;
  final String message;
  final String time;
  final int unreadCount;
  final String? itemImageUrl;
  final VoidCallback? onDelete;

  const MessageTile({
    super.key,
    required this.senderName,
    required this.itemTitle,
    required this.message,
    required this.time,
    required this.unreadCount,
    this.itemImageUrl,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: itemImageUrl != null && itemImageUrl!.isNotEmpty
              ? Image.network(
                  itemImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
                )
              : const Icon(Icons.image, color: Colors.grey),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(senderName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
          Text(time, style: TextStyle(color: unreadCount > 0 ? const Color(0xFFB11A23) : Colors.grey, fontSize: 12, fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(itemTitle, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: unreadCount > 0 ? Colors.black87 : Colors.grey.shade600, fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Color(0xFFB11A23), shape: BoxShape.circle),
                  child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onSelected: (value) {
          if (value == 'delete' && onDelete != null) {
            onDelete!();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Remove Conversation', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
