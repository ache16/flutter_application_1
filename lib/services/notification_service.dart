import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final RxInt unreadMessageCount = 0.obs;
  final RxInt unreadFriendRequestCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
  }

  void _initNotifications() {
    // 初始化通知服务
    // 这里可以集成 Firebase Cloud Messaging 或本地通知
  }

  // 显示本地通知
  void showNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    // 使用 Get.snackbar 作为临时通知
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Colors.white,
      icon: const Icon(Icons.notifications, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  // 更新未读消息数
  void updateUnreadMessageCount(int count) {
    unreadMessageCount.value = count;
  }

  // 更新未读好友请求数
  void updateUnreadFriendRequestCount(int count) {
    unreadFriendRequestCount.value = count;
  }

  // 获取总未读数
  int get totalUnread => unreadMessageCount.value + unreadFriendRequestCount.value;
}
