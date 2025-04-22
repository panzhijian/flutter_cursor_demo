class LogUtil {
  static bool isDebug = true;
  
  static void d(dynamic message) {
    if (isDebug) {
      print('🟢 DEBUG: $message');
    }
  }
  
  static void i(dynamic message) {
    if (isDebug) {
      print('🔵 INFO: $message');
    }
  }
  
  static void w(dynamic message) {
    if (isDebug) {
      print('🟠 WARN: $message');
    }
  }
  
  static void e(dynamic message) {
    if (isDebug) {
      print('🔴 ERROR: $message');
    }
  }
} 