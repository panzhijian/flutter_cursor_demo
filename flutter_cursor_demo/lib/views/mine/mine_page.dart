import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_cursor_demo/viewmodels/user_viewmodel.dart';
import 'package:flutter_cursor_demo/routes/app_routes.dart';

class MinePage extends StatefulWidget {
  const MinePage({Key? key}) : super(key: key);

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> with AutomaticKeepAliveClientMixin {
  late UserViewModel _viewModel;
  bool _isInitialized = false;
  
  @override
  bool get wantKeepAlive => true;
  
  void initState() {
    super.initState();
    _viewModel = context.read<UserViewModel>();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _init();
      _isInitialized = true;
    }
  }
  
  Future<void> _init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: _init,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: viewModel.isLoggedIn ? 3 : 3, // 根据登录状态调整项目数量
              itemBuilder: (context, index) {
                if (index == 0) {
                  // 用户信息头部
                  return _buildUserHeader(context, viewModel);
                } else if (index == 1) {
                  // 功能列表
                  return _buildFunctionList(context, viewModel);
                } else {
                  // 登录/注册按钮区域（如果未登录）
                  return _buildLoginButtonArea(context, viewModel);
                }
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildUserHeader(BuildContext context, UserViewModel viewModel) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.r, 40.r, 24.r, 24.r), // 增加上边距
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: viewModel.isLoggedIn
          ? _buildLoggedInHeader(context, viewModel)
          : _buildNotLoggedInHeader(context),
    );
  }
  
  Widget _buildLoggedInHeader(BuildContext context, UserViewModel viewModel) {
    final user = viewModel.currentUser;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80.r,
          height: 80.r,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: FlutterLogo(
              size: 60.r,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          user?.username ?? '用户',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
  
  Widget _buildNotLoggedInHeader(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.login);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FlutterLogo(
                size: 60.r,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '未登录',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoginButtonArea(BuildContext context, UserViewModel viewModel) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
      child: ElevatedButton(
        onPressed: () {
          if (viewModel.isLoggedIn) {
            _showLogoutDialog(context, viewModel);
          } else {
            context.push(AppRoutes.login);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          viewModel.isLoggedIn ? '退出登录' : '登录/注册',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildFunctionList(BuildContext context, UserViewModel viewModel) {
    return Column(
      children: [
        _buildFunctionItem(
          icon: Icons.favorite,
          title: '我的收藏',
          onTap: () {
            if (!viewModel.isLoggedIn) {
              _showNeedLoginDialog(context);
              return;
            }
            context.push(AppRoutes.collect);
          },
        ),
        _buildFunctionItem(
          icon: Icons.info,
          title: '关于我们',
          onTap: () {
            _showAboutDialog(context);
          },
        ),
      ],
    );
  }
  
  Widget _buildFunctionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  
  Future<void> _showLogoutDialog(BuildContext context, UserViewModel viewModel) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    if (result == true && mounted) {
      final success = await viewModel.logout();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已退出登录')),
        );
      }
    }
  }
  
  void _showNeedLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('该功能需要登录后使用'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.login);
            },
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于我们'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('应用名称: Flutter Cursor Demo'),
            SizedBox(height: 8.h),
            Text('版本: 1.0.0'),
            SizedBox(height: 8.h),
            Text('这是一个基于WanAndroid API开发的Flutter示例应用，展示了Flutter应用开发的基本架构和功能实现。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
} 