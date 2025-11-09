import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'book_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'borrowed_books_screen.dart';
import 'explore_tab.dart';
import 'favorite_tab.dart';
import 'package:intl/intl.dart';
import 'notification_screen.dart';
import 'help_support_screen.dart';
import 'wishlist_screen.dart';
import 'book_club_screen.dart';
import 'login_screen.dart';
import 'online_library_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import 'history_order_screen.dart';
import 'borrowed_books_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      // 🟦 Drawer menu
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Drawer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "LibHub",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // 📋 Các mục menu
              // 📋 Các mục menu
              _buildDrawerItem(
                Icons.person_outline,
                "Thông tin cá nhân",
                subtitleWidget: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text("...", style: TextStyle(fontSize: 13));
                    }

                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    String name = data["name"] ?? "Người dùng";

                    return Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    );
                  },
                ),
                onTap: () {
                  _navigateTo(context, const ProfileScreen());
                },
              ),

              _buildDrawerItem(
                Icons.library_books_outlined,
                "Danh sách mượn",
                onTap: () {
                  _navigateTo(context, const BorrowedBooksScreen());
                },
              ),

              _buildDrawerItem(
                Icons.desktop_mac_outlined,
                "Mua sách online",
                onTap: () {
                  _navigateTo(context, const OnlineLibraryScreen());
                },
              ),

              _buildDrawerItem(
                Icons.group_outlined,
                "Câu lạc bộ sách",
                onTap: () {
                  _navigateTo(context, const BookClubsScreen());
                },
              ),

              _buildDrawerItem(
                Icons.notifications_none,
                "Thông báo",
                onTap: () {
                  _navigateTo(context, const NotificationScreen());
                },
              ),

              _buildDrawerItem(
                Icons.history,
                "Lịch sử đơn hàng",
                onTap: () {
                  _navigateTo(context, const HistoryOrder());
                },
              ),

              _buildDrawerItem(
                Icons.help_outline,
                "Trợ giúp & Hỗ trợ",
                onTap: () {
                  _navigateTo(context, const HelpSupportScreen());
                },
              ),

              const Spacer(),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Đăng xuất",
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),

              const Spacer(),
              const Divider(),
            ],
          ),
        ),
      ),

      // 🟨 AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Builder(
          builder: (context) {
            return Row(
              children: [
                GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "LibHub",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 20,
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // 🧱 Nội dung chính
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text(
                    "Chào mừng...",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  );
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;
                String name = data["name"] ?? "Bạn";

                return Text(
                  "Chào mừng, $name!",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                );
              },
            ),

            const SizedBox(height: 4),
            const Text(
              "Khám phá những quyển sách mới hằng ngày",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // 🔍 Thanh tìm kiếm
            // Container(
            //   height: 44,
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(30),
            //   ),
            //   child: TextField(
            //     controller: _searchCtrl,
            //     decoration: InputDecoration(
            //       hintText: "Tìm kiếm sách, tác giả, ...",
            //       prefixIcon: IconButton(
            //         icon: const Icon(Icons.search, color: Colors.grey),
            //         onPressed: () {
            //           final query = _searchCtrl.text.trim();
            //           if (query.isNotEmpty) {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => SearchScreen(query: query),
            //               ),
            //             );
            //           }
            //         },
            //       ),
            //       border: InputBorder.none,
            //       contentPadding: const EdgeInsets.symmetric(vertical: 8),
            //     ),
            //     onSubmitted: (value) {
            //       if (value.trim().isNotEmpty) {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => SearchScreen(query: value.trim()),
            //           ),
            //         );
            //       }
            //     },
            //   ),
            // ),

            const SizedBox(height: 16),

            // 📊 Thống kê
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: getBorrowedTotal(),
                    builder: (context, snapshot) {
                      return _buildStatCard(
                        "Sách đã mượn",
                        (snapshot.data ?? 0).toString(),
                        Colors.indigo,
                        Icons.book_outlined,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FutureBuilder<int>(
                    future: getCurrentlyBorrowing(),
                    builder: (context, snapshot) {
                      return _buildStatCard(
                        "đang mượnSách ",
                        (snapshot.data ?? 0).toString(),
                        Colors.deepOrange,
                        Icons.access_time,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Điểm đọc sách",
                    "850",
                    Colors.purple,
                    Icons.emoji_events,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FutureBuilder<int>(
                    future: getFavoriteCount(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return _buildStatCard(
                          "Yêu thích",
                          "...",
                          Colors.redAccent,
                          Icons.favorite,
                        );
                      }

                      return _buildStatCard(
                        "Yêu thích",
                        snapshot.data.toString(),
                        Colors.redAccent,
                        Icons.favorite,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 📚 Tab + Nội dung
            Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blueAccent,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blueAccent,
                  tabs: const [
                    Tab(text: "Khám phá"),
                    Tab(text: "Sách Hot"),
                    Tab(text: "Yêu thích"),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      ExploreTab(),
                      BorrowedBooksTab(),
                      FavoriteTab(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 📦 Hàm phụ trợ
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildStatCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(
    String title,
    String author,
    String tag,
    String imagePath,
    String description,
  ) {
    ImageProvider imageProvider;

    if (imagePath.startsWith('http')) {
      imageProvider = NetworkImage(imagePath);
    } else {
      imageProvider = AssetImage(imagePath);
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
              imagePath: imagePath,
              description: description, // ✅ fixed
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
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
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
                  Text(author, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    description.isNotEmpty ? description : "Chưa có mô tả",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (tag.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tag == "Mới" ? Colors.blue[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tag == "Mới" ? Colors.blue : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title, {
    String? subtitle,
    Widget? subtitleWidget,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle:
          subtitleWidget ??
          (subtitle != null
              ? Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                )
              : null),
      onTap: onTap,
    );
  }
}

Future<int> getFavoriteCount() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final snapshot = await FirebaseFirestore.instance
      .collection("favorites")
      .where("user_id", isEqualTo: userId)
      .get();
  return snapshot.docs.length;
}

Future<int> getBorrowedTotal() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final snapshot = await FirebaseFirestore.instance
      .collection("borrowed_books")
      .where("user_id", isEqualTo: userId)
      .get();
  return snapshot.docs.length;
}

Future<int> getCurrentlyBorrowing() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final snapshot = await FirebaseFirestore.instance
      .collection("borrowed_books")
      .where("user_id", isEqualTo: userId)
      .where("status", isEqualTo: "đang mượn")
      .get();
  return snapshot.docs.length;
}
