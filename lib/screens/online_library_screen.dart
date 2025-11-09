import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_detail_screen.dart';
import 'checkout_screen.dart';

class OnlineLibraryScreen extends StatefulWidget {
  const OnlineLibraryScreen({super.key});

  @override
  State<OnlineLibraryScreen> createState() => _OnlineLibraryScreenState();
}

class _OnlineLibraryScreenState extends State<OnlineLibraryScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          "Mua sách online",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              );
            },
          ),
        ],
      ),

      // Nội dung chính
      body: Column(
        children: [
          // 🔍 Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm sách hoặc tác giả",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),

          // 🧾 Danh sách sách
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("books").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "📭 Chưa có sách nào trong thư viện.",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  );
                }

                final books = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final author = (data['author'] ?? '').toString().toLowerCase();
                  return title.contains(searchQuery) ||
                      author.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final data = books[index].data() as Map<String, dynamic>;

                    final title = data['title'] ?? "Không có tiêu đề";
                    final author = data['author'] ?? "Không rõ tác giả";
                    final description = data['description'] ?? "";
                    final price = data['price']?.toString() ?? "0";
                    final imagePath = data['image'] ?? ""; // 🔥 sửa lại từ 'image' → 'picture'
                    final rating = data['rating']?.toString() ?? "4.0";

                    // Xác định ảnh hiển thị
                    ImageProvider imageProvider;
                    if (imagePath.startsWith('http')) {
                      imageProvider = NetworkImage(imagePath);
                    } else if (imagePath.contains('assets/')) {
                      imageProvider = AssetImage(imagePath);
                    } else {
                      imageProvider =
                          const AssetImage('assets/images/default_book.jpg');
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
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
                                imagePath: imagePath,
                                description: description,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              // 🖼 Ảnh sách
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

                              // 📘 Thông tin sách
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      author,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      description.isNotEmpty
                                          ? description
                                          : "Không có mô tả",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black45,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            size: 14, color: Colors.amber),
                                        const SizedBox(width: 2),
                                        Text(
                                          rating,
                                          style: const TextStyle(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // 💸 Giá + nút Thêm
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "$price vnd",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final user =
                                          FirebaseAuth.instance.currentUser;

                                      if (user == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Vui lòng đăng nhập để thêm vào giỏ hàng")));
                                        return;
                                      }

                                      final cartRef = FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .collection('cart')
                                          .doc(title);

                                      final cartDoc = await cartRef.get();
                                      final parsedPrice = double.tryParse(
                                              price.replaceAll(',', '')) ??
                                          0;

                                      if (cartDoc.exists) {
                                        await cartRef.update({
                                          'quantity': FieldValue.increment(1),
                                        });
                                      } else {
                                        await cartRef.set({
                                          'title': title,
                                          'author': author,
                                          'price': parsedPrice,
                                          'image': imagePath,
                                          'quantity': 1,
                                          'createdAt':
                                              FieldValue.serverTimestamp(),
                                        });
                                      }

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            'Đã thêm "$title" vào giỏ hàng!'),
                                        duration:
                                            const Duration(milliseconds: 800),
                                      ));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black87,
                                      minimumSize: const Size(80, 32),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add,
                                        size: 16, color: Colors.white),
                                    label: const Text(
                                      "Thêm",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
