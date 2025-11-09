import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'manage_members_screen.dart';
import 'event_detail_screen.dart';

class ClubDetailScreen extends StatelessWidget {
  final String clubId;
  const ClubDetailScreen({required this.clubId, super.key});

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết CLB")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('book_clubs').doc(clubId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Có lỗi xảy ra!"));
          }
          if (!snapshot.data!.exists) {
            return const Center(child: Text("Không tìm thấy CLB."));
          }

          final club = snapshot.data!;
          final members = List<String>.from(club['members'] ?? []);
          final uid = _auth.currentUser!.uid;
          final roleByUser = Map<String, dynamic>.from(club['roleByUser'] ?? {});
          final role = roleByUser[uid] ?? "Thành viên";
          final isAdmin = role == "Quản trị viên";

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // [ ... Phần thông tin CLB và thành viên ... ]
              // (Giữ nguyên phần CircleAvatar, Tên, Mô tả, ListTile Thành viên, ListTile Vai trò)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.group,
                    size: 50,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Text(
                club['name'],
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  club['description'],
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.people_outline_rounded,
                    color: theme.colorScheme.primary),
                title: Text("Thành viên", style: textTheme.titleMedium),
                trailing: Text(
                  "${members.length}",
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person_pin_rounded,
                    color: theme.colorScheme.secondary),
                title: Text("Vai trò của bạn", style: textTheme.titleMedium),
                trailing: Text(
                  role,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Divider(height: 1),
              ),

              // ⭐️ CẬP NHẬT: Khu vực Admin
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bảng điều khiển Quản trị",
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),

                      // ⭐️ MỚI: Dùng Wrap để các nút tự động xuống hàng
                      Wrap(
                        spacing: 12.0, // Khoảng cách ngang giữa các nút
                        runSpacing: 8.0, // Khoảng cách dọc khi xuống hàng
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              _editClubInfo(context, clubId, club);
                            },
                            label: const Text("Chỉnh sửa CLB"),
                          ),
                          FilledButton.icon(
                            icon: const Icon(Icons.add_task_rounded),
                            onPressed: () {
                              _createEvent(context, clubId, members);
                            },
                            label: const Text("Tạo sự kiện"),
                          ),

                          // ⭐️ MỚI: Nút Quản lý Thành viên
                          OutlinedButton.icon(
                            icon: const Icon(Icons.manage_accounts_rounded),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManageMembersScreen(
                                    clubId: clubId,
                                  ),
                                ),
                              );
                            },
                            label: const Text("Quản lý Thành viên"),
                            style: OutlinedButton.styleFrom(
                              // Làm cho nút này nổi bật hơn một chút
                              foregroundColor: theme.colorScheme.secondary,
                              side: BorderSide(color: theme.colorScheme.secondary),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              if (!isAdmin)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.exit_to_app_rounded, color: theme.colorScheme.error),
                    label: Text(
                      "Rời khỏi CLB",
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    onPressed: () {
                      // Gọi hàm mới tạo, truyền vào ID và tên CLB
                      _leaveClub(context, clubId, uid, club['name']);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5)),
                      // Nút này chiếm toàn bộ chiều rộng
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ),

              // [Phần "Sự kiện của CLB" StreamBuilder bên dưới vẫn giữ nguyên]
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Divider(height: 1),
              ),

              // ⭐️ MỚI: Đường kẻ phân cách
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Divider(height: 1),
              ),

              // ⭐️ MỚI: Tiêu đề cho danh sách sự kiện
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Sự kiện của CLB",
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),

              // ⭐️ MỚI: StreamBuilder để hiển thị danh sách sự kiện
              StreamBuilder<QuerySnapshot>(
                // Truy vấn subcollection 'events' và sắp xếp
                stream: _firestore
                    .collection('book_clubs')
                    .doc(clubId)
                    .collection('events')
                    .orderBy('createdAt', descending: true) // Mới nhất lên trên
                    .snapshots(),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!eventSnapshot.hasData ||
                      eventSnapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Chưa có sự kiện nào được tạo."),
                    );
                  }

                  // Dùng Column vì nó đã nằm trong ListView
                  return Column(
                    children: eventSnapshot.data!.docs.map((eventDoc) {
                      return _buildEventCard(
                          context, eventDoc, clubId, isAdmin);
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ⭐️ MỚI: Widget để hiển thị từng thẻ sự kiện
// [Bên trong class ClubDetailScreen]

  Widget _buildEventCard(BuildContext context, DocumentSnapshot eventDoc,
      String clubId, bool isAdmin) {
    final eventData = eventDoc.data() as Map<String, dynamic>;
    final title = eventData['title'] ?? 'Không có tiêu đề';
    final description = eventData['description'] ?? 'Không có mô tả';

    // ⭐️ MỚI: Bọc Card trong InkWell để có hiệu ứng gợn sóng khi nhấn
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      clipBehavior: Clip.antiAlias, // Để hiệu ứng gợn sóng không bị tràn
      child: InkWell(
        // ⭐️ MỚI: Thêm hành động onTap
        onTap: () {
          // (Hãy đảm bảo bạn đã import 'event_detail_screen.dart' nếu bạn tạo file riêng)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(
                clubId: clubId,
                eventId: eventDoc.id,
              ),
            ),
          );
        },
        child: ListTile(
          leading: Icon(Icons.event_note_rounded,
              color: Theme.of(context).colorScheme.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                maxLines: 1, // Chỉ hiển thị 1 dòng ở list
                overflow: TextOverflow.ellipsis, // Thêm ... nếu quá dài
              ),
            ],
          ),
          isThreeLine: false, // Giảm chiều cao lại
          trailing: isAdmin
              ? IconButton(
            icon: Icon(Icons.delete_outline,
                color: Theme.of(context).colorScheme.error),
            onPressed: () {
              _deleteEvent(context, clubId, eventDoc.id);
            },
          )
          // ⭐️ MỚI: Thêm icon điều hướng cho người dùng thường
              : const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }

  // ⭐️ MỚI: Hàm để xóa sự kiện (có xác nhận)
  void _deleteEvent(
      BuildContext context, String clubId, String eventId) async {
    // Hiển thị dialog xác nhận
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa sự kiện này không?"),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          FilledButton(
            child: const Text("Xóa"),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    // Nếu người dùng xác nhận "Xóa"
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('book_clubs')
            .doc(clubId)
            .collection('events')
            .doc(eventId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa sự kiện.")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi xóa sự kiện: $e")),
        );
      }
    }
  }

  void _editClubInfo(
      BuildContext context, String clubId, DocumentSnapshot club) {
    final nameCtrl = TextEditingController(text: club['name']);
    final descCtrl = TextEditingController(text: club['description']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Chỉnh sửa CLB"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Tên CLB")),
            TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Mô tả CLB")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('book_clubs')
                  .doc(clubId)
                  .update({
                'name': nameCtrl.text.trim(),
                'description': descCtrl.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

// [Bên trong class ClubDetailScreen]

// [Bên trong class ClubDetailScreen]

  void _createEvent(BuildContext context, String clubId, List<String> members) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final limitCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tạo sự kiện"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Tên sự kiện")),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Mô tả sự kiện")),
            TextField(
              controller: limitCtrl,
              decoration: const InputDecoration(labelText: "Giới hạn tham gia (bỏ trống nếu không)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              // ⭐️ Lấy thông tin sự kiện và CLB
              final eventTitle = titleCtrl.text.trim();
              final eventDesc = descCtrl.text.trim();
              final clubDoc = await FirebaseFirestore.instance.collection('book_clubs').doc(clubId).get();
              final clubName = clubDoc.data()?['name'] ?? 'CLB của bạn';

              int? participantLimit;
              if (limitCtrl.text.trim().isNotEmpty) {
                participantLimit = int.tryParse(limitCtrl.text.trim());
              }

              // Thêm sự kiện vào subcollection
              final eventRef = FirebaseFirestore.instance.collection('book_clubs').doc(clubId).collection('events');
              final newEvent = await eventRef.add({
                'title': eventTitle,
                'description': eventDesc,
                'createdAt': FieldValue.serverTimestamp(),
                'participantLimit': participantLimit,
              });

              // ⭐️ MỚI: Gửi thông báo đến tất cả thành viên
              await _sendNotificationsToMembers(
                members: members,
                clubName: clubName,
                eventTitle: eventTitle,
                clubId: clubId,
                eventId: newEvent.id, // ID của sự kiện vừa tạo
              );

              // Gửi email (vẫn giữ nếu bạn muốn)
              await _sendEventEmails(eventTitle, eventDesc, members);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Sự kiện đã tạo và thông báo đã gửi!")));
            },
            child: const Text("Tạo"),
          ),
        ],
      ),
    );
  }
  // [Bên trong class ClubDetailScreen]

