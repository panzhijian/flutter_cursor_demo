import 'package:flutter/foundation.dart';
import 'package:flutter_cursor_demo/models/user_info.dart';
import 'package:flutter_cursor_demo/models/article.dart';
import 'package:flutter_cursor_demo/models/page_data.dart';
import 'package:flutter_cursor_demo/services/user_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  
  // 登录状态
  bool get isLoggedIn => _userService.isLoggedIn;
  UserInfo? get currentUser => _userService.currentUser;
  
  // 加载状态
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // 错误信息
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  
  // 收藏相关
  PageData<Article>? _collectPageData;
  List<Article> get collectArticles => _collectPageData?.datas ?? [];
  bool get hasMoreCollects => _collectPageData?.over == false;
  
  bool _isLoadingMoreCollects = false;
  bool get isLoadingMoreCollects => _isLoadingMoreCollects;
  
  int _currentCollectPage = 0;
  
  // 初始化数据
  Future<void> initData() async {
    await _userService.init();
    notifyListeners();
  }
  
  // 登录
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      final result = await _userService.login(username, password);
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 注册
  Future<bool> register(String username, String password, String repassword) async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      final result = await _userService.register(username, password, repassword);
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 登出
  Future<bool> logout() async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      final result = await _userService.logout();
      _collectPageData = null; // 清空收藏数据
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 获取收藏列表
  Future<void> getCollectList({bool refresh = false}) async {
    if (!isLoggedIn) {
      _errorMessage = '请先登录';
      return;
    }
    
    if (refresh) {
      _setLoading(true);
      _currentCollectPage = 0;
    } else {
      _isLoadingMoreCollects = true;
      _currentCollectPage++;
    }
    
    _errorMessage = '';
    notifyListeners();
    
    try {
      final pageData = await _userService.getCollectList(_currentCollectPage);
      
      if (refresh || _collectPageData == null) {
        _collectPageData = pageData;
      } else {
        _collectPageData = _collectPageData!.copyWith(
          curPage: pageData.curPage,
          over: pageData.over,
          appendDatas: pageData.datas,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (!refresh) {
        _currentCollectPage--;
      }
    } finally {
      if (refresh) {
        _setLoading(false);
      } else {
        _isLoadingMoreCollects = false;
        notifyListeners();
      }
    }
  }
  
  // 取消收藏
  Future<bool> uncollectArticle(Article article) async {
    if (!isLoggedIn) {
      _errorMessage = '请先登录';
      return false;
    }
    
    try {
      bool success;
      
      // 判断是在收藏列表中还是在文章列表中取消收藏
      if (_collectPageData != null && _collectPageData!.datas.any((a) => a.id == article.id)) {
        // 在收藏列表中取消收藏
        success = await _userService.uncollectArticleFromCollectPage(
          article.id ?? 0,
          article.originId ?? -1,
        );
        
        // 如果成功，从收藏列表中移除该文章
        if (success) {
          final index = _collectPageData!.datas.indexWhere((a) => a.id == article.id);
          if (index != -1) {
            _collectPageData!.datas.removeAt(index);
            notifyListeners();
          }
        }
      } else {
        // 在文章列表中取消收藏
        success = await _userService.uncollectArticle(article.id ?? 0);
      }
      
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  // 清除错误信息
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
} 