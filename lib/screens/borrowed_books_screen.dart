import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BorrowedBooksScreen extends StatefulWidget {
  const BorrowedBooksScreen({super.key});

  @override
  State<BorrowedBooksScreen> createState() => _BorrowedBooksScreenState();
}

class _BorrowedBooksScreenState extends State<BorrowedBooksScreen> {
  String selectedFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Nếu chưa đăng nhập
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Vui lòng đăng nhập để xem danh sách sách đã mượn.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Stream lấy dữ liệu sách theo user_id
    final borrowedBooksStream = FirebaseFirestore.instance
        .collection('borrowed_books')
        .where('user_id', isEqualTo: currentUser.uid)
        .orderBy('borrow_date', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Sách đã mượn',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // --- Bộ lọc ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FilterChip(
                  label: 'Tất cả',
                  selected: selectedFilter == 'Tất cả',
                  onTap: () => setState(() => selectedFilter = 'Tất cả'),
                ),
                _FilterChip(
                  label: 'Đang mượn',
                  selected: selectedFilter == 'Đang mượn',
                  onTap: () => setState(() => selectedFilter = 'Đang mượn'),
                ),
                _FilterChip(
                  label: 'Quá hạn',
                  selected: selectedFilter == 'Quá hạn',
                  onTap: () => setState(() => selectedFilter = 'Quá hạn'),
                ),
                _FilterChip(
                  label: 'Đã trả',
                  selected: selectedFilter == 'Đã trả',
                  onTap: () => setState(() => selectedFilter = 'Đã trả'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Danh sách sách từ Firestore ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: borrowedBooksStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Lỗi tải dữ liệu: ${snapshot.error}'),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('Không có sách nào.'));
                  }

                  final books = docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    return BookModel.fromMap(doc.id, data);
                  }).where((book) {
                    // --- Bộ lọc dữ liệu ---
                    if (selectedFilter == 'Tất cả') return true;
                    if (selectedFilter == 'Quá hạn') {
                      return book.dueDate.isBefore(DateTime.now()) &&
                          book.status.toLowerCase() != 'đã trả';
                    }
                    return book.status.toLowerCase() ==
                        selectedFilter.toLowerCase();
                  }).toList();

                  if (books.isEmpty) {
                    return const Center(child: Text('Không có sách phù hợp.'));
                  }

                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return _BookItem(book: books[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======== MODEL ========
class BookModel {
  final String id;
  final String bookId;
  final String title;
  final String author;
  final String image;
  final String status;
  final DateTime borrowDate;
  final DateTime dueDate;
  final String? description;

  BookModel({
    required this.id,
    required this.bookId,
    required this.title,
    required this.author,
    required this.image,
    required this.status,
    required this.borrowDate,
    required this.dueDate,
    this.description,
  });

  factory BookModel.fromMap(String docId, Map<String, dynamic> data) {
    return BookModel(
      id: docId,
      bookId: data['book_id']?.toString() ?? '',
      title: data['book_title']?.toString() ?? 'Không có tiêu đề',
      author: data['book_author']?.toString() ?? 'Không rõ tác giả',
      image: data['book_image']?.toString() ?? '',
      status: data['status']?.toString() ?? 'đang mượn',
      borrowDate: (data['borrow_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['due_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['book_description']?.toString(),
    );
  }
}

// ======== BOOK ITEM ========
class _BookItem extends StatelessWidget {
  final BookModel book;

  const _BookItem({required this.book});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final borrowDateStr = DateFormat('dd/MM/yyyy').format(book.borrowDate);
    final returnDateStr = DateFormat('dd/MM/yyyy').format(book.dueDate);

    String statusText;
    Color statusColor;

    if (book.status.toLowerCase() == 'đã trả') {
      statusText = 'Đã trả';
      statusColor = Colors.green;
    } else if (book.dueDate.isBefore(now)) {
      statusText = 'Quá hạn';
      statusColor = Colors.red;
    } else {
      final daysLeft = book.dueDate.difference(now).inDays;
      statusText = 'Hết hạn sau $daysLeft ngày';
      statusColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: book.image.isNotEmpty
              ? Image.network(
                  book.image,
                  width: 48,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 48),
                )
              : const Icon(Icons.book, size: 48, color: Colors.grey),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.author, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                'Mượn: $borrowDateStr\nTrả: $returnDateStr',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        trailing: Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(book.title),
              content: Text(
                (book.description?.isNotEmpty ?? false)
                    ? book.description!
                    : 'Không có mô tả cho sách này.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ======== FILTER CHIP ========
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.deepPurple : const Color(0xFFE0E0E0),
            width: 1.3,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.deepPurple : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
