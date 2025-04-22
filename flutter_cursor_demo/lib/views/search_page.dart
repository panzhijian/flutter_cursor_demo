import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:easy_refresh/easy_refresh.dart';

import 'package:flutter_cursor_demo/viewmodels/search_viewmodel.dart';
import 'package:flutter_cursor_demo/widgets/search_article_item.dart';
import 'package:flutter_cursor_demo/models/hot_keyword.dart';

class SearchPage extends StatefulWidget {
  final SearchType initialSearchType;
  final String? initialKeyword;
  
  const SearchPage({
    Key? key,
    this.initialSearchType = SearchType.keyword,
    this.initialKeyword,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late SearchViewModel _viewModel;
  late TextEditingController _searchController;
  final EasyRefreshController _refreshController = EasyRefreshController();
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _viewModel = context.read<SearchViewModel>();
    _searchController = TextEditingController(text: widget.initialKeyword ?? '');
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
    // 清除之前的搜索结果，确保显示热词页面
    _viewModel.clearSearchResults();
    await _viewModel.init();
    
    // 如果有初始关键词，直接执行搜索
    if (widget.initialKeyword != null && widget.initialKeyword!.isNotEmpty) {
      if (widget.initialSearchType == SearchType.keyword) {
        await _viewModel.searchByKeyword(widget.initialKeyword!);
      } else {
        await _viewModel.searchByAuthor(widget.initialKeyword!);
      }
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  // 添加搜索处理方法
  void _performSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    
    FocusScope.of(context).unfocus(); // 隐藏键盘
    
    if (widget.initialSearchType == SearchType.author) {
      _viewModel.searchByAuthor(keyword.trim());
    } else {
      _viewModel.searchByKeyword(keyword.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _buildSearchField(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<SearchViewModel>(
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
          
          if (viewModel.searchResults.isEmpty) {
            // 显示热词
            return _buildHotKeywords(viewModel);
          }
          
          // 显示搜索结果
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
              if (viewModel.searchType == SearchType.keyword) {
                await viewModel.searchByKeyword(viewModel.currentKeyword);
              } else {
                await viewModel.searchByAuthor(viewModel.currentKeyword);
              }
            },
            onLoad: () async {
              await viewModel.loadMore();
            },
            child: ListView.builder(
              itemCount: viewModel.searchResults.length,
              itemBuilder: (context, index) {
                final article = viewModel.searchResults[index];
                return SearchArticleItem(article: article);
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSearchField() {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        style: TextStyle(fontSize: 16.sp),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.initialSearchType == SearchType.author 
              ? '输入作者昵称搜索' 
              : '搜索关键词',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20.r),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.clear, color: Colors.grey[600], size: 18.r),
                  onPressed: () {
                    _searchController.clear();
                    _viewModel.clearSearchResults();
                  },
                ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 4.w),
          isDense: true,
        ),
        onSubmitted: (value) {
          _performSearch(value);
        },
        onChanged: (value) {
          setState(() {}); // 触发重新渲染以显示/隐藏清除按钮
        },
      ),
    );
  }
  
  Widget _buildHotKeywords(SearchViewModel viewModel) {
    if (viewModel.hotKeywords.isEmpty) {
      return const Center(
        child: Text('暂无热搜词'),
      );
    }
    
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.whatshot, color: Colors.redAccent, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                '热门搜索',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: viewModel.hotKeywords.map((keyword) {
              return InkWell(
                onTap: () {
                  _searchController.text = keyword.name;
                  _performSearch(keyword.name);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    keyword.name,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
} 