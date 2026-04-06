import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/socket_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DiaryController>(() => DiaryController());
    Get.lazyPut<FriendController>(() => FriendController());
    Get.lazyPut<ChatController>(() => ChatController());
  }
}

// 控制器
class HomeController extends GetxController {
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;
  
  void changeIndex(int index) {
    _currentIndex.value = index;
  }
}

class DiaryController extends GetxController {
  final _diaries = <Map<String, dynamic>>[].obs;
  final _isLoading = false.obs;
  final _selectedDate = DateTime.now().obs;
  
  List<Map<String, dynamic>> get diaries => _diaries;
  bool get isLoading => _isLoading.value;
  DateTime get selectedDate => _selectedDate.value;

  final ApiService _api = Get.find();

  @override
  void onInit() {
    super.onInit();
    loadDiaries();
  }

  Future<void> loadDiaries() async {
    _isLoading.value = true;
    try {
      final response = await _api.get('/diary/my');
      _diaries.value = List<Map<String, dynamic>>.from(response.data);
    } finally {
      _isLoading.value = false;
    }
  }

  void selectDate(DateTime date) {
    _selectedDate.value = date;
  }
}

class FriendController extends GetxController {
  final _friends = <Map<String, dynamic>>[].obs;
  final _requests = <Map<String, dynamic>>[].obs;
  final _isLoading = false.obs;
  
  List<Map<String, dynamic>> get friends => _friends;
  List<Map<String, dynamic>> get requests => _requests;
  bool get isLoading => _isLoading.value;
  int get requestCount => _requests.length;

  final ApiService _api = Get.find();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    _isLoading.value = true;
    try {
      final friendsRes = await _api.get('/friends/list');
      final requestsRes = await _api.get('/friends/requests/pending');
      _friends.value = List<Map<String, dynamic>>.from(friendsRes.data);
      _requests.value = List<Map<String, dynamic>>.from(requestsRes.data);
    } finally {
      _isLoading.value = false;
    }
  }
}

class ChatController extends GetxController {
  final _recentChats = <Map<String, dynamic>>[].obs;
  final _isLoading = false.obs;
  final _unreadCount = 0.obs;
  
  List<Map<String, dynamic>> get recentChats => _recentChats;
  bool get isLoading => _isLoading.value;
  int get unreadCount => _unreadCount.value;

  final ApiService _api = Get.find();

  @override
  void onInit() {
    super.onInit();
    loadRecentChats();
  }

  Future<void> loadRecentChats() async {
    _isLoading.value = true;
    try {
      final response = await _api.get('/chat/recent/list');
      _recentChats.value = List<Map<String, dynamic>>.from(response.data);
      _calculateUnreadCount();
    } finally {
      _isLoading.value = false;
    }
  }

  void _calculateUnreadCount() {
    _unreadCount.value = _recentChats.fold<int>(0, (sum, chat) {
      return sum + (chat['unread_count'] ?? 0) as int;
    });
  }
}
