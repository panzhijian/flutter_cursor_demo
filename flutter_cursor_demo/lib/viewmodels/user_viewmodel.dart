import 'package:flutter/foundation.dart';
import 'package:flutter_cursor_demo/models/user_info.dart';
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
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
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