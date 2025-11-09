import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  String searchKeyword = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔍 Thanh tìm kiếm
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => searchKeyword = value.toLowerCase()),
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

        // Danh sách sách
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('books').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("📚 Chưa có sách nào trong thư viện."),
                );
              }

              // Lọc sách theo từ khóa
              final books = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title = (data['title'] ?? '').toString().toLowerCase();
                final author = (data['author'] ?? '').toString().toLowerCase();
                final tag = (data['tag'] ?? '').toString().toLowerCase();

                if (searchKeyword.isEmpty) return true;

                return title.contains(searchKeyword) ||
                    author.contains(searchKeyword) ||
                    tag.contains(searchKeyword);
              }).toList();

              if (books.isEmpty) {
                return const Center(child: Text("Không tìm thấy sách phù hợp."));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Hiển thị tổng số sách
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "📖 Tổng số sách: ${books.length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),

                  // Danh sách sách
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final data = books[index].data() as Map<String, dynamic>;

                        final title = data['title'] ?? 'Không tên';
                        final author = data['author'] ?? 'Không rõ';
                        final tag = data['tag'] ?? '';
                        final image = data['image'] ?? '';
                        final description = data['description'] ?? '';
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

                        return InkWell(
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
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Ảnh bìa sách
                                Container(
                                  width: 55,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
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
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        author,
                                        style: const TextStyle(color: Colors.black54),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        description.isNotEmpty
                                            ? description
                                            : "Chưa có mô tả",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.black45,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Số lượng: $quantity cuốn",
                                        style: const TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Tag
                                if (tag.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: tag == "Mới"
                                          ? Colors.blue[100]
                                          : Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        color: tag == "Mới"
                                            ? Colors.blue
                                            : Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
