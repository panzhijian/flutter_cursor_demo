import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  
  late SharedPreferences _prefs;
  
  StorageService._internal();
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // 存储字符串
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }
  
  // 获取字符串
  String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }
  
  // 存储布尔值
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }
  
  // 获取布尔值
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }
  
  // 存储整数
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }
  
  // 获取整数
  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }
  
  // 存储双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }
  
  // 获取双精度浮点数
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }
  
  // 存储字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }
  
  // 获取字符串列表
  List<String> getStringList(String key, {List<String> defaultValue = const []}) {
    return _prefs.getStringList(key) ?? defaultValue;
  }
  
  // 删除指定键值对
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
  
  // 清空所有键值对
  Future<bool> clear() async {
    return await _prefs.clear();
  }
  
  // 检查是否包含某个键
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
} 