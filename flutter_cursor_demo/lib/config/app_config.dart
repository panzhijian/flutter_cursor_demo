class AppConfig {
  // API基础URL
  static const String baseUrl = 'https://www.wanandroid.com';
  
  // 首页相关API
  static const String homeArticleList = '/article/list/{page}/json';
  static const String homeBanner = '/banner/json';
  
  // 体系相关API
  static const String systemTree = '/tree/json';
  static const String systemArticleList = '/article/list/{page}/json';
  
  // 登录相关API
  static const String login = '/user/login';
  static const String register = '/user/register';
  static const String logout = '/user/logout/json';
  
  // 收藏相关API
  static const String collectList = '/lg/collect/list/{page}/json';
  static const String collectArticle = '/lg/collect/{id}/json';
  static const String uncollectOriginId = '/lg/uncollect_originId/{id}/json';
  static const String collectOutsideArticle = '/lg/collect/add/json';
  static const String uncollectArticle = '/lg/uncollect/{id}/json';

  // 搜索相关API
  static const String searchHotKeywords = '/hotkey/json';
  static const String searchByKeyword = '/article/query/{page}/json';
  static const String searchByAuthor = '/article/list/{page}/json?author={author}';

  // 本地存储Key
  static const String keyToken = 'token';
  static const String keyUsername = 'username';
  static const String keyIsLogin = 'isLogin';
} 