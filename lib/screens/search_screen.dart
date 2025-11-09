import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String query;

  const SearchScreen({super.key, required this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late String _searchQuery;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.query;
    _controller.text = _searchQuery;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "Tìm sách hoặc tác giả...",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value.trim();
            });
          },
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final books = snapshot.data!.docs.where((doc) {
            final title = (doc['title'] ?? '').toString().toLowerCase();
            final author = (doc['author'] ?? '').toString().toLowerCase();
            final query = _searchQuery.toLowerCase();
            return title.contains(query) || author.contains(query);
          }).toList();

          if (books.isEmpty) {
            return const Center(
              child: Text("Không tìm thấy sách phù hợp."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return _buildBookItem(
                title: book['title'] ?? 'Chưa có tên',
                author: book['author'] ?? 'Chưa có tác giả',
                tag: book['tag'] ?? '',
                imagePath: book['image'] ?? '',
                description: book['description'] ?? '',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookItem({
    required String title,
    required String author,
    required String tag,
    required String imagePath,
    required String description,
  }) {
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
              description: description,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          leading: imagePath.isNotEmpty
              ? (imagePath.startsWith('http')
              ? Image.network(imagePath, width: 50, height: 70, fit: BoxFit.cover)
              : Image.asset(imagePath, width: 50, height: 70, fit: BoxFit.cover))
              : null,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(author),
          trailing: tag.isNotEmpty
              ? Container(
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
          )
              : null,
        ),
      ),
    );
  }
}
