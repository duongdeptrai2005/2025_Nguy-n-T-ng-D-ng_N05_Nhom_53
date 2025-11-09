import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_detail_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐️ SỬA: Bỏ dấu '_'
    final auth = FirebaseAuth.instance;
    final String? currentUserId = auth.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Thông báo")),
        body: const Center(child: Text("Vui lòng đăng nhập để xem thông báo.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Thông báo"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          // ... (code xử lý loading, error, empty giữ nguyên)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text("Có lỗi xảy ra khi tải thông báo."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60,
                      color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Bạn chưa có thông báo nào."),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              final bool isRead = data['read'] ?? false;

              return _buildNotificationTile(context, doc.id, data, isRead);
            },
          );
        },
      ),
    );
  }

  // Widget con để hiển thị từng thông báo
  Widget _buildNotificationTile(BuildContext context, String docId,
      Map<String, dynamic> data, bool isRead) {
    final theme = Theme.of(context);

    // ... (code lấy title, body, type, timestamp giữ nguyên)
    final String title = data['title'] ?? 'Thông báo';
    final String body = data['body'] ?? 'Bạn có thông báo mới.';
    final String type = data['type'] ?? '';
    final Timestamp? timestamp = data['createdAt'] as Timestamp?;
    String timeAgo = "Vừa xong";
    if (timestamp != null) {
      final difference = DateTime.now().difference(timestamp.toDate().toLocal());
      if (difference.inDays > 1) {
        timeAgo = "${difference.inDays} ngày trước";
      } else if (difference.inHours > 0) {
        timeAgo = "${difference.inHours} giờ trước";
      } else if (difference.inMinutes > 0) {
        timeAgo = "${difference.inMinutes} phút trước";
      }
    }

    // ... (code switch/case icon giữ nguyên)
    IconData iconData;
    Color iconColor;
    switch (type) {
      case 'CLUB_EVENT':
        iconData = Icons.event_note_rounded;
        iconColor = theme.colorScheme.primary;
        break;
      case 'BOOK_DUE':
        iconData = Icons.timer_off_outlined;
        iconColor = theme.colorScheme.error;
        break;
      case 'BOOK_BORROW':
        iconData = Icons.book_outlined;
        iconColor = Colors.green;
        break;
      case 'BOOK_RETURN':
        iconData = Icons.check_circle_outline;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.notifications_none_outlined;
        iconColor = Colors.orange;
    }

    return Card(
      elevation: isRead ? 0.5 : 2.0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        // ⭐️ SỬA: Thay thế withOpacity
        tileColor: isRead ? Colors.white : theme.colorScheme.primary
            .withAlpha((255 * 0.04).round()), // ~0.04 opacity
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          // ⭐️ SỬA: Thay thế withOpacity
          backgroundColor: iconColor.withAlpha((255 * 0.1).round()), // ~0.1 opacity
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        title: Text(title, style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold
        )),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(body),
        ),
        trailing: Text(
            timeAgo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        onTap: () {
          _markAsRead(docId);
          _handleNotificationTap(context, data);
        },
      ),
    );
  }

  // Hàm đánh dấu đã đọc
  void _markAsRead(String docId) {
    FirebaseFirestore.instance.collection('notifications').doc(docId).update({
      'read': true,
    });
  }

  // Hàm xử lý khi nhấn vào thông báo
  void _handleNotificationTap(BuildContext context, Map<String, dynamic> data) {
    final String type = data['type'] ?? '';

    if (type == 'CLUB_EVENT') {
      final Map<String, dynamic> notificationData = data['data'] ?? {};

      String? clubId = notificationData['clubId'];
      String? eventId = notificationData['eventId'];

      // ⭐️ SỬA: Dùng '??=' để thay thế 'if'
      clubId ??= data['clubId'];
      eventId ??= data['eventId'];

      if (clubId != null && eventId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EventDetailScreen(
                  // ⭐️ SỬA: Thêm '!' để khẳng định không null
                  clubId: clubId!,
                  eventId: eventId!,
                ),
          ),
        );
      }
    }
  }
}