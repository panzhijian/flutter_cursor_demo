import 'package:flutter/foundation.dart';
import 'package:flutter_cursor_demo/config/app_config.dart';
import 'package:flutter_cursor_demo/models/tree.dart';
import 'package:flutter_cursor_demo/models/article.dart';
import 'package:flutter_cursor_demo/models/page_data.dart';
import 'package:flutter_cursor_demo/services/http_service.dart';

class SystemViewModel extends ChangeNotifier {
  final HttpService _httpService = HttpService();
  
  // 体系树数据
  List<Tree> _trees = [];
  List<Tree> get trees => _trees;
  
  // 当前选中的体系
  Tree? _selectedTree;
  Tree? get selectedTree => _selectedTree;
  
  // 当前选中的子体系
  Tree? _selectedSubTree;
  Tree? get selectedSubTree => _selectedSubTree;
  
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
      await _fetchTreeData();
      if (_trees.isNotEmpty) {
        selectTree(_trees[0]);
      }
    } catch (e) {
      _errorMessage = '加载失败: $e';
    } finally {
      _setLoading(false);
    }
  }
  
  // 选择体系
  void selectTree(Tree tree) {
    _selectedTree = tree;
    if (tree.children.isNotEmpty) {
      selectSubTree(tree.children[0]);
    } else {
      _selectedSubTree = null;
      _articlePageData = null;
    }
    notifyListeners();
  }
  
  // 选择子体系
  Future<void> selectSubTree(Tree subTree) async {
    _selectedSubTree = subTree;
    _articlePageData = null;
    _currentPage = 0; // 重置页码
    notifyListeners();
    
    await _fetchArticles(refresh: true);
  }
  
  // 刷新数据
  Future<void> refreshData() async {
    _errorMessage = '';
    
    try {
      await _fetchArticles(refresh: true);
    } catch (e) {
      _errorMessage = '刷新失败: $e';
      rethrow; // 重新抛出异常，让UI层可以捕获
    }
  }
  
  // 加载更多文章
  Future<void> loadMoreArticles() async {
    if (_isLoadingMore || !hasMore) return;
    
    _isLoadingMore = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _fetchArticles(refresh: false);
    } catch (e) {
      _errorMessage = '加载更多失败: $e';
      rethrow; // 重新抛出异常，让UI层可以捕获
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  // 收藏文章
  Future<bool> collectArticle(Article article) async {
    try {
      final path = AppConfig.collectArticle.replaceFirst('{id}', article.id.toString());
      final response = await _httpService.post(path);
      
      if (response['errorCode'] == 0) {
        // 更新文章的收藏状态
        final index = articles.indexWhere((a) => a.id == article.id);
        if (index != -1) {
          articles[index].collect = true;
          notifyListeners();
        }
        return true;
      } else {
        _errorMessage = response['errorMsg'] ?? '收藏失败';
        return false;
      }
    } catch (e) {
      _errorMessage = '收藏失败: $e';
      return false;
    }
  }
  
  // 取消收藏文章
  Future<bool> uncollectArticle(Article article) async {
    try {
      final path = AppConfig.uncollectOriginId.replaceFirst('{id}', article.id.toString());
      final response = await _httpService.post(path);
      
      if (response['errorCode'] == 0) {
        // 更新文章的收藏状态
        final index = articles.indexWhere((a) => a.id == article.id);
        if (index != -1) {
          articles[index].collect = false;
          notifyListeners();
        }
        return true;
      } else {
        _errorMessage = response['errorMsg'] ?? '取消收藏失败';
        return false;
      }
    } catch (e) {
      _errorMessage = '取消收藏失败: $e';
      return false;
    }
  }
  
  // 获取体系树数据
  Future<void> _fetchTreeData() async {
    try {
      final response = await _httpService.get(AppConfig.systemTree);
      if (response['errorCode'] == 0) {
        final List<dynamic> data = response['data'];
        _trees = data.map((item) => Tree.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(response['errorMsg'] ?? '获取体系数据失败');
      }
    } catch (e) {
      throw Exception('获取体系数据失败: $e');
    }
  }
  
  // 获取文章列表
  Future<void> _fetchArticles({bool refresh = false}) async {
    if (_selectedSubTree == null) return;
    
    if (refresh) {
      _currentPage = 0;
    } else {
      _currentPage++;
    }
    
    final String path = AppConfig.systemArticleList.replaceFirst('{page}', _currentPage.toString());
    
    try {
      final response = await _httpService.get(path, params: {'cid': _selectedSubTree!.id});
      if (response['errorCode'] == 0) {
        final data = response['data'];
        final pageData = PageData<Article>.fromJson(data, (json) => Article.fromJson(json));
        
        if (refresh || _articlePageData == null) {
          _articlePageData = pageData;
        } else {
          final List<Article> combinedArticles = [..._articlePageData!.datas, ...pageData.datas];
          _articlePageData = _articlePageData!.copyWith(
            curPage: pageData.curPage,
            over: pageData.over,
            datas: combinedArticles,
          );
        }
        
        notifyListeners();
      } else {
        if (!refresh) {
          _currentPage--; // 如果是加载更多失败，需要回退页码
        }
        throw Exception(response['errorMsg'] ?? '获取文章列表失败');
      }
    } catch (e) {
      if (!refresh) {
        _currentPage--; // 如果是加载更多失败，需要回退页码
      }
      throw Exception('获取文章列表失败: $e');
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
} 