import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'cloudinary_service.dart';
import '../widgets/bottom_nav.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final CollectionReference booksRef =
      FirebaseFirestore.instance.collection('books');

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();

  String searchKeyword = "";

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _showBookDialog({DocumentSnapshot? book}) {
    final titleController = TextEditingController(text: book?['title'] ?? '');
    final authorController = TextEditingController(text: book?['author'] ?? '');
    final tagController = TextEditingController(text: book?['tag'] ?? '');
    final descriptionController =
        TextEditingController(text: book?['description'] ?? '');
    final priceController = TextEditingController(text: book?['price'] ?? '');
    final ratingController = TextEditingController(text: book?['rating'] ?? '');
    final quantityController =
        TextEditingController(text: book?['quantity']?.toString() ?? '');

    String imageUrl = book?['image'] ?? '';
    _selectedImage = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            ImageProvider imageProvider;
            if (_selectedImage != null) {
              imageProvider = FileImage(_selectedImage!);
            } else if (imageUrl.startsWith('http')) {
              imageProvider = NetworkImage(imageUrl);
            } else if (imageUrl.isNotEmpty) {
              imageProvider = AssetImage(imageUrl);
            } else {
              imageProvider =
                  const AssetImage('assets/images/no_image.png');
            }

            return AlertDialog(
              title: Text(book == null ? "📚 Thêm sách mới" : "✏️ Chỉnh sửa sách"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picked =
                            await _picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setStateDialog(() {
                            _selectedImage = File(picked.path);
                          });
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          color: Colors.grey[300],
                        ),
                        child: (_selectedImage == null && imageUrl.isEmpty)
                            ? const Icon(Icons.add_a_photo,
                                size: 40, color: Colors.black54)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                        controller: titleController,
                        decoration:
                            const InputDecoration(labelText: "Tên sách")),
                    TextField(
                        controller: authorController,
                        decoration:
                            const InputDecoration(labelText: "Tác giả")),
                    TextField(
                        controller: tagController,
                        decoration: const InputDecoration(labelText: "Thẻ (tag)")),
                    TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: "Giá")),
                    TextField(
                        controller: ratingController,
                        decoration:
                            const InputDecoration(labelText: "Đánh giá")),
                    TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: "Số lượng sách")),
                    TextField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: "Mô tả")),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Hủy"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text(book == null ? "Thêm" : "Lưu"),
                  onPressed: () async {
                    String finalImageUrl = imageUrl;

                    try {
                      if (_selectedImage != null) {
                        final uploadedUrl =
                            await CloudinaryService.uploadImage(_selectedImage!);
                        if (uploadedUrl != null) {
                          finalImageUrl = uploadedUrl;
                        }
                      }

                      final data = {
                        "title": titleController.text.trim(),
                        "author": authorController.text.trim(),
                        "tag": tagController.text.trim(),
                        "image": finalImageUrl,
                        "description": descriptionController.text.trim(),
                        "price": priceController.text.trim(),
                        "rating": ratingController.text.trim(),
                        "quantity": int.tryParse(quantityController.text) ?? 0,
                      };

                      if (book == null) {
                        await booksRef.add(data);
                      } else {
                        await booksRef.doc(book.id).update(data);
                      }

                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("⚠️ Lỗi khi lưu sách: $e"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteBook(DocumentSnapshot book) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa '${book['title']}' không?"),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Xóa"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await booksRef.doc(book.id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: const Text(
          "📘 Quản lý sách (Cloudinary)",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => searchKeyword = value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: "🔍 Tìm sách theo tên, tác giả hoặc thẻ...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: booksRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có sách nào trong thư viện."));
          }

          final books = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title = (data['title'] ?? '').toString().toLowerCase();
            final author = (data['author'] ?? '').toString().toLowerCase();
            final tag = (data['tag'] ?? '').toString().toLowerCase();

            // Nếu không có từ khóa thì hiển thị tất cả
            if (searchKeyword.isEmpty) return true;

            // Tìm kiếm theo tiêu đề, tác giả hoặc thẻ
            return title.contains(searchKeyword) ||
                author.contains(searchKeyword) ||
                tag.contains(searchKeyword);
          }).toList();

          if (books.isEmpty) {
            return const Center(child: Text("Không tìm thấy sách nào phù hợp."));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final data = book.data() as Map<String, dynamic>;

              final title = data['title'] ?? 'Không tên';
              final author = data['author'] ?? 'Không rõ';
              final image = data['image'] ?? '';
              final tag = data['tag'] ?? '';
              final quantity = data['quantity'] ?? 0;

              ImageProvider imageProvider;
              if (image.startsWith('http')) {
                imageProvider = NetworkImage(image);
              } else if (image.isNotEmpty) {
                imageProvider = AssetImage(image);
              } else {
                imageProvider =
                    const AssetImage('assets/images/no_image.png');
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image(
                      image: imageProvider,
                      width: 50,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tác giả: $author"),
                      Text("Số lượng: $quantity"),
                      if (tag.isNotEmpty)
                        Text("Thẻ: $tag", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _showBookDialog(book: book),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBook(book),
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
        onPressed: () => _showBookDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: buildBottomNav(context, 1),
    );
  }
}
