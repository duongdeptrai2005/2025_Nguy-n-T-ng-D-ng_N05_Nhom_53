import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart'; // Nếu bạn muốn format ngày giờ đẹp hơn

class EventDetailScreen extends StatelessWidget {
  final String clubId;
  final String eventId;

  const EventDetailScreen({
    required this.clubId,
    required this.eventId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết sự kiện")),
      body: StreamBuilder<DocumentSnapshot>(
        // Truy vấn đến đúng tài liệu sự kiện
        stream: FirebaseFirestore.instance
            .collection('book_clubs')
            .doc(clubId)
            .collection('events')
            .doc(eventId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Có lỗi xảy ra khi tải sự kiện."));
          }
          if (!snapshot.data!.exists) {
            return const Center(child: Text("Không tìm thấy sự kiện."));
          }

          final eventData = snapshot.data!.data() as Map<String, dynamic>;

          // Lấy dữ liệu
          final title = eventData['title'] ?? 'Không có tiêu đề';
          final description = eventData['description'] ?? 'Không có mô tả';
          final timestamp = eventData['createdAt'] as Timestamp?;

          // Lấy số lượng giới hạn (có thể là null)
          final limit = eventData['participantLimit'] as int?;

          // Format ngày giờ
          String formattedDate = "Chưa có thông tin";
          if (timestamp != null) {
            // Ví dụ: dùng intl:
            // formattedDate = DateFormat('EEEE, dd/MM/yyyy - HH:mm', 'vi_VN')
            //     .format(timestamp.toDate().toLocal());

            // Cách đơn giản không cần package 'intl':
            formattedDate = timestamp.toDate().toLocal().toString().substring(0, 16);
          }

          // Hiển thị số lượng
          String limitText = limit?.toString() ?? "Không giới hạn";

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. Tên sự kiện
              Text(
                title,
                style: textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // 2. Thời gian
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary),
                title: Text("Thời gian tạo", style: textTheme.titleMedium),
                subtitle: Text(formattedDate, style: textTheme.bodyLarge),
              ),

              // 3. Số lượng giới hạn
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.people_alt_rounded, color: theme.colorScheme.secondary),
                title: Text("Giới hạn tham gia", style: textTheme.titleMedium),
                subtitle: Text(limitText, style: textTheme.bodyLarge),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),

              // 4. Mô tả
              Text(
                "Mô tả chi tiết",
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: textTheme.bodyLarge?.copyWith(height: 1.5), // Tăng giãn dòng
              ),
            ],
          );
        },
      ),
    );
  }
}