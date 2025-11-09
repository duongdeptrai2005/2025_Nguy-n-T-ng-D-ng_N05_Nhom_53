import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.white),
            SizedBox(width: 8),
            Text("Cài đặt", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Thông tin người dùng
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage('lib/assets/images/book_sample.png'),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Van Duc",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.logout, color: Colors.black),
                ),
              ],
            ),
          ),

          // Danh sách cài đặt
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const Text(
                  "Thiết lập tài khoản",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSettingItem("Chỉnh sửa thông tin", Icons.arrow_forward_ios),
                _buildSettingItem("Thay đổi mật khẩu", Icons.arrow_forward_ios),
                SwitchListTile(
                  title: const Text("Bật thông báo"),
                  value: true,
                  onChanged: (val) {},
                  activeColor: Colors.blue,
                ),
                SwitchListTile(
                  title: const Text("Tự động cập nhật"),
                  value: false,
                  onChanged: (val) {},
                ),
                const Divider(height: 32),
                const Text(
                  "Thông tin thêm",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSettingItem("Về chúng tôi", Icons.arrow_forward_ios),
                _buildSettingItem("Chính sách bảo mật", Icons.arrow_forward_ios),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNav(context, 4),
    );
  }

  Widget _buildSettingItem(String title, IconData icon) {
    return ListTile(
      title: Text(title),
      trailing: Icon(icon, size: 18),
      onTap: () {},
    );
  }
}
