import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_nav.dart';

class OrderStatsScreen extends StatelessWidget {
  const OrderStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text("📦 Quản lý đơn hàng"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      bottomNavigationBar: buildBottomNav(context, 4),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "❌ Lỗi khi tải dữ liệu: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "📭 Chưa có đơn hàng nào.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderDoc = orders[index];
              final order = orderDoc.data() as Map<String, dynamic>? ?? {};
              final id = orderDoc.id;
              final status = order['status'] ?? 'pending';
              final total = order['total'] ?? 0;
              final createdAt =
                  (order['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
              final userId = order['userId'] ?? '';
              final userAddress = order['userAddress'] ?? 'Chưa có địa chỉ';

              return FutureBuilder<DocumentSnapshot>(
                future: _getUserData(userId),
                builder: (context, userSnapshot) {
                  String userName = 'Người dùng ẩn danh';
                  String userEmail = 'Không có email';
                  if (userSnapshot.hasError) {
                    debugPrint(
                        "❌ Lỗi khi lấy dữ liệu userId=$userId: ${userSnapshot.error}");
                  } else if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                    userName = userData['name'] ?? userName;
                    userEmail = userData['email'] ?? userEmail;

                    if (!userData.containsKey('name')) {
                      debugPrint(
                          "⚠️ User document $userId không có trường 'name'");
                    }
                    if (!userData.containsKey('email')) {
                      debugPrint(
                          "⚠️ User document $userId không có trường 'email'");
                    }
                  } else {
                    debugPrint("⚠️ User document $userId không tồn tại");
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Đơn hàng #${id.substring(0, 6)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          _buildStatusChip(status),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("👤 Người mua: $userName"),
                          Text("📧 $userEmail",
                              style: const TextStyle(color: Colors.black54)),
                          Text(
                            "🏠 Địa chỉ: $userAddress",
                            style: const TextStyle(color: Colors.black87),
                          ),
                          Text(
                            "🕒 ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "💰 Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(total)}",
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      children: [
                        const Divider(),
                        ...items.map((item) {
                          final title = item['title']?.toString() ?? 'Không có tên';
                          final author = item['author']?.toString() ?? 'Không rõ';
                          final imageUrl = item['image']?.toString().trim() ?? '';
                          final price = item['price'] ?? 0;
                          final quantity = item['quantity'] ?? 1;

                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildImage(imageUrl),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
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
                        const Divider(),
                        if (status != 'completed')
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('orders')
                                      .doc(id)
                                      .update({'status': 'completed'});

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            '✅ Đơn hàng đã được xác nhận giao thành công!'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('❌ Lỗi: $e')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text("Xác nhận đã giao"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                      ],
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

  Future<DocumentSnapshot> _getUserData(String userId) async {
    if (userId.isEmpty) {
      throw Exception("UserId rỗng");
    }
    return await FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Đang xử lý';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Đã giao';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Đã hủy';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

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
