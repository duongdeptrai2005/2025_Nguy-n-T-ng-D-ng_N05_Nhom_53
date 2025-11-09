import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../widgets/bottom_nav.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? selectedReader;
  String? selectedBook;
  DateTime borrowDate = DateTime.now();
  DateTime returnDate = DateTime.now().add(const Duration(days: 7));

  void addBorrowTicket() {
    if (selectedReader == null || selectedBook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn độc giả và sách!")),
      );
      return;
    }

    AppData.addBorrowTicket(
      readerId: selectedReader!,
      bookTitle: selectedBook!,
      borrowDate: borrowDate,
      returnDate: returnDate,
    );

    setState(() {
      selectedReader = null;
      selectedBook = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Báo cáo - Phiếu mượn"),
        backgroundColor: Colors.blue[600],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======= FORM TẠO PHIẾU MƯỢN =======
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tạo phiếu mượn mới",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chọn độc giả
                  DropdownButtonFormField<String>(
                    value: selectedReader,
                    decoration: const InputDecoration(
                      labelText: "Chọn độc giả",
                      border: OutlineInputBorder(),
                    ),
                    items: AppData.readers.map((r) {
                      return DropdownMenuItem<String>(
                        value: r["id"] as String,
                        child: Text("${r["id"]} - ${r["name"]}"),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedReader = val),
                  ),

                  const SizedBox(height: 16),

                  // Chọn sách
                  DropdownButtonFormField<String>(
                    value: selectedBook,
                    decoration: const InputDecoration(
                      labelText: "Chọn sách",
                      border: OutlineInputBorder(),
                    ),
                    items: AppData.books.map((b) {
                      return DropdownMenuItem<String>(
                        value: b["title"] as String,
                        child: Text(b["title"]),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedBook = val),
                  ),

                  const SizedBox(height: 16),

                  // Chọn ngày mượn
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Ngày mượn",
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: borrowDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() => borrowDate = date);
                                }
                              },
                            ),
                          ),
                          controller: TextEditingController(
                            text:
                                "${borrowDate.day}/${borrowDate.month}/${borrowDate.year}",
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Ngày trả",
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: returnDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() => returnDate = date);
                                }
                              },
                            ),
                          ),
                          controller: TextEditingController(
                            text:
                                "${returnDate.day}/${returnDate.month}/${returnDate.year}",
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Nút thêm phiếu mượn
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Thêm phiếu mượn"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: addBorrowTicket,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ======= DANH SÁCH PHIẾU MƯỢN =======
            const Text(
              "Danh sách phiếu mượn",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            AppData.borrowTickets.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Chưa có phiếu mượn nào",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: AppData.borrowTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = AppData.borrowTickets[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.book, color: Colors.blue),
                          title: Text(ticket["bookTitle"]),
                          subtitle: Text(
                            "Độc giả: ${ticket["readerId"]}\n"
                            "Mượn: ${ticket["borrowDate"].toString().substring(0, 10)} - "
                            "Trả: ${ticket["returnDate"].toString().substring(0, 10)}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                AppData.deleteBorrowTicket(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNav(context, 2),
    );
  }
}
