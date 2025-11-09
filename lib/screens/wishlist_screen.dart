import 'package:flutter/material.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistScreen> {
  String filter = 'Tất cả';

  final List<Map<String, dynamic>> books = [
    {
      'title': 'The Great Gatsby',
      'author': 'F. Scott Fitzgerald',
      'color': Colors.blue,
      'status': 'Sẵn sàng',
      'available': true,
    },
    {
      'title': 'To Kill a Mockingbird',
      'author': 'Harper Lee',
      'color': Colors.purple,
      'status': 'Đã bị mượn',
      'available': false,
      'returnDate': '10/11',
    },
    {
      'title': '1984',
      'author': 'George Orwell',
      'color': Colors.red,
      'status': 'Có sẵn',
      'available': true,
    },
    {
      'title': 'Pride and Prejudice',
      'author': 'Jane Austen',
      'color': Colors.pink,
      'status': 'Đã bị mượn',
      'available': false,
      'returnDate': '10/11',
    },
    {
      'title': 'The Beautiful and Damned',
      'author': 'F. Scott Fitzgerald',
      'color': Colors.green,
      'status': 'Có sẵn',
      'available': true,
    },
    {
      'title': 'This Side of Paradise',
      'author': 'F. Scott Fitzgerald',
      'color': Colors.amber,
      'status': 'Đã bị mượn',
      'available': false,
      'returnDate': '10-11',
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredBooks = books.where((b) {
      if (filter == 'Tất cả') return true;
      if (filter == 'Có sẵn') return b['available'] == true;
      if (filter == 'Không') return b['available'] == false;
      return true;
    }).toList();

    int availableCount = books.where((b) => b['available']).length;
    int borrowedCount = books.length - availableCount;

    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),
      appBar: AppBar(
        title: const Text(
          'Danh sách mong muốn',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Thống kê
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Có sẵn', availableCount, Colors.green),
                _buildStatCard('Đã được mượn', borrowedCount, Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            // Bộ lọc
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: ['Tất cả', 'Có sẵn', 'Không'].map((type) {
                bool isActive = filter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isActive,
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (_) {
                      setState(() {
                        filter = type;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Danh sách sách
            Expanded(
              child: ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return _buildBookItem(book);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      width: 160,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBookItem(Map<String, dynamic> book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 65,
            decoration: BoxDecoration(
              color: book['color'],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  book['author'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: book['available']
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book['status'],
                        style: TextStyle(
                          color: book['available']
                              ? Colors.green
                              : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (book.containsKey('returnDate')) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Ngày trả dự kiến: ${book['returnDate']}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ]
                  ],
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                books.remove(book);
              });
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
