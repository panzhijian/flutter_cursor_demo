import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_cursor_demo/routes/app_routes.dart';
import 'package:flutter_cursor_demo/views/home/home_page.dart';
import 'package:flutter_cursor_demo/views/system/system_page.dart';
import 'package:flutter_cursor_demo/views/mine/mine_page.dart';

class MainPage extends StatefulWidget {
  final Widget child;
  
  const MainPage({Key? key, required this.child}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const SystemPage(),
    const MinePage(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _getSelectedIndex(context),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12.sp,
        unselectedFontSize: 12.sp,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: '体系',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
  
  void _onItemTapped(int index, BuildContext context) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.system);
        break;
      case 2:
        context.go(AppRoutes.mine);
        break;
    }
  }
  
  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    
    if (location.startsWith(AppRoutes.home) || location == '/') {
      _currentIndex = 0;
    } else if (location.startsWith(AppRoutes.system)) {
      _currentIndex = 1;
    } else if (location.startsWith(AppRoutes.mine)) {
      _currentIndex = 2;
    }
    
    return _currentIndex;
  }
} 