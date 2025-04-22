import 'package:flutter/foundation.dart';
import 'package:flutter_cursor_demo/config/app_config.dart';
import 'package:flutter_cursor_demo/models/article.dart';
import 'package:flutter_cursor_demo/models/banner.dart';
import 'package:flutter_cursor_demo/models/page_data.dart';
import 'package:flutter_cursor_demo/services/http_service.dart';

class HomeViewModel extends ChangeNotifier {
  final HttpService _httpService = HttpService();
  
  // Banner数据
  List<BannerItem> _banners = [];
  List<BannerItem> get banners => _banners;
  
  // 文章数据
  PageData<Article>? _articlePageData;
  List<Article> get articles => _articlePageData?.datas ?? [];
  bool get hasMore => _articlePageData?.over == false;
  
  // 加载状态
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  
  // 错误信息
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  
  // 当前页码
  int _currentPage = 0;
  
  // 初始化数据
  Future<void> initData() async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      await Future.wait([
        _fetchBanners(),
        _fetchArticles(refresh: true),
      ]);
    } catch (e) {
      _errorMessage = '加载失败: $e';
    } finally {
      _setLoading(false);
    }
  }
  
  // 刷新数据
  Future<void> refreshData() async {
    _errorMessage = '';
    
    try {
      await Future.wait([
        _fetchBanners(),
        _fetchArticles(refresh: true),
      ]);
    } catch (e) {
      _errorMessage = '刷新失败: $e';
    }
  }
  
  // 加载更多文章
  Future<void> loadMoreArticles() async {
    if (_isLoadingMore || !hasMore) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      await _fetchArticles();
    } catch (e) {
      _errorMessage = '加载更多失败: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  // 获取轮播图数据
  Future<void> _fetchBanners() async {
    try {
      final response = await _httpService.get(AppConfig.homeBanner);
      if (response['errorCode'] == 0) {
        final List<dynamic> data = response['data'];
        _banners = data.map((item) => BannerItem.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(response['errorMsg'] ?? '获取轮播图失败');
      }
    } catch (e) {
      throw Exception('获取轮播图失败: $e');
    }
  }
  
  // 获取文章列表
  Future<void> _fetchArticles({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
    } else {
      _currentPage++;
    }
    
    final String path = AppConfig.homeArticleList.replaceFirst('{page}', _currentPage.toString());
    
    try {
      final response = await _httpService.get(path);
      if (response['errorCode'] == 0) {
        final data = response['data'];
        final pageData = PageData<Article>.fromJson(data, (json) => Article.fromJson(json));
        
        if (refresh || _articlePageData == null) {
          _articlePageData = pageData;
        } else {
          _articlePageData = _articlePageData!.copyWith(
            curPage: pageData.curPage,
            over: pageData.over,
            appendDatas: pageData.datas,
          );
        }
        
        notifyListeners();
      } else {
        throw Exception(response['errorMsg'] ?? '获取文章列表失败');
      }
    } catch (e) {
      if (refresh) {
        _currentPage = 0;
      } else {
        _currentPage--;
      }
      throw Exception('获取文章列表失败: $e');
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
} 