import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageMembersScreen extends StatelessWidget {
  final String clubId;

  const ManageMembersScreen({required this.clubId, super.key});

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;
    final String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý Thành viên")),
      // 1. Lắng nghe thay đổi của CLB (để cập nhật danh sách members)
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('book_clubs').doc(clubId).snapshots(),
        builder: (context, clubSnapshot) {
          if (!clubSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clubData = clubSnapshot.data!.data() as Map<String, dynamic>;
          final members = List<String>.from(clubData['members'] ?? []);
          final roles = Map<String, dynamic>.from(clubData['roleByUser'] ?? {});

          if (members.isEmpty) {
            return const Center(child: Text("Câu lạc bộ chưa có thành viên."));
          }

          // 2. Lấy thông tin chi tiết của các thành viên
          return StreamBuilder<QuerySnapshot>(
            // 'whereIn' sẽ lấy tất cả user có ID nằm trong danh sách 'members'
            stream: _firestore
                .collection('users')
                .where(FieldPath.documentId, whereIn: members)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final userDocs = userSnapshot.data!.docs;

              return ListView.builder(
                itemCount: userDocs.length,
                itemBuilder: (context, index) {
                  final userDoc = userDocs[index];
                  final userData = userDoc.data() as Map<String, dynamic>;
                  final memberUid = userDoc.id;

                  final String name = userData['name'] ?? 'Người dùng';
                  final String email = userData['email'] ?? 'Không có email';
                  final String role = roles[memberUid] ?? 'Thành viên';

                  // Không cho phép admin tự xóa mình
                  final bool isCurrentUser = (memberUid == currentUserId);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(name.substring(0, 1).toUpperCase()),
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email),
                          if (role == "Quản trị viên")
                            Text(
                              "Quản trị viên",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                        ],
                      ),
                      isThreeLine: true,
                      // Nút xóa (chỉ hiển thị nếu đó không phải là chính mình)
                      trailing: isCurrentUser
                          ? const Text("Bạn", style: TextStyle(fontWeight: FontWeight.w500))
                          : IconButton(
                        icon: Icon(Icons.remove_circle_outline,
                            color: Theme.of(context).colorScheme.error),
                        onPressed: () {
                          _removeMember(context, clubId, memberUid, name);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Hàm xóa thành viên
  Future<void> _removeMember(BuildContext context, String clubId, String uidToRemove, String name) async {
    // Hiển thị dialog xác nhận
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa $name ra khỏi câu lạc bộ?"),
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
        await FirebaseFirestore.instance.collection('book_clubs').doc(clubId).update({
          // Xóa UID khỏi mảng 'members'
          'members': FieldValue.arrayRemove([uidToRemove]),
          // Xóa vai trò của họ khỏi map 'roleByUser'
          'roleByUser.$uidToRemove': FieldValue.delete(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã xóa $name khỏi CLB.")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi xóa thành viên: $e")),
        );
      }
    }
  }
}