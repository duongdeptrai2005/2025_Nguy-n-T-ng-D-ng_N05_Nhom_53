import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_club_detail.dart';

class BookClubsScreen extends StatefulWidget {
  const BookClubsScreen({super.key});

  @override
  State<BookClubsScreen> createState() => _BookClubsScreenState();
}

class _BookClubsScreenState extends State<BookClubsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _joinClub(String clubId) async {
    final uid = _auth.currentUser!.uid;
    final clubRef = _firestore.collection('book_clubs').doc(clubId);

    await clubRef.update({
      'members': FieldValue.arrayUnion([uid]),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Tham gia câu lạc bộ thành công!")),
    );
  }

  Future<void> _createClub() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Tạo câu lạc bộ mới", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Tên CLB",
                prefixIcon: Icon(Icons.book),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Mô tả CLB",
                prefixIcon: Icon(Icons.info_outline),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final uid = _auth.currentUser!.uid;
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              if (name.isEmpty || desc.isEmpty) return;

              await _firestore.collection('book_clubs').add({
                'name': name,
                'description': desc,
                'members': [uid],
                'createdBy': uid,
                'roleByUser': {uid: "Quản trị viên"},
                'createdAt': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Tạo câu lạc bộ thành công!")),
              );
            },
            child: const Text("Tạo", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getColor(String clubId) {
    final colors = [Colors.blue, Colors.purple, Colors.green, Colors.pink, Colors.orange];
    return colors[clubId.hashCode % colors.length].withOpacity(0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text("Câu lạc bộ sách", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.group_add, color: Colors.white),
                onPressed: _createClub,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                label: const Text(
                  "Tham gia / Tạo câu lạc bộ",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('book_clubs')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Chưa có câu lạc bộ nào.\nHãy là người đầu tiên tạo nhé!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final clubs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: clubs.length,
                  itemBuilder: (context, index) {
                    final club = clubs[index];
                    final clubId = club.id;
                    final members = List<String>.from(club['members'] ?? []);
                    final uid = _auth.currentUser!.uid;
                    final isMember = members.contains(uid);
                    final roleByUser = Map<String, dynamic>.from(club['roleByUser'] ?? {});
                    final role = roleByUser[uid] ?? "Thành viên";

                    Color roleColor;
                    switch (role) {
                      case "Quản trị viên":
                        roleColor = Colors.redAccent.shade100;
                        break;
                      case "Người điều hành":
                        roleColor = Colors.orangeAccent.shade100;
                        break;
                      default:
                        roleColor = Colors.blueAccent.shade100;
                    }

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (isMember) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ClubDetailScreen(clubId: clubId)),
                            );
                          } else {
                            _joinClub(clubId);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: _getColor(clubId),
                                child: const Icon(Icons.book, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      club['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      club['description'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.people, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${members.length} thành viên",
                                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: roleColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            role,
                                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  if (isMember) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => ClubDetailScreen(clubId: clubId)),
                                    );
                                  } else {
                                    _joinClub(clubId);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isMember ? Colors.grey[850] : Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  isMember ? "Truy cập" : "Tham gia",
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
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
