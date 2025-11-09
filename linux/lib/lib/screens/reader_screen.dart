import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../data/app_data.dart'; // ✅ thêm dòng này

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  // Hàm thêm hoặc sửa độc giả
  void _showReaderDialog({Map<String, dynamic>? reader, int? index}) {
    final idController = TextEditingController(text: reader?['id'] ?? '');
    final nameController = TextEditingController(text: reader?['name'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reader == null ? "Thêm độc giả" : "Sửa thông tin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: "Mã độc giả"),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Tên độc giả"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              final id = idController.text.trim();
              final name = nameController.text.trim();

              if (id.isEmpty || name.isEmpty) return;

              setState(() {
                if (reader == null) {
                  // Thêm mới
                  AppData.readers.add({"id": id, "name": name});
                } else {
                  // Cập nhật
                  AppData.readers[index!] = {"id": id, "name": name};
                }
              });
              Navigator.pop(context);
            },
            child: Text(reader == null ? "Thêm" : "Lưu"),
          ),
        ],
      ),
    );
  }

  // Hàm xóa độc giả
  void _deleteReader(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text(
          "Bạn có chắc muốn xóa độc giả ${AppData.readers[index]['name']} không?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                AppData.readers.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readers = AppData.readers; // ✅ lấy dữ liệu từ AppData

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: const Text(
          "Quản lý độc giả",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: readers.length,
        itemBuilder: (context, index) {
          final reader = readers[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blueAccent),
              title: Text(reader['name']),
              subtitle: Text("Mã độc giả: ${reader['id']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () =>
                        _showReaderDialog(reader: reader, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteReader(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showReaderDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: buildBottomNav(context, 3),
    );
  }
}
