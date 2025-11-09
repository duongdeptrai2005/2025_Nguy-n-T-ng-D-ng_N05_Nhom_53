import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool twoFactorEnabled = false;
  bool loginNotifications = true;

  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt bảo mật"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Bật xác thực hai bước"),
            subtitle: const Text("Thêm một lớp bảo mật khi đăng nhập."),
            value: twoFactorEnabled,
            onChanged: (value) {
              setState(() => twoFactorEnabled = value);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Thông báo đăng nhập mới"),
            subtitle:
            const Text("Nhận thông báo khi tài khoản đăng nhập từ thiết bị lạ."),
            value: loginNotifications,
            onChanged: (value) {
              setState(() => loginNotifications = value);
            },
          ),

        ],
      ),
    );
  }
}
