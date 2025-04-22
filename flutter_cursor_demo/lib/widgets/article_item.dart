import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cursor_demo/models/article.dart';
import 'package:flutter_cursor_demo/routes/app_routes.dart';
import 'package:flutter_cursor_demo/viewmodels/home_viewmodel.dart';
import 'package:flutter_cursor_demo/viewmodels/system_viewmodel.dart';
import 'package:flutter_cursor_demo/viewmodels/user_viewmodel.dart';

class ArticleItem extends StatelessWidget {
  final Article article;
  final bool isInCollectPage;
  
  const ArticleItem({
    Key? key, 
    required this.article,
    this.isInCollectPage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      article.title ?? '',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (!isInCollectPage) _buildCollectButton(context),
                ],
              ),
              SizedBox(height: 8.h),
              if (article.desc != null && article.desc!.isNotEmpty)
                Text(
                  article.desc!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.person, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    article.author != null && article.author!.isNotEmpty
                        ? article.author!
                        : (article.shareUser ?? ''),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.access_time, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    article.niceDate ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: [
                  if (article.superChapterName != null)
                    _buildTag(article.superChapterName!),
                  if (article.chapterName != null)
                    _buildTag(article.chapterName!),
                  ...article.tags.map((tag) => _buildTag(tag.name ?? '')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCollectButton(BuildContext context) {
    // 使用 Consumer 而不是 Provider.of 以保证能够正确监听登录状态的变化
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        return InkWell(
          onTap: () {
            if (!userViewModel.isLoggedIn) {
              _showNeedLoginDialog(context);
              return;
            }
            
            // 根据不同页面使用不同的ViewModel来处理收藏/取消收藏
            if (isInCollectPage) {
              // 收藏页面使用UserViewModel
              _handleCollectInFavoritePage(context);
            } else {
              // 判断是在首页还是在体系页
              final routeLocation = GoRouterState.of(context).matchedLocation;
              if (routeLocation.startsWith(AppRoutes.system)) {
                _handleCollectInSystemPage(context);
              } else {
                _handleCollectInHomePage(context);
              }
            }
          },
          child: Icon(
            article.collect ? Icons.favorite : Icons.favorite_border,
            color: article.collect ? Colors.red : Colors.grey,
            size: 20.sp,
          ),
        );
      },
    );
  }
  
  void _handleCollectInHomePage(BuildContext context) async {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    
    // 震动反馈
    HapticFeedback.mediumImpact();
    
    // 根据当前收藏状态执行收藏或取消收藏
    if (article.collect) {
      // 已收藏，执行取消收藏
      final success = await homeViewModel.uncollectArticle(article);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('取消收藏成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(homeViewModel.errorMessage)),
        );
      }
    } else {
      // 未收藏，执行收藏
      final success = await homeViewModel.collectArticle(article);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('收藏成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(homeViewModel.errorMessage)),
        );
      }
    }
  }
  
  void _handleCollectInSystemPage(BuildContext context) async {
    final systemViewModel = Provider.of<SystemViewModel>(context, listen: false);
    
    // 震动反馈
    HapticFeedback.mediumImpact();
    
    // 根据当前收藏状态执行收藏或取消收藏
    if (article.collect) {
      // 已收藏，执行取消收藏
      final success = await systemViewModel.uncollectArticle(article);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('取消收藏成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(systemViewModel.errorMessage)),
        );
      }
    } else {
      // 未收藏，执行收藏
      final success = await systemViewModel.collectArticle(article);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('收藏成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(systemViewModel.errorMessage)),
        );
      }
    }
  }
  
  void _handleCollectInFavoritePage(BuildContext context) async {
    // 在收藏页面只有取消收藏的操作
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    
    // 震动反馈
    HapticFeedback.mediumImpact();
    
    final success = await userViewModel.uncollectArticle(article);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('取消收藏成功')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userViewModel.errorMessage)),
      );
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
  
  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.blue,
        ),
      ),
    );
  }
  
  void _onTap(BuildContext context) {
    // 获取文章链接
    String url = '';
    if (article.link != null && article.link!.isNotEmpty) {
      url = article.link!;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开文章，链接为空')),
      );
      return;
    }
    
    // 导航到文章详情页
    final String uri = Uri(
      path: AppRoutes.articleDetail,
      queryParameters: {
        'id': article.id.toString(),
        'title': article.title ?? '',
        'url': url,
      },
    ).toString();
    context.push(uri);
  }
} 