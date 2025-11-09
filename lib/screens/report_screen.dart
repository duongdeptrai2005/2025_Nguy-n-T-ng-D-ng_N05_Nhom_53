import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/bottom_nav.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // ✅ Hàm hiển thị thông báo
  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// ✅ Xác nhận trả sách → cập nhật trạng thái + tăng 1 quyển trong Firestore
  Future<void> _confirmReturn(String docId) async {
    try {
      // 🔹 Lấy thông tin phiếu mượn
      final borrowDoc =
          await _firestore.collection("borrowed_books").doc(docId).get();

      if (!borrowDoc.exists) {
        return _snack("❌ Không tìm thấy phiếu mượn!");
      }

      final borrowData = borrowDoc.data()!;
      final bookTitle = borrowData["book_title"];

      // 🔹 Tìm sách theo title trong collection "books"
      final booksRef = _firestore.collection("books");
      final bookSnap =
          await booksRef.where("title", isEqualTo: bookTitle).limit(1).get();

      if (bookSnap.docs.isEmpty) {
        return _snack("❌ Không tìm thấy thông tin sách trong thư viện!");
      }

      final bookDoc = bookSnap.docs.first;
      final currentQuantity = (bookDoc["quantity"] ?? 0) as int;

      // 🔹 Tăng lại 1 quyển sách
      await booksRef.doc(bookDoc.id).update({
        "quantity": currentQuantity + 1,
      });

      // 🔹 Cập nhật trạng thái phiếu mượn thành "đã trả"
      await _firestore.collection("borrowed_books").doc(docId).update({
        "status": "đã trả",
        "return_date": Timestamp.now(),
      });

      _snack("✅ Đã xác nhận trả sách và cập nhật số lượng!");
    } catch (e) {
      debugPrint("❌ Lỗi khi xác nhận trả: $e");
      _snack("❌ Lỗi khi cập nhật: $e");
    }
  }

  // 🔹 Stream danh sách phiếu theo trạng thái
  Stream<QuerySnapshot> _getBorrowStream(String status) {
    return _firestore
        .collection('borrowed_books')
        .where('status', isEqualTo: status)
        .orderBy('borrow_date', descending: true)
        .snapshots();
  }

  // 🔹 Widget danh sách phiếu mượn
  Widget _buildBorrowList(Stream<QuerySnapshot> stream, bool isOngoing) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("❌ Lỗi Firestore: ${snapshot.error}",
                style: const TextStyle(color: Colors.red)),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text(
              isOngoing
                  ? "📭 Chưa có phiếu đang mượn."
                  : "✅ Chưa có phiếu đã trả.",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>? ?? {};
            final title = data['book_title'] ?? 'Không rõ';
            final author = data['book_author'] ?? 'Không rõ';
            final status = data['status'] ?? 'đang mượn';
            final image = data['book_image'];
            final userId = data['user_id'] ?? '';

            DateTime? borrowDate;
            DateTime? dueDate;
            try {
              borrowDate = (data['borrow_date'] as Timestamp?)?.toDate();
              dueDate = (data['due_date'] as Timestamp?)?.toDate();
            } catch (_) {}

            // 🔹 Lấy tên người mượn
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(userId).get(),
              builder: (context, userSnap) {
                String borrowerName = "Đang tải...";
                if (userSnap.connectionState == ConnectionState.done &&
                    userSnap.data != null &&
                    userSnap.data!.exists) {
                  borrowerName =
                      (userSnap.data!.data() as Map<String, dynamic>)['name'] ??
                          'Không rõ';
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: image != null && image.toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              image,
                              width: 55,
                              height: 75,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.book, color: Colors.blue),
                            ),
                          )
                        : const Icon(Icons.book, color: Colors.blue),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "👤 Người mượn: $borrowerName\n"
                        "Tác giả: $author\n"
                        "📅 ${borrowDate != null ? _formatDate(borrowDate) : '?'} → ${dueDate != null ? _formatDate(dueDate) : '?'}\n"
                        "Trạng thái: ${status.toUpperCase()}",
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                    trailing: isOngoing
                        ? ElevatedButton(
                            onPressed: () => _confirmReturn(docs[index].id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Xác nhận\ntrả",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          )
                        : const Icon(Icons.check_circle,
                            color: Colors.grey, size: 28),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Quản lý phiếu mượn"),
        backgroundColor: Colors.blue[600],
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "📘 Đang mượn"),
            Tab(text: "✅ Đã trả"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBorrowList(_getBorrowStream('đang mượn'), true),
          _buildBorrowList(_getBorrowStream('đã trả'), false),
        ],
      ),
      bottomNavigationBar: buildBottomNav(context, 2),
    );
  }
}
