import 'package:flutter_cursor_demo/config/app_config.dart';
import 'package:flutter_cursor_demo/services/http_service.dart';
import 'package:flutter_cursor_demo/services/storage_service.dart';
import 'package:flutter_cursor_demo/models/user_info.dart';

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
      final response = await _httpService.post(
        AppConfig.login,
        data: {'username': username, 'password': password}
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
      final response = await _httpService.post(
        AppConfig.register,
        data: {
          'username': username,
          'password': password,
          'repassword': repassword
        }
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
        
        return true;
      } else {
        throw Exception(response['errorMsg'] ?? '登出失败');
      }
    } catch (e) {
      throw Exception('登出失败: $e');
    }
  }
} 