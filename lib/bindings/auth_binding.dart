import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/socket_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class AuthController extends GetxController {
  final _isLoading = false.obs;
  final _user = Rxn<Map<String, dynamic>>();
  
  bool get isLoading => _isLoading.value;
  Map<String, dynamic>? get user => _user.value;
  set user(Map<String, dynamic>? value) => _user.value = value;
  bool get isLoggedIn => _user.value != null;

  final ApiService _api = Get.find();
  final StorageService _storage = Get.find();

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  void _loadUser() {
    _user.value = _storage.getUser();
  }

  Future<bool> login(String username, String password) async {
    _isLoading.value = true;
    try {
      final response = await _api.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      final data = response.data;
      await _storage.setToken(data['token']);
      await _storage.setUser(data['user']);
      _api.setToken(data['token']);
      _user.value = data['user'];

      // 连接 Socket
      Get.find<SocketService>().connect();

      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> register(String username, String password, String nickname) async {
    _isLoading.value = true;
    try {
      final response = await _api.post('/auth/register', data: {
        'username': username,
        'password': password,
        'nickname': nickname,
      });

      final data = response.data;
      await _storage.setToken(data['token']);
      await _storage.setUser(data['user']);
      _api.setToken(data['token']);
      _user.value = data['user'];

      Get.find<SocketService>().connect();

      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    Get.find<SocketService>().disconnect();
    await _storage.clearAll();
    _api.clearToken();
    _user.value = null;
  }
}
