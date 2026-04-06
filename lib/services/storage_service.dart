import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  late GetStorage _box;
  
  // 内存缓存
  final Map<String, dynamic> _cache = {};

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // ===== Token =====
  String? getToken() => _box.read('token');
  
  Future<void> setToken(String token) async {
    await _box.write('token', token);
  }
  
  Future<void> removeToken() async {
    await _box.remove('token');
  }

  // ===== 用户信息 =====
  Map<String, dynamic>? getUser() {
    final userStr = _box.read('user');
    if (userStr == null) return null;
    if (userStr is String) {
      try {
        return jsonDecode(userStr);
      } catch (e) {
        return null;
      }
    }
    return userStr as Map<String, dynamic>?;
  }
  
  Future<void> setUser(Map<String, dynamic> user) async {
    await _box.write('user', jsonEncode(user));
    _cache['user'] = user;
  }
  
  Future<void> removeUser() async {
    await _box.remove('user');
    _cache.remove('user');
  }

  // ===== 登录状态 =====
  bool get isLoggedIn => getToken() != null;

  // ===== 设置项 =====
  Future<void> setSetting(String key, dynamic value) async {
    await _box.write('setting_$key', value);
  }
  
  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _box.read('setting_$key') ?? defaultValue;
  }

  // ===== 主题设置 =====
  String getThemeMode() => getSetting('theme_mode', defaultValue: 'system');
  Future<void> setThemeMode(String mode) => setSetting('theme_mode', mode);

  // ===== 通知设置 =====
  bool getNotificationEnabled() => getSetting('notification_enabled', defaultValue: true);
  Future<void> setNotificationEnabled(bool enabled) => setSetting('notification_enabled', enabled);

  // ===== 缓存数据 =====
  void setCache(String key, dynamic value) {
    _cache[key] = value;
  }
  
  dynamic getCache(String key) => _cache[key];
  
  void clearCache() {
    _cache.clear();
  }

  // ===== 草稿箱 =====
  Future<void> saveDiaryDraft(Map<String, dynamic> draft) async {
    await _box.write('diary_draft', jsonEncode(draft));
  }
  
  Map<String, dynamic>? getDiaryDraft() {
    final draft = _box.read('diary_draft');
    if (draft == null) return null;
    return jsonDecode(draft);
  }
  
  Future<void> clearDiaryDraft() async {
    await _box.remove('diary_draft');
  }

  // ===== 聊天记录缓存 =====
  Future<void> cacheMessages(int friendId, List<dynamic> messages) async {
    await _box.write('messages_$friendId', jsonEncode(messages));
  }
  
  List<dynamic>? getCachedMessages(int friendId) {
    final data = _box.read('messages_$friendId');
    if (data == null) return null;
    return jsonDecode(data);
  }

  // ===== 清除所有数据 =====
  Future<void> clearAll() async {
    await _box.erase();
    _cache.clear();
  }
}
