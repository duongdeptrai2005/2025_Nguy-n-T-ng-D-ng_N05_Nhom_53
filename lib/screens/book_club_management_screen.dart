import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookClubManagementScreen extends StatelessWidget {
  const BookClubManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final clubsQuery = FirebaseFirestore.instance
        .collection('book_clubs')
        .where('members', arrayContains: currentUser?.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Câu lạc bộ"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: clubsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Bạn chưa tham gia câu lạc bộ nào.",
                  style: TextStyle(fontSize: 16)),
            );
          }

          final clubs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              final name = club['name'] ?? 'Không tên';
              final description = club['description'] ?? 'Không có mô tả';
              final members = (club['members'] as List?)?.length ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.group,
                      color: Colors.blueAccent, size: 32),
                  title: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(
                    "$description\nThành viên: $members người",
                    style: const TextStyle(height: 1.4),
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClubMembersScreen(club: club),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ClubMembersScreen extends StatelessWidget {
  final QueryDocumentSnapshot club;
  const ClubMembersScreen({super.key, required this.club});

  Future<List<Map<String, dynamic>>> _fetchMembers() async {
    final members = List<String>.from(club['members'] ?? []);
    final roleByUser = Map<String, dynamic>.from(club['roleByUser'] ?? {});
    List<Map<String, dynamic>> memberList = [];

    for (var uid in members) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        memberList.add({
          'name': userData['name'] ?? 'Không rõ',
          'email': userData['email'] ?? '',
          'role': roleByUser[uid] ?? 'Thành viên',
        });
      }
    }

    return memberList;
  }

  @override
  Widget build(BuildContext context) {
    final clubName = club['name'] ?? 'Câu lạc bộ';

    return Scaffold(
      appBar: AppBar(
        title: Text("Thành viên: $clubName"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có thành viên nào."));
          }

          final members = snapshot.data!;

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blueAccent),
                  title: Text(member['name']),
                  subtitle: Text(member['email']),
                  trailing: Text(
                    member['role'],
                    style: TextStyle(
                      color: member['role'] == 'Quản trị viên'
                          ? Colors.redAccent
                          : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
