import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/bottom_nav.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  // ======================= HÀM HIỂN THỊ DIALOG THÊM/SỬA =======================
  void _showUserDialog({DocumentSnapshot? user}) {
    final nameController = TextEditingController(text: user?['name'] ?? '');
    final emailController =
        TextEditingController(text: user?['email'] ?? user?['e-mail'] ?? '');
    final phoneController = TextEditingController(text: user?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? "Thêm người dùng" : "Sửa thông tin"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Tên người dùng"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                readOnly: user != null, // Không cho sửa email khi chỉnh
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Số điện thoại"),
                readOnly: user != null, // Không cho sửa sđt khi chỉnh
              ),
              const SizedBox(height: 10),
              TextField(
                enabled: false,
                decoration: const InputDecoration(
                  labelText: "Vai trò",
                  hintText: "user",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              final phone = phoneController.text.trim();

              if (name.isEmpty || email.isEmpty || phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
                );
                return;
              }

              try {
                // Nếu đang thêm mới, kiểm tra trùng
                if (user == null) {
                  // Kiểm tra trùng email hoặc số điện thoại
                  final existingUsers = await usersRef
                      .where('role', isEqualTo: 'user')
                      .get();

                  bool emailExists = existingUsers.docs.any((doc) =>
                      (doc['email'] ?? doc['e-mail'] ?? '').toString().toLowerCase() ==
                      email.toLowerCase());
                  bool phoneExists = existingUsers.docs.any((doc) =>
                      (doc['phone'] ?? '') == phone);

                  if (emailExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email đã tồn tại')),
                    );
                    return;
                  }

                  if (phoneExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Số điện thoại đã tồn tại')),
                    );
                    return;
                  }

                  // Thêm mới
                  await usersRef.add({
                    'name': name,
                    'email': email,
                    'phone': phone,
                    'role': 'user',
                    'created_at': Timestamp.now(),
                  });
                } else {
                  // Chỉ được phép sửa tên
                  await usersRef.doc(user.id).update({
                    'name': name,
                  });
                }

                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                debugPrint('🔥 Lỗi khi thêm/sửa người dùng: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            },
            child: Text(user == null ? "Thêm" : "Lưu"),
          ),
        ],
      ),
    );
  }

  // ======================= HÀM XÓA NGƯỜI DÙNG =======================
  void _deleteUser(DocumentSnapshot user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa ${user['name']} không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await usersRef.doc(user.id).delete();
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                debugPrint('🔥 Lỗi khi xóa người dùng: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi xóa: $e')),
                );
              }
            },
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  // ======================= GIAO DIỆN CHÍNH =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: const Text(
          "Quản lý người dùng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      // STREAMBUILDER NGHE DỮ LIỆU TỪ FIRESTORE (CHỈ LẤY role=user)
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef
            .where('role', isEqualTo: 'user')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('🔥 Lỗi stream: ${snapshot.error}');
            return Center(
              child: Text("Lỗi khi tải dữ liệu: ${snapshot.error}"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];
          debugPrint("📡 Số người dùng (role=user): ${users.length}");

          if (users.isEmpty) {
            return const Center(child: Text("Chưa có người dùng nào"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blueAccent),
                  title: Text(user['name'] ?? 'Không có tên'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${user['email'] ?? user['e-mail'] ?? ''}"),
                      Text("Điện thoại: ${user['phone'] ?? ''}"),
                      Text("Vai trò: ${user['role'] ?? ''}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showUserDialog(user: user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showUserDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: buildBottomNav(context, 3),
    );
  }
}
