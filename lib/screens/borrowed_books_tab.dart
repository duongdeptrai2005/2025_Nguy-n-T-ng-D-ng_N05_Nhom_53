import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail_screen.dart'; // 🔹 import trang chi tiết

class BorrowedBooksTab extends StatelessWidget {
  const BorrowedBooksTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Lấy danh sách sách có rating cao nhất
    final topRatedBooksStream = FirebaseFirestore.instance
        .collection('books')
        .orderBy('rating', descending: true)
        .limit(10)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: topRatedBooksStream,
      builder: (context, snapshot) {
        // --- Đang tải ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // --- Lỗi ---
        if (snapshot.hasError) {
          return Center(child: Text('⚠️ Lỗi tải dữ liệu: ${snapshot.error}'));
        }

        // --- Không có dữ liệu ---
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('Không có sách nổi bật nào.'));
        }

        // --- Hiển thị danh sách sách ---
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            final title = data['title'] ?? 'Không có tiêu đề';
            final author = data['author'] ?? 'Không rõ tác giả';
            final image = data['image'] ?? '';
            final rating = data['rating']?.toString() ?? '0';
            final tag = data['tag'] ?? '';
            final description = data['description'] ?? '';

            // Ảnh hiển thị
            ImageProvider imageProvider;
            if (image.startsWith('http')) {
              imageProvider = NetworkImage(image);
            } else if (image.isNotEmpty) {
              imageProvider = AssetImage(image);
            } else {
              imageProvider = const AssetImage('assets/images/no_image.png');
            }

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: imageProvider,
                    width: 55,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[700], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (tag.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 👉 Khi bấm vào, chuyển sang chi tiết sách
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailScreen(
                        title: title,
                        author: author,
                        tag: tag,
                        imagePath: image,
                        description: description,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
