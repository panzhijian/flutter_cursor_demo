import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter_cursor_demo/routes/app_routes.dart';
import 'package:flutter_cursor_demo/viewmodels/home_viewmodel.dart';
import 'package:flutter_cursor_demo/viewmodels/system_viewmodel.dart';
import 'package:flutter_cursor_demo/viewmodels/user_viewmodel.dart';
import 'package:flutter_cursor_demo/viewmodels/search_viewmodel.dart';
import 'package:flutter_cursor_demo/services/storage_service.dart';
import 'package:flutter_cursor_demo/services/http_service.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 配置全局错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    log('Flutter error: ${details.exception}', error: details.exception, stackTrace: details.stack);
  };

  // 处理未捕获的异步错误
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    log('Uncaught exception: $error', error: error, stackTrace: stack);
    return true;
  };

  // 在Zone中运行应用，捕获所有错误
  runZonedGuarded(() async {
    // 初始化本地存储
    await StorageService().init();
    
    // 初始化HTTP服务
    await HttpService().init();
    
    // 设置状态栏颜色
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    runApp(const MyApp());
  }, (error, stackTrace) {
    log('Uncaught exception in zone: $error', error: error, stackTrace: stackTrace);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SystemViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Flutter Cursor Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: Colors.blue,
              scaffoldBackgroundColor: Colors.grey[100],
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                iconTheme: IconThemeData(color: Colors.black),
              ),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            routerConfig: AppRoutes.router,
          );
        },
      ),
    );
  }
}