// ⭐️ MỚI: Hàm để thành viên tự rời CLB
  Future<void> _leaveClub(BuildContext context, String clubId, String currentUserId, String clubName) async {

    // 1. Hiển thị dialog xác nhận
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận rời CLB"),
        content: Text("Bạn có chắc chắn muốn rời khỏi '$clubName'?\n\nBạn sẽ cần tham gia lại (nếu CLB cho phép) để xem lại nội dung."),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          FilledButton(
            child: const Text("Rời CLB"),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    // 2. Nếu người dùng không xác nhận, dừng lại
    if (confirm != true) return;

    // 3. Thực hiện cập nhật Firebase
    try {
      await FirebaseFirestore.instance.collection('book_clubs').doc(clubId).update({
        // Xóa UID khỏi mảng 'members'
        'members': FieldValue.arrayRemove([currentUserId]),
        // Xóa vai trò của họ khỏi map 'roleByUser'
        'roleByUser.$currentUserId': FieldValue.delete(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn đã rời khỏi $clubName.")),
      );

      // 4. QUAN TRỌNG: Đóng màn hình chi tiết CLB
      if (context.mounted) {
        Navigator.of(context).pop();
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi rời CLB: $e")),
      );
    }
  }

// ️ Hàm tạo thông báo trong app cho các thành viên
  Future<void> _sendNotificationsToMembers({
    required List<String> members,
    required String clubName,
    required String eventTitle,
    required String clubId,
    required String eventId,
  }) async {
    final _firestore = FirebaseFirestore.instance;
    // Dùng "batch" để gửi nhiều thông báo cùng lúc cho hiệu quả
    final batch = _firestore.batch();

    for (var uid in members) {
      // Tạo một document mới trong collection 'notifications'
      final notificationRef = _firestore.collection('notifications').doc();

      batch.set(notificationRef, {
        'userId': uid, // Thông báo này dành cho ai
        'title': 'Sự kiện mới: $clubName',
        'body': eventTitle,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'type': 'CLUB_EVENT',
        'clubId': clubId, // Để có thể điều hướng khi nhấn vào
        'eventId': eventId, // Để có thể điều hướng khi nhấn vào
      });
    }

    try {
      await batch.commit(); // Gửi tất cả thông báo
    } catch (e) {
      print("Lỗi khi tạo thông báo batch: $e");
    }
  }
  Future<void> _sendEventEmails(
      String title, String description, List<String> members) async {
    for (var uid in members) {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final email = userDoc['email'];
      print("Gửi email đến $email về sự kiện $title");
    }
  }
}