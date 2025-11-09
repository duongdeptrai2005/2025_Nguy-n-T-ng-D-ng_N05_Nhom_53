import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_detail_screen.dart';

class FavoriteTab extends StatelessWidget {
  const FavoriteTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text("Vui lòng đăng nhập để xem danh sách yêu thích."),
      );
    }

    // 🔥 Truy vấn danh sách yêu thích từ Firestore
    final favoritesRef = FirebaseFirestore.instance
        .collection('favorites')
        .where('user_id', isEqualTo: user.uid);

    return StreamBuilder<QuerySnapshot>(
      stream: favoritesRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "💔 Bạn chưa thêm quyển sách nào vào yêu thích.",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final favoriteBooks = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteBooks.length,
          itemBuilder: (context, index) {
            final fav = favoriteBooks[index];
            final title = fav['book_title'] ?? "Không có tiêu đề";
            final author = fav['book_author'] ?? "Không rõ tác giả";
            final image = fav['book_image'] ?? "";
            // final description = fav['description'] ?? ""; // ✅ thêm mô tả
            final docId = fav.id;

            ImageProvider imageProvider;
            if (image.startsWith('http')) {
              imageProvider = NetworkImage(image);
            } else {
              imageProvider = AssetImage(image);
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              shadowColor: Colors.grey.withOpacity(0.2),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailScreen(
                        title: title,
                        author: author,
                        tag: "",
                        imagePath: image,
                        // description: description, // ✅ truyền sang chi tiết
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      // Ảnh bìa
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image(
                          image: imageProvider,
                          width: 55,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Thông tin sách
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tác giả: $author",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            // Text(
                            //   description.isNotEmpty
                            //       ? description
                            //       : "Chưa có mô tả",
                            //   maxLines: 2,
                            //   overflow: TextOverflow.ellipsis,
                            //   style: const TextStyle(
                            //     color: Colors.black45,
                            //     fontSize: 12,
                            //   ),
                            // ),
                          ],
                        ),
                      ),

                      // Nút xóa
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('favorites')
                              .doc(docId)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("❌ Đã xóa '$title' khỏi danh sách yêu thích"),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
