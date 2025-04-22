import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';

import 'package:flutter_cursor_demo/viewmodels/user_viewmodel.dart';
import 'package:flutter_cursor_demo/widgets/article_item.dart';

class CollectPage extends StatefulWidget {
  const CollectPage({Key? key}) : super(key: key);

  @override
  State<CollectPage> createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> {
  late UserViewModel _viewModel;
  final EasyRefreshController _refreshController = EasyRefreshController();
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
      _viewModel.getCollectList(refresh: true);
    });
  }
  
  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        elevation: 0,
      ),
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _init,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }
          
          if (viewModel.collectArticles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.collections_bookmark_outlined,
                    size: 80.r,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '暂无收藏',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return EasyRefresh(
            controller: _refreshController,
            header: const ClassicHeader(
              dragText: '下拉刷新',
              armedText: '释放刷新',
              readyText: '正在刷新...',
              processingText: '正在刷新...',
              processedText: '刷新完成',
              failedText: '刷新失败',
              messageText: '最后更新于 %T',
            ),
            footer: const ClassicFooter(
              dragText: '上拉加载',
              armedText: '释放加载',
              readyText: '正在加载...',
              processingText: '正在加载...',
              processedText: '加载完成',
              failedText: '加载失败',
              noMoreText: '没有更多数据',
              messageText: '最后更新于 %T',
            ),
            onRefresh: () async {
              await viewModel.getCollectList(refresh: true);
            },
            onLoad: () async {
              if (viewModel.hasMoreCollects) {
                await viewModel.getCollectList(refresh: false);
              }
            },
            child: ListView.builder(
              itemCount: viewModel.collectArticles.length,
              itemBuilder: (context, index) {
                final article = viewModel.collectArticles[index];
                // 在收藏页面使用isInCollectPage=true
                return ArticleItem(
                  article: article,
                  isInCollectPage: true,
                );
              },
            ),
          );
        },
      ),
    );
  }
} 