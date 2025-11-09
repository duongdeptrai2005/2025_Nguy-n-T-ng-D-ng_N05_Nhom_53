import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final _firestore = FirebaseFirestore.instance;

  /// ⭐️ Hàm tạo thông báo khi MƯỢN SÁCH
  static Future<void> createBorrowNotification({
    required String userId,
    required String bookTitle,
    required String bookId,
    String? borrowId, // ID của lần mượn, nếu có
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'title': 'Mượn sách thành công',
        'body': 'Bạn đã mượn thành công sách "$bookTitle".',
        'type': 'BOOK_BORROW',
        'data': {
          'bookId': bookId,
          if (borrowId != null) 'borrowId': borrowId,
        }
      });
    } catch (e) {
      debugPrint("Lỗi khi tạo thông báo mượn sách: $e");
    }
  }

  /// ⭐️ Hàm tạo thông báo khi TRẢ SÁCH
  static Future<void> createReturnNotification({
    required String userId,
    required String bookTitle,
    required String bookId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'title': 'Trả sách thành công',
        'body': 'Bạn đã trả thành công sách "$bookTitle".',
        'type': 'BOOK_RETURN',
        'data': {
          'bookId': bookId,
        }
      });
    } catch (e) {
      debugPrint("Lỗi khi tạo thông báo trả sách: $e");
    }
  }

// Bạn cũng có thể di chuyển hàm tạo thông báo sự kiện CLB vào đây
// static Future<void> createClubEventNotification(...) { ... }
}