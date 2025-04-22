import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_cursor_demo/views/home/home_page.dart';
import 'package:flutter_cursor_demo/views/system/system_page.dart';
import 'package:flutter_cursor_demo/views/mine/mine_page.dart';
import 'package:flutter_cursor_demo/views/mine/login_page.dart';
import 'package:flutter_cursor_demo/views/mine/register_page.dart';
import 'package:flutter_cursor_demo/views/mine/collect_page.dart';
import 'package:flutter_cursor_demo/views/article_detail_page.dart';
import 'package:flutter_cursor_demo/views/main_page.dart';
import 'package:flutter_cursor_demo/views/search_page.dart';
import 'package:flutter_cursor_demo/viewmodels/search_viewmodel.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRoutes {
  static const String home = '/home';
  static const String system = '/system';
  static const String mine = '/mine';
  static const String login = '/login';
  static const String register = '/register';
  static const String articleDetail = '/article-detail';
  static const String collect = '/collect';
  static const String search = '/search';
  
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainPage(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: home,
            pageBuilder: (context, state) => NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: system,
            pageBuilder: (context, state) => NoTransitionPage(
              child: SystemPage(),
            ),
          ),
          GoRoute(
            path: mine,
            pageBuilder: (context, state) => NoTransitionPage(
              child: MinePage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: register,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => RegisterPage(),
      ),
      GoRoute(
        path: collect,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CollectPage(),
      ),
      GoRoute(
        path: articleDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final Map<String, String> params = state.uri.queryParameters;
          final articleId = params['id'] ?? '';
          final title = params['title'] ?? '';
          final url = params['url'] ?? '';
          return ArticleDetailPage(articleId: articleId, title: title, url: url);
        },
      ),
      GoRoute(
        path: search,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final Map<String, String> params = state.uri.queryParameters;
          final String? keyword = params['keyword'];
          final String type = params['type'] ?? 'keyword';
          
          return SearchPage(
            initialKeyword: keyword,
            initialSearchType: type == 'author' ? SearchType.author : SearchType.keyword,
          );
        },
      ),
    ],
  );
} 