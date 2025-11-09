import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookDetailScreen extends StatefulWidget {
  final String title;
  final String author;
  final String tag;
  final String imagePath;
  final String? description;

  const BookDetailScreen({
    super.key,
    required this.title,
    required this.author,
    required this.tag,
    required this.imagePath,
    this.description,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool isFavorite = false;
  String? favoriteDocId;
  double averageRating = 0.0;
  int totalReviews = 0;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _loadAverageRating();
  }

  Future<void> _checkFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("favorites")
        .where("book_title", isEqualTo: widget.title)
        .where("user_id", isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        isFavorite = true;
        favoriteDocId = snapshot.docs.first.id;
      });
    }
  }

  Future<void> _loadAverageRating() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("reviews")
        .where("book_title", isEqualTo: widget.title)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final ratings = snapshot.docs
          .map((d) => (d["rating"] ?? 0).toDouble())
          .toList();
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      setState(() {
        averageRating = avg;
        totalReviews = ratings.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = widget.imagePath.startsWith("http")
        ? NetworkImage(widget.imagePath)
        : AssetImage(widget.imagePath) as ImageProvider;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          "Chi tiết sách",
          style: TextStyle(
            color: Colors.blueGrey[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.redAccent : Colors.black45,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📚 Ảnh bìa
            Center(
              child: Hero(
                tag: widget.title,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image(
                    image: imageProvider,
                    width: 180,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📘 Tiêu đề, tác giả, rating
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.author,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < averageRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${averageRating.toStringAsFixed(1)} (${totalReviews})",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🏷️ Thẻ sách
            if (widget.tag.isNotEmpty)
              Chip(
                label: Text(
                  widget.tag,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.blueAccent,
              ),

            const SizedBox(height: 20),

            // 📄 Mô tả
            const Text(
              "📖 Giới thiệu",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description ??
                  "Chưa có mô tả cho quyển sách này.",
              style: const TextStyle(
                color: Colors.black87,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            // 🔘 Nút hành động
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _borrow(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.bookmark_add_outlined,
                        color: Colors.white),
                    label: const Text(
                      "Mượn ngay",
                      style:
                          TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showReviewDialog(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.reviews, color: Colors.blueAccent),
                    label: const Text(
                      "Đánh giá",
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 💬 Danh sách đánh giá
            const Text(
              "💬 Đánh giá gần đây",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _reviewList(),
          ],
        ),
      ),
    );
  }

  /// ❤️ Thêm / xóa yêu thích
  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _snack("Vui lòng đăng nhập để thêm yêu thích!");

    final favorites = FirebaseFirestore.instance.collection("favorites");

    if (isFavorite && favoriteDocId != null) {
      await favorites.doc(favoriteDocId).delete();
      setState(() => isFavorite = false);
      _snack("❌ Đã xóa khỏi yêu thích");
    } else {
      final doc = await favorites.add({
        "book_title": widget.title,
        "book_author": widget.author,
        "book_image": widget.imagePath,
        "user_id": user.uid,
        "created_at": Timestamp.now(),
      });
      setState(() {
        isFavorite = true;
        favoriteDocId = doc.id;
      });
      _snack("💖 Đã thêm vào yêu thích!");
    }
  }

  /// ✅ Mượn sách
  Future<void> _borrow(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _snack("Vui lòng đăng nhập để mượn sách!");

    final borrowed = FirebaseFirestore.instance.collection("borrowed_books");
    final existing = await borrowed
        .where("user_id", isEqualTo: user.uid)
        .where("book_title", isEqualTo: widget.title)
        .where("status", whereIn: ["đang mượn", "pending"])
        .get();

    if (existing.docs.isNotEmpty) {
      return _snack("❌ Bạn đã mượn quyển này rồi!");
    }

    // Giảm số lượng
    final bookRef = FirebaseFirestore.instance.collection("books");
    final snap =
        await bookRef.where("title", isEqualTo: widget.title).limit(1).get();
    if (snap.docs.isEmpty) return _snack("Không tìm thấy thông tin sách!");
    final doc = snap.docs.first;
    final quantity = (doc["quantity"] ?? 0) as int;
    if (quantity <= 0) return _snack("📚 Sách đã hết!");

    await bookRef.doc(doc.id).update({"quantity": quantity - 1});

    await borrowed.add({
      "book_title": widget.title,
      "book_author": widget.author,
      "book_image": widget.imagePath,
      "user_id": user.uid,
      "borrow_date": Timestamp.now(),
      "due_date": Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      "status": "đang mượn",
    });

    _snack("✅ Mượn sách thành công!");
  }

  /// 💬 Danh sách đánh giá
  Widget _reviewList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("reviews")
          .where("book_title", isEqualTo: widget.title)
          .orderBy("created_at", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final reviews = snapshot.data!.docs;
        if (reviews.isEmpty) {
          return const Text("📭 Chưa có đánh giá nào.");
        }
        return Column(
          children: reviews.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data["username"] ?? "Người dùng",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < (data["rating"] ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data["comment"] ?? "",
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// 💫 Gửi đánh giá
  void _showReviewDialog(BuildContext context) {
    final commentCtrl = TextEditingController();
    double rating = 5;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đánh giá sách"),
        content: StatefulBuilder(
          builder: (context, setSB) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    onPressed: () => setSB(() => rating = i + 1.0),
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Nhập cảm nhận của bạn...",
                ),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
              onPressed: () async {
                await _saveReview(rating, commentCtrl.text);
                Navigator.pop(context);
              },
              child: const Text("Gửi")),
        ],
      ),
    );
  }

  Future<void> _saveReview(double rating, String comment) async {
    if (comment.trim().isEmpty) return _snack("Hãy nhập nội dung!");
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection("reviews").add({
      "book_title": widget.title,
      "rating": rating,
      "comment": comment.trim(),
      "created_at": Timestamp.now(),
      "user_id": user?.uid,
      "username": user?.displayName ?? user?.email ?? "Người dùng",
    });
    _snack("✅ Đánh giá thành công!");
    _loadAverageRating(); // Cập nhật sao trung bình
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
