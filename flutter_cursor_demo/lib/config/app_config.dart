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
  
  // 本地存储Key
  static const String keyToken = 'token';
  static const String keyUsername = 'username';
  static const String keyIsLogin = 'isLogin';
} 