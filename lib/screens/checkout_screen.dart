import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _addressController = TextEditingController();

  /// Tính tổng tiền giỏ hàng
  double calculateTotal(QuerySnapshot snapshot) {
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final price = (data['price'] ?? 0).toDouble();
      final qty = (data['quantity'] ?? 1).toInt();
      total += price * qty;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    // 🔹 Load địa chỉ hiện tại của user nếu có
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((doc) {
        if (doc.exists && doc.data()?['address'] != null) {
          _addressController.text = doc.data()!['address'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Giỏ hàng"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Vui lòng đăng nhập để xem giỏ hàng."),
        ),
      );
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          "Giỏ hàng của bạn",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "🛒 Giỏ hàng trống",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          final total = calculateTotal(snapshot.data!);

          return Column(
            children: [
              // Danh sách sản phẩm trong giỏ
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final title = data['title'] ?? '';
                    final author = data['author'] ?? '';
                    final image = data['image'] ?? '';
                    final quantity = data['quantity'] ?? 1;
                    final price = (data['price'] ?? 0).toDouble();

                    ImageProvider imageProvider;
                    if (image.startsWith('http')) {
                      imageProvider = NetworkImage(image);
                    } else if (image.contains('assets/')) {
                      imageProvider = AssetImage(image);
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
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            // Ảnh sách
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
                                  const SizedBox(height: 6),
                                  Text(
                                    "${price.toStringAsFixed(0)} vnd",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Nút tăng/giảm số lượng
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    cartRef.doc(doc.id).update({
                                      'quantity': FieldValue.increment(1),
                                    });
                                  },
                                ),
                                Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    if (quantity > 1) {
                                      cartRef.doc(doc.id).update({
                                        'quantity': FieldValue.increment(-1),
                                      });
                                    } else {
                                      cartRef.doc(doc.id).delete();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Nhập địa chỉ + Tổng tiền + Thanh toán
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nhập địa chỉ
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: "🏠 Nhập địa chỉ nhận hàng",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      "💵 Đặt hàng và thanh toán khi nhận hàng",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tổng: ${total.toStringAsFixed(0)} vnd",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final address = _addressController.text.trim();
                            if (address.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "❌ Vui lòng nhập địa chỉ trước khi đặt hàng."),
                                ),
                              );
                              return;
                            }

                            final cartSnapshot = await cartRef.get();
                            if (cartSnapshot.docs.isEmpty) return;

                            final total = calculateTotal(cartSnapshot);

                            // 🔹 Lưu địa chỉ vào document user
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .set({'address': address}, SetOptions(merge: true));

                            // Lưu đơn hàng vào Firestore
                            final orderData = {
                              'userId': user!.uid,
                              'userAddress': address,
                              'items': cartSnapshot.docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return {
                                  'title': data['title'],
                                  'author': data['author'],
                                  'price': data['price'],
                                  'quantity': data['quantity'],
                                  'image': data['image'],
                                };
                              }).toList(),
                              'total': total,
                              'status': 'pending',
                              'createdAt': FieldValue.serverTimestamp(),
                            };
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .add(orderData);

                            // Xóa giỏ hàng
                            final batch = FirebaseFirestore.instance.batch();
                            for (var d in cartSnapshot.docs) {
                              batch.delete(d.reference);
                            }
                            await batch.commit();

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Đặt hàng thành công! Thanh toán khi nhận hàng."),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              _addressController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Thanh toán",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
