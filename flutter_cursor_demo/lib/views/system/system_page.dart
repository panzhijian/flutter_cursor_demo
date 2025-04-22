import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_cursor_demo/models/tree.dart';
import 'package:flutter_cursor_demo/viewmodels/system_viewmodel.dart';
import 'package:flutter_cursor_demo/widgets/article_item.dart';
import 'package:flutter_cursor_demo/routes/app_routes.dart';

class SystemPage extends StatefulWidget {
  const SystemPage({Key? key}) : super(key: key);

  @override
  State<SystemPage> createState() => _SystemPageState();
}

class _SystemPageState extends State<SystemPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late SystemViewModel _viewModel;
  late TabController _tabController;
  final EasyRefreshController _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  bool _isInitialized = false;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _viewModel = context.read<SystemViewModel>();
    _tabController = TabController(length: 0, vsync: this);
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.initData();
      _updateTabController();
    });
  }
  
  void _updateTabController() {
    final tree = _viewModel.selectedTree;
    if (tree != null && tree.children.isNotEmpty) {
      setState(() {
        _tabController = TabController(
          length: tree.children.length,
          vsync: this,
        );
        _tabController.addListener(_handleTabChange);
      });
    }
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final tree = _viewModel.selectedTree;
      if (tree != null && tree.children.isNotEmpty && _tabController.index < tree.children.length) {
        final subTree = tree.children[_tabController.index];
        _viewModel.selectSubTree(subTree);
        
        // 切换分类时重置刷新状态
        _refreshController.resetFooter();
        _refreshController.resetHeader();
      }
    }
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<SystemViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('体系'),
            actions: [
              IconButton(
                icon: const Icon(Icons.category),
                onPressed: () {
                  _showTreeSelectionDialog(context, viewModel);
                },
              ),
            ],
            bottom: viewModel.selectedTree != null && viewModel.selectedTree!.children.isNotEmpty
                ? TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: viewModel.selectedTree!.children.map((subTree) {
                      return Tab(text: subTree.name);
                    }).toList(),
                  )
                : null,
          ),
          body: _buildBody(viewModel),
        );
      },
    );
  }
  
  Widget _buildBody(SystemViewModel viewModel) {
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
    
    if (viewModel.trees.isEmpty) {
      return const Center(
        child: Text('暂无数据'),
      );
    }
    
    if (viewModel.selectedSubTree == null) {
      return Center(
        child: Text(
          '请选择分类',
          style: TextStyle(fontSize: 16.sp),
        ),
      );
    }
    
    return EasyRefresh.builder(
      controller: _refreshController,
      header: const ClassicHeader(
        dragText: '下拉刷新',
        armedText: '释放刷新',
        readyText: '正在刷新...',
        processingText: '正在刷新...',
        processedText: '刷新完成',
        failedText: '刷新失败',
        messageText: '最后更新于 %T',
        showMessage: true,
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
        showMessage: true,
      ),
      onRefresh: () async {
        try {
          await viewModel.refreshData();
          if (viewModel.hasError) {
            _refreshController.finishRefresh(IndicatorResult.fail);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(viewModel.errorMessage)),
              );
            }
          } else {
            _refreshController.finishRefresh(IndicatorResult.success);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('刷新成功')),
              );
            }
          }
        } catch (e) {
          _refreshController.finishRefresh(IndicatorResult.fail);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('刷新失败: $e')),
            );
          }
        }
      },
      onLoad: () async {
        try {
          if (!viewModel.hasMore) {
            _refreshController.finishLoad(IndicatorResult.noMore);
            return;
          }
          
          await viewModel.loadMoreArticles();
          if (viewModel.hasError) {
            _refreshController.finishLoad(IndicatorResult.fail);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(viewModel.errorMessage)),
              );
            }
          } else if (!viewModel.hasMore) {
            _refreshController.finishLoad(IndicatorResult.noMore);
          } else {
            _refreshController.finishLoad(IndicatorResult.success);
          }
        } catch (e) {
          _refreshController.finishLoad(IndicatorResult.fail);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('加载更多失败: $e')),
            );
          }
        }
      },
      childBuilder: (context, physics) {
        return viewModel.articles.isEmpty 
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('该分类下暂无文章'),
                ),
              )
            : ListView.builder(
                physics: physics,
                itemCount: viewModel.articles.length,
                itemBuilder: (context, index) {
                  final article = viewModel.articles[index];
                  return ArticleItem(article: article);
                },
              );
      },
    );
  }
  
  void _showTreeSelectionDialog(BuildContext context, SystemViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择分类'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: viewModel.trees.length,
              itemBuilder: (context, index) {
                final tree = viewModel.trees[index];
                return ListTile(
                  title: Text(tree.name),
                  selected: viewModel.selectedTree?.id == tree.id,
                  onTap: () {
                    viewModel.selectTree(tree);
                    Navigator.of(context).pop();
                    _updateTabController();
                    
                    // 切换主分类时重置刷新状态
                    _refreshController.resetFooter();
                    _refreshController.resetHeader();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }
} 