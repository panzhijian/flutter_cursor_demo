import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_cursor_demo/utils/log_util.dart';
import 'package:flutter_cursor_demo/config/app_config.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  
  late Dio _dio;
  late CookieJar _cookieJar;
  bool _isInitialized = false;
  
  HttpService._internal();
  
  Future<void> init() async {
    if (_isInitialized) return;
    
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    
    // 初始化持久化Cookie管理
    final tempDir = await getTemporaryDirectory();
    final cookiePath = '${tempDir.path}/.cookies/';
    _cookieJar = PersistCookieJar(
      storage: FileStorage(cookiePath),
    );
    _dio.interceptors.add(CookieManager(_cookieJar));
    
    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        LogUtil.d('请求: ${options.uri}');
        LogUtil.d('请求头: ${options.headers}');
        LogUtil.d('请求参数: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        LogUtil.d('响应: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        LogUtil.e('请求错误: ${e.message}');
        return handler.next(e);
      },
    ));
    
    _isInitialized = true;
  }
  
  // 清除所有Cookies，用于退出登录
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }
  
  // GET请求
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? params}) async {
    await init();
    try {
      final response = await _dio.get(path, queryParameters: params);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }
  
  // POST请求
  Future<Map<String, dynamic>> post(String path, {dynamic data, Map<String, dynamic>? params}) async {
    await init();
    try {
      final response = await _dio.post(path, data: data, queryParameters: params);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }
  
  // 处理响应
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final errorCode = data['errorCode'] as int;
      
      if (errorCode == 0) {
        return data;
      } else {
        throw Exception(data['errorMsg'] ?? '未知错误');
      }
    } else {
      throw Exception('网络请求失败，状态码：${response.statusCode}');
    }
  }
  
  // 处理错误
  Map<String, dynamic> _handleError(DioException e) {
    String message;
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = '连接超时';
        break;
      case DioExceptionType.sendTimeout:
        message = '请求超时';
        break;
      case DioExceptionType.receiveTimeout:
        message = '响应超时';
        break;
      case DioExceptionType.badResponse:
        message = '服务器响应错误，状态码：${e.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        message = '请求取消';
        break;
      default:
        message = '网络错误：${e.message}';
        break;
    }
    
    return {
      'errorCode': -1,
      'errorMsg': message,
      'data': null
    };
  }
}