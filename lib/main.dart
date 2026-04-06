import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'routes/app_pages.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/socket_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 初始化服务
  await _initServices();
  
  runApp(const XiaoLiuYiJiApp());
}

Future<void> _initServices() async {
  try {
    // 按顺序初始化服务
    await Get.putAsync(() => StorageService().init());
    logger.i('✅ StorageService 初始化完成');
    
    Get.put(ApiService());
    logger.i('✅ ApiService 初始化完成');
    
    Get.put(SocketService());
    logger.i('✅ SocketService 初始化完成');
    
    Get.put(NotificationService());
    logger.i('✅ NotificationService 初始化完成');
    
  } catch (e, stackTrace) {
    logger.e('服务初始化失败', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

class XiaoLiuYiJiApp extends StatelessWidget {
  const XiaoLiuYiJiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: '小六印记',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          defaultTransition: Transition.cupertino,
          getPages: AppPages.routes,
          initialRoute: AppPages.INITIAL,
          locale: const Locale('zh', 'CN'),
          fallbackLocale: const Locale('zh', 'CN'),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
        );
      },
    );
  }
}
