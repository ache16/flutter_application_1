import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../bindings/home_binding.dart';
import '../diary/diary_list_screen.dart';
import '../friends/friends_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DiaryListScreen(),
      const FriendsScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    return Obx(() => Scaffold(
      body: IndexedStack(
        index: controller.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: controller.currentIndex,
        onDestinationSelected: controller.changeIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.book_outlined),
            selectedIcon: const Icon(Icons.book),
            label: '忆记',
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: '好友',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: Get.find<ChatController>().unreadCount > 0,
              label: Text('${Get.find<ChatController>().unreadCount}'),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: '聊天',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    ));
  }
}
