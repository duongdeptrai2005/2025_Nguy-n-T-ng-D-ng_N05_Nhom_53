class AppData {
  // Danh sách sách
  static List<Map<String, dynamic>> books = [
    {"title": "Sách Ngữ Văn lớp 6 tập 2", "quantity": 10},
    {"title": "Sách Toán lớp 7 tập 1", "quantity": 5},
    {"title": "Sách Lịch sử lớp 9", "quantity": 3},
  ];

  // Danh sách độc giả
  static List<Map<String, dynamic>> readers = [
    {"id": "DG001", "name": "Nguyễn Văn A"},
    {"id": "DG002", "name": "Trần Thị B"},
  ];

  // Danh sách phiếu mượn
  static List<Map<String, dynamic>> borrowTickets = [];

  // Hàm thêm phiếu mượn
  static void addBorrowTicket({
    required String readerId,
    required String bookTitle,
    required DateTime borrowDate,
    required DateTime returnDate,
  }) {
    borrowTickets.add({
      "readerId": readerId,
      "bookTitle": bookTitle,
      "borrowDate": borrowDate,
      "returnDate": returnDate,
    });
  }

  // Hàm xóa phiếu mượn
  static void deleteBorrowTicket(int index) {
    borrowTickets.removeAt(index);
  }
}
