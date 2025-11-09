import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../data/app_data.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  void _showBookDialog({Map<String, dynamic>? book, int? index}) {
    final titleController = TextEditingController(text: book?['title'] ?? '');
    final quantityController = TextEditingController(
      text: book?['quantity']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(book == null ? "Thêm sách mới" : "Chỉnh sửa sách"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Tên sách"),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: "Số lượng"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(book == null ? "Thêm" : "Lưu"),
              onPressed: () {
                final title = titleController.text.trim();
                final quantity = int.tryParse(quantityController.text) ?? 0;

                if (title.isEmpty) return;

                setState(() {
                  if (book == null) {
                    AppData.books.add({"title": title, "quantity": quantity});
                  } else {
                    AppData.books[index!] = {
                      "title": title,
                      "quantity": quantity,
                    };
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteBook(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: Text(
            "Bạn có chắc muốn xóa '${AppData.books[index]['title']}' không?",
          ),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Xóa"),
              onPressed: () {
                setState(() {
                  AppData.books.removeAt(index);
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = AppData.books;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: const Text(
          "Quản lý sách",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${books.length} sách",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: () => _showBookDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.menu_book, color: Colors.blue),
                    title: Text(
                      book['title'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text("Số lượng: ${book['quantity']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () =>
                              _showBookDialog(book: book, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteBook(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNav(context, 1),
    );
  }
}
