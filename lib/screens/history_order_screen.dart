import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryOrder extends StatelessWidget {
  const HistoryOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text("Lịch sử mua hàng"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: user == null
          ? const Center(
              child: Text("Vui lòng đăng nhập để xem lịch sử mua hàng."),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "🔥 Lỗi khi tải dữ liệu: ${snapshot.error}",
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("📭 Bạn chưa có đơn hàng nào."),
                  );
                }

                final orders = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order =
                        orders[index].data() as Map<String, dynamic>;

                    final status = order['status'] ?? 'Không rõ';
                    final total = order['total'] ?? 0;
                    final createdAt =
                        (order['createdAt'] as Timestamp).toDate();
                    final items =
                        List<Map<String, dynamic>>.from(order['items'] ?? []);
                    final address = order['userAddress'] ?? 'Chưa có địa chỉ';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          "Đơn hàng #${orders[index].id.substring(0, 6)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Trạng thái: $status",
                              style: TextStyle(
                                color: status == "pending"
                                    ? Colors.orange
                                    : status == "completed"
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(total)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "🏠 Địa chỉ nhận hàng: $address",
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        children: items.map((item) {
                          final title =
                              item['title']?.toString() ?? 'Không có tên';
                          final author =
                              item['author']?.toString() ?? 'Không rõ';
                          final imageUrl =
                              item['image']?.toString().trim() ?? '';
                          final price = item['price'] ?? 0;
                          final quantity = item['quantity'] ?? 1;

                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildImage(imageUrl),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Tác giả: $author\nSố lượng: $quantity",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: Text(
                              NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: '₫',
                              ).format(price),
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  /// ✅ Hàm hiển thị ảnh (dùng field `image`)
  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 50,
        height: 70,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 50,
        height: 70,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 50,
            height: 70,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint("❌ Lỗi tải ảnh: $error");
          return Container(
            width: 50,
            height: 70,
            color: Colors.red[50],
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, color: Colors.redAccent),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        width: 50,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint("⚠️ Ảnh asset không tồn tại: $imageUrl");
          return Container(
            width: 50,
            height: 70,
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }
  }
}
