import 'package:flutter_cursor_demo/config/app_config.dart';
import 'package:flutter_cursor_demo/services/http_service.dart';
import 'package:flutter_cursor_demo/models/hot_keyword.dart';
import 'package:flutter_cursor_demo/models/article.dart';
import 'package:flutter_cursor_demo/models/page_data.dart';
import 'package:dio/dio.dart';

class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  
  final HttpService _httpService = HttpService();
  
  SearchService._internal();
  
  // 获取搜索热词
  Future<List<HotKeyword>> getHotKeywords() async {
    try {
      final response = await _httpService.get(AppConfig.searchHotKeywords);
      
      if (response['errorCode'] == 0) {
        final List<dynamic> data = response['data'];
        return data.map((item) => HotKeyword.fromJson(item)).toList();
      } else {
        throw Exception(response['errorMsg'] ?? '获取热词失败');
      }
    } catch (e) {
      throw Exception('获取热词失败: $e');
    }
  }
  
  // 按关键词搜索文章
  Future<PageData<Article>> searchByKeyword(String keyword, int page) async {
    try {
      final path = AppConfig.searchByKeyword.replaceFirst('{page}', page.toString());
      
      // 使用FormData处理关键词，确保去除首尾空格
      final formData = FormData.fromMap({
        'k': keyword.trim()
      });
      
      final response = await _httpService.post(path, data: formData);
      
      if (response['errorCode'] == 0) {
        final data = response['data'];
        return PageData<Article>.fromJson(data, (json) => Article.fromJson(json));
      } else {
        throw Exception(response['errorMsg'] ?? '搜索失败');
      }
    } catch (e) {
      throw Exception('搜索失败: $e');
    }
  }
  
  // 按作者搜索文章
  Future<PageData<Article>> searchByAuthor(String author, int page) async {
    try {
      final path = AppConfig.searchByAuthor
        .replaceFirst('{page}', page.toString())
        .replaceFirst('{author}', Uri.encodeComponent(author.trim()));
      
      final response = await _httpService.get(path);
      
      if (response['errorCode'] == 0) {
        final data = response['data'];
        return PageData<Article>.fromJson(data, (json) => Article.fromJson(json));
      } else {
        throw Exception(response['errorMsg'] ?? '搜索失败');
      }
    } catch (e) {
      throw Exception('搜索失败: $e');
    }
  }
} 