import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/book_screen.dart';
import '../screens/report_screen.dart';
import '../screens/reader_screen.dart';
import '../screens/settings_screen.dart';

Widget buildBottomNav(BuildContext context, int currentIndex) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    selectedItemColor: Colors.blue[700],
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    onTap: (index) {
      if (index == currentIndex) return; // tránh reload lại trang hiện tại
      Widget nextPage;
      switch (index) {
        case 0:
          nextPage = const HomeScreen();
          break;
        case 1:
          nextPage = const BookScreen();
          break;
        case 2:
          nextPage = const ReportScreen();
          break;
        case 3:
          nextPage = const ReaderScreen();
          break;
        case 4:
          nextPage = const SettingsScreen();
          break;
        default:
          nextPage = const HomeScreen();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextPage),
      );
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
      BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Sách"),
      BottomNavigationBarItem(icon: Icon(Icons.article), label: "Báo cáo"),
      BottomNavigationBarItem(icon: Icon(Icons.people), label: "Độc giả"),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Cài đặt"),
    ],
  );
}
