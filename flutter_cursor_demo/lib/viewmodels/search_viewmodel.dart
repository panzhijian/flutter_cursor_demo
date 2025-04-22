import 'package:flutter/material.dart';
import 'package:flutter_cursor_demo/models/hot_keyword.dart';
import 'package:flutter_cursor_demo/models/article.dart';
import 'package:flutter_cursor_demo/models/page_data.dart';
import 'package:flutter_cursor_demo/services/search_service.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchService _searchService = SearchService();
  
  // 热词列表
  List<HotKeyword> _hotKeywords = [];
  List<HotKeyword> get hotKeywords => _hotKeywords;
  
  // 搜索结果
  List<Article> _searchResults = [];
  List<Article> get searchResults => _searchResults;
  
  // 当前搜索关键词
  String _currentKeyword = '';
  String get currentKeyword => _currentKeyword;
  
  // 是否正在加载
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // 是否正在加载更多
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  
  // 是否有错误
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  
  // 分页数据
  PageData<Article>? _pageData;
  bool get hasMore => _pageData?.over == false;
  
  // 当前页码
  int _currentPage = 0;
  
  // 搜索类型
  SearchType _searchType = SearchType.keyword;
  SearchType get searchType => _searchType;
  
  // 初始化 - 获取热词
  Future<void> init() async {
    _setLoading(true);
    _errorMessage = '';
    try {
      _hotKeywords = await _searchService.getHotKeywords();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  // 按关键词搜索
  Future<void> searchByKeyword(String keyword, {bool refresh = true}) async {
    if (keyword.isEmpty) {
      return;
    }
    
    _currentKeyword = keyword;
    _searchType = SearchType.keyword;
    
    if (refresh) {
      _setLoading(true);
      _currentPage = 0;
      _searchResults = [];
    } else {
      _isLoadingMore = true;
      _currentPage++;
    }
    
    _errorMessage = '';
    notifyListeners();
    
    try {
      final pageData = await _searchService.searchByKeyword(keyword, _currentPage);
      
      if (refresh) {
        _searchResults = pageData.datas;
        _pageData = pageData;
      } else {
        _searchResults.addAll(pageData.datas);
        _pageData = _pageData!.copyWith(
          curPage: pageData.curPage,
          over: pageData.over,
        );
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      if (!refresh) {
        _currentPage--;
      }
      notifyListeners();
    } finally {
      if (refresh) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }
  
  // 按作者搜索
  Future<void> searchByAuthor(String author, {bool refresh = true}) async {
    if (author.isEmpty) {
      return;
    }
    
    _currentKeyword = author;
    _searchType = SearchType.author;
    
    if (refresh) {
      _setLoading(true);
      _currentPage = 0;
      _searchResults = [];
    } else {
      _isLoadingMore = true;
      _currentPage++;
    }
    
    _errorMessage = '';
    notifyListeners();
    
    try {
      final pageData = await _searchService.searchByAuthor(author, _currentPage);
      
      if (refresh) {
        _searchResults = pageData.datas;
        _pageData = pageData;
      } else {
        _searchResults.addAll(pageData.datas);
        _pageData = _pageData!.copyWith(
          curPage: pageData.curPage,
          over: pageData.over,
        );
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      if (!refresh) {
        _currentPage--;
      }
      notifyListeners();
    } finally {
      if (refresh) {
        _setLoading(false);
      } else {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }
  
  // 加载更多搜索结果
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) {
      return;
    }
    
    if (_searchType == SearchType.keyword) {
      await searchByKeyword(_currentKeyword, refresh: false);
    } else {
      await searchByAuthor(_currentKeyword, refresh: false);
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  // 清除搜索结果
  void clearSearchResults() {
    _searchResults = [];
    _pageData = null;
    _currentPage = 0;
    _currentKeyword = '';
    _errorMessage = '';
    notifyListeners();
  }
}

enum SearchType {
  keyword,
  author,
} 