import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'book_screen.dart';
import 'report_screen.dart';
import 'reader_screen.dart';
import 'settings_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int totalBorrows = 0;
  int totalReturns = 0;
  int totalUsers = 0;
  int totalBooks = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// 🔥 Lấy dữ liệu thống kê từ Firestore
  Future<void> _loadDashboardData() async {
    try {
      final borrowSnap = await FirebaseFirestore.instance
          .collection('borrowed_books')
          .where('status', isEqualTo: 'đang mượn')
          .get();

      final returnSnap = await FirebaseFirestore.instance
          .collection('borrowed_books')
          .where('status', isEqualTo: 'đã trả')
          .get();

      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      final bookSnap =
          await FirebaseFirestore.instance.collection('books').get();

      setState(() {
        totalBorrows = borrowSnap.size;
        totalReturns = returnSnap.size;
        totalUsers = userSnap.size;
        totalBooks = bookSnap.size;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('🔥 Lỗi khi tải thống kê: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        toolbarHeight: 70,
        title: const Text(
          "📊 Trang quản trị",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ====================== Thống kê ======================
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Đang mượn",
                            totalBorrows.toString(),
                            Icons.book_outlined,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            "Đã trả",
                            totalReturns.toString(),
                            Icons.assignment_turned_in_outlined,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Người dùng",
                            totalUsers.toString(),
                            Icons.people_outline,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            "Tổng sách",
                            totalBooks.toString(),
                            Icons.menu_book_outlined,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ====================== Biểu đồ mượn trả ======================
                    _buildChartSection(),

                    const SizedBox(height: 30),

                    // ====================== Lượt mượn gần đây ======================
                    _buildRecentBorrowsSection(),
                  ],
                ),
              ),
            ),

      // ====================== Thanh điều hướng dưới ======================
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const BookScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ReportScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ReaderScreen()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Sách"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Phiếu mượn"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Độc giả"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Cài đặt"),
        ],
      ),
    );
  }

  // ====================== Widget thống kê ======================
  static Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // ====================== Biểu đồ tròn ======================
  Widget _buildChartSection() {
    final total = totalBorrows + totalReturns;
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _boxStyle(),
        child: const Center(
            child: Text("Chưa có dữ liệu mượn/trả sách.",
                style: TextStyle(color: Colors.grey))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("📈 Tỷ lệ mượn / trả",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    color: Colors.orange,
                    value: totalBorrows.toDouble(),
                    title: "Mượn",
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: totalReturns.toDouble(),
                    title: "Trả",
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== Lượt mượn gần đây ======================
  Widget _buildRecentBorrowsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🕓 Lượt mượn gần đây",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('borrowed_books')
                .orderBy('borrow_date', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Chưa có lượt mượn nào.",
                      style: TextStyle(color: Colors.grey)),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        data['book_image'] ?? '',
                        width: 45,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(data['book_title'] ?? 'Không rõ'),
                    subtitle: Text("Trạng thái: ${data['status'] ?? ''}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 3))
      ],
    );
  }
}
