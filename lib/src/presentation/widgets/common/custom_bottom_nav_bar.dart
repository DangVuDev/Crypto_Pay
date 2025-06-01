import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Mô hình dữ liệu cho mỗi mục trong thanh điều hướng
class BottomNavItem {
  final IconData icon;
  final String label;
  final String path;

  const BottomNavItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}

/// Thanh điều hướng dưới cùng tùy chỉnh
class CustomBottomNavBar extends StatelessWidget {
  final String currentLocation;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentLocation,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF121212),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: items.indexWhere((item) => item.path == currentLocation),
        onTap: (index) {
          onTap(index);
          final selectedItem = items[index];
          if (GoRouter.of(context).location != selectedItem.path) {
            context.go(selectedItem.path);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF627EEA), // Màu chọn mặc định (ETH)
        unselectedItemColor: Colors.white.withOpacity(0.7),
        selectedIconTheme: const IconThemeData(size: 24, color: Color(0xFF627EEA)),
        unselectedIconTheme: const IconThemeData(size: 20, color: Colors.white70),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        items: items.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.icon, color: const Color(0xFF627EEA)),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

extension on GoRouter {
  get location => null;
}