import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Trợ giúp & Hỗ trợ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chúng tôi luôn sẵn sàng giúp bạn 💬",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Nếu bạn gặp bất kỳ vấn đề nào khi sử dụng ứng dụng, vui lòng xem các câu hỏi thường gặp hoặc liên hệ trực tiếp với chúng tôi.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),

            // Phần Câu hỏi thường gặp
            const Text(
              "Câu hỏi thường gặp (FAQ)",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              question: "Làm thế nào để mượn sách trong thư viện?",
              answer:
                  "Bạn chỉ cần chọn cuốn sách muốn mượn, nhấn nút 'Mượn' và xác nhận. Sau khi được duyệt, sách sẽ xuất hiện trong danh sách mượn của bạn.",
            ),
            _buildFAQItem(
              question: "Tôi có thể gia hạn sách đã mượn không?",
              answer:
                  "Có, bạn có thể gia hạn trong mục 'Danh sách mượn' nếu cuốn sách chưa được người khác đặt trước.",
            ),
            _buildFAQItem(
              question: "Tôi quên mật khẩu tài khoản, phải làm sao?",
              answer:
                  "Vui lòng chọn 'Quên mật khẩu' ở màn hình đăng nhập. Một email hướng dẫn đặt lại mật khẩu sẽ được gửi cho bạn.",
            ),

            const SizedBox(height: 28),
            const Divider(thickness: 1, color: Colors.black12),
            const SizedBox(height: 16),

            const Text(
              "Liên hệ hỗ trợ",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            _buildContactTile(
              icon: Icons.email_outlined,
              title: "Email",
              content: "support@libraryapp.com",
            ),
            _buildContactTile(
              icon: Icons.phone_outlined,
              title: "Hotline",
              content: "+84 123 456 789",
            ),
            _buildContactTile(
              icon: Icons.access_time,
              title: "Giờ làm việc",
              content: "Thứ 2 - Thứ 6: 8h00 - 17h30",
            ),

            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                label: const Text(
                  "Liên hệ ngay",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {
                  _showContactDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget phụ ---
  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ExpansionTile(
        iconColor: Colors.blueAccent,
        collapsedIconColor: Colors.black54,
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(content,
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Liên hệ hỗ trợ"),
        content: const Text(
          "Bạn có thể gửi email cho chúng tôi qua:\n📩 support@libraryapp.com\n\nHoặc gọi hotline: 📞 +84 123 456 789",
        ),
        actions: [
          TextButton(
            child: const Text("Đóng"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
