import 'package:flutter_cursor_demo/config/app_config.dart';
import 'package:flutter_cursor_demo/services/http_service.dart';
import 'package:flutter_cursor_demo/services/storage_service.dart';
import 'package:flutter_cursor_demo/models/user_info.dart';
import 'package:flutter_cursor_demo/models/article.dart';
import 'package:flutter_cursor_demo/models/page_data.dart';
import 'package:dio/dio.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  
  final HttpService _httpService = HttpService();
  final StorageService _storageService = StorageService();
  
  UserInfo? _currentUser;
  bool get isLoggedIn => _currentUser != null;
  UserInfo? get currentUser => _currentUser;
  
  UserService._internal();
  
  // 初始化
  Future<void> init() async {
    final isLogin = _storageService.getBool(AppConfig.keyIsLogin);
    if (isLogin) {
      final username = _storageService.getString(AppConfig.keyUsername);
      if (username.isNotEmpty) {
        _currentUser = UserInfo(username: username);
      }
    }
  }
  
  // 登录
  Future<bool> login(String username, String password) async {
    try {
      final formData = FormData.fromMap({
        'username': username,
        'password': password
      });
      
      final response = await _httpService.post(
        AppConfig.login,
        data: formData
      );
      
      if (response['errorCode'] == 0) {
        final userData = response['data'];
        _currentUser = UserInfo.fromJson(userData);
        
        // 保存登录状态
        await _storageService.setBool(AppConfig.keyIsLogin, true);
        await _storageService.setString(AppConfig.keyUsername, username);
        
        return true;
      } else {
        throw Exception(response['errorMsg'] ?? '登录失败');
      }
    } catch (e) {
      throw Exception('登录失败: $e');
    }
  }
  
  // 注册
  Future<bool> register(String username, String password, String repassword) async {
    try {
      final formData = FormData.fromMap({
        'username': username,
        'password': password,
        'repassword': repassword
      });
      
      final response = await _httpService.post(
        AppConfig.register,
        data: formData
      );
      
      if (response['errorCode'] == 0) {
        final userData = response['data'];
        _currentUser = UserInfo.fromJson(userData);
        
        // 保存登录状态
        await _storageService.setBool(AppConfig.keyIsLogin, true);
        await _storageService.setString(AppConfig.keyUsername, username);
        
        return true;
      } else {
        throw Exception(response['errorMsg'] ?? '注册失败');
      }
    } catch (e) {
      throw Exception('注册失败: $e');
    }
  }
  
  // 登出
  Future<bool> logout() async {
    try {
      final response = await _httpService.get(AppConfig.logout);
      
      if (response['errorCode'] == 0) {
        _currentUser = null;
        
        // 清除登录状态
        await _storageService.setBool(AppConfig.keyIsLogin, false);
        await _storageService.remove(AppConfig.keyUsername);
        
        // 清除cookies
        await _httpService.clearCookies();
        
        return true;
      } else {
        throw Exception(response['errorMsg'] ?? '登出失败');
      }
    } catch (e) {
      throw Exception('登出失败: $e');
    }
  }
  
  // 获取收藏列表
  Future<PageData<Article>> getCollectList(int page) async {
    try {
      final path = AppConfig.collectList.replaceFirst('{page}', page.toString());
      final response = await _httpService.get(path);
      
      if (response['errorCode'] == 0) {
        final data = response['data'];
        return PageData<Article>.fromJson(data, (json) => Article.fromJson(json));
      } else {
        throw Exception(response['errorMsg'] ?? '获取收藏列表失败');
      }
    } catch (e) {
      throw Exception('获取收藏列表失败: $e');
    }
  }
  
  // 收藏文章
  Future<bool> collectArticle(int articleId) async {
    try {
      final path = AppConfig.collectArticle.replaceFirst('{id}', articleId.toString());
      final response = await _httpService.post(path);
      
      if (response['errorCode'] == 0) {
        return true;
      } else {
        throw Exception(response['errorMsg'] ?? '收藏文章失败');
      }
    } catch (e) {
      throw Exception('收藏文章失败: $e');
    }
  }
  
  // 取消收藏文章 (首页文章列表)
  Future<bool> uncollectArticle(int articleId) async {
    try {
      final path = AppConfig.uncollectOriginId.replaceFirst('{id}', articleId.toString());
      final response = await _httpService.post(path);
      
      if (response['errorCode'] == 0) {
        return true;
      } else {
        throw Exception(response['errorMsg'] ?? '取消收藏失败');
      }
    } catch (e) {
      throw Exception('取消收藏失败: $e');
    }
  }
  
  // 取消收藏文章 (收藏页面)
  Future<bool> uncollectArticleFromCollectPage(int articleId, int originId) async {
    try {
      final path = AppConfig.uncollectArticle.replaceFirst('{id}', articleId.toString());
      final response = await _httpService.post(path, data: {'originId': originId == 0 ? -1 : originId});
      
      if (response['errorCode'] == 0) {
        return true;
      } else {
        throw Exception(response['errorMsg'] ?? '取消收藏失败');
      }
    } catch (e) {
      throw Exception('取消收藏失败: $e');
    }
  }
} 