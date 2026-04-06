import 'package:dio/dio.dart' hide Response;
import 'package:get/get.dart';
import '../utils/app_logger.dart';
import 'storage_service.dart';

class ApiService extends GetxService {
  static const String baseUrl = 'http://211.159.186.157:3000/api';
  
  late Dio _dio;
  final _isConnected = true.obs;
  
  Dio get dio => _dio;
  bool get isConnected => _isConnected.value;

  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加认证令牌
        final storage = Get.find<StorageService>();
        final token = storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        AppLogger.d('📤 请求: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _isConnected.value = true;
        AppLogger.d('📥 响应: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) {
        _handleError(error);
        return handler.next(error);
      },
    ));

    // 添加重试拦截器
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            AppLogger.w('🔄 请求失败，准备重试...');
            await Future.delayed(const Duration(seconds: 1));
            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           (error.response?.statusCode != null && error.response!.statusCode! >= 500);
  }

  void _handleError(DioException error) {
    _isConnected.value = false;
    
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      AppLogger.e('⏱️ 请求超时');
    } else if (error.type == DioExceptionType.connectionError) {
      AppLogger.e('📡 网络连接失败');
    } else if (error.response?.statusCode == 401) {
      AppLogger.w('🔒 认证失效，需要重新登录');
      // 清除登录状态
      Get.find<StorageService>().clearAll();
      Get.offAllNamed('/login');
    } else if (error.response?.statusCode == 403) {
      AppLogger.w('🚫 权限不足');
    } else if (error.response?.statusCode == 404) {
      AppLogger.w('❓ 资源不存在');
    } else if (error.response?.statusCode == 500) {
      AppLogger.e('💥 服务器错误');
    } else {
      AppLogger.e('❌ 请求错误: ${error.message}');
    }
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  // REST API 方法
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
  }) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  // 上传文件
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
    });

    return await _dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
    );
  }
}
