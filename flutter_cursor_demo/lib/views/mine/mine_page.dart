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

class _MinePageState extends State<MinePage> {
  late UserViewModel _viewModel;
  bool _isInitialized = false;
  
  @override
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
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 实现设置功能
            },
          ),
        ],
      ),
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: _init,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildUserHeader(context, viewModel),
                  SizedBox(height: 16.h),
                  _buildFunctionList(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildUserHeader(BuildContext context, UserViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(24.r),
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
    
    return Row(
      children: [
        CircleAvatar(
          radius: 40.r,
          backgroundColor: Colors.white,
          child: Text(
            user?.username?.substring(0, 1).toUpperCase() ?? 'U',
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.username ?? '用户',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'ID: ${user?.id ?? ''}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            await _showLogoutDialog(context, viewModel);
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          child: Text(
            '退出登录',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNotLoggedInHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40.r,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            size: 40.r,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            '未登录',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            context.push(AppRoutes.login);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          child: Text(
            '登录/注册',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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
            // TODO: 实现收藏功能
          },
        ),
        _buildFunctionItem(
          icon: Icons.history,
          title: '浏览历史',
          onTap: () {
            // TODO: 实现浏览历史功能
          },
        ),
        _buildFunctionItem(
          icon: Icons.star,
          title: '积分排行',
          onTap: () {
            // TODO: 实现积分排行功能
          },
        ),
        _buildFunctionItem(
          icon: Icons.share,
          title: '分享',
          onTap: () {
            // TODO: 实现分享功能
          },
        ),
        _buildFunctionItem(
          icon: Icons.info,
          title: '关于我们',
          onTap: () {
            // TODO: 实现关于我们功能
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
} 