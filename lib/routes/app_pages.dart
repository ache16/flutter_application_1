import 'package:get/get.dart';

import '../bindings/home_binding.dart';
import '../bindings/auth_binding.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/diary/diary_detail_screen.dart';
import '../screens/diary/diary_edit_screen.dart';
import '../screens/diary/diary_calendar_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/friends/friends_screen.dart';
import '../screens/friends/friend_search_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/profile_edit_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/statistics/statistics_screen.dart';
import '../screens/moments/moments_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.DIARY_DETAIL,
      page: () => DiaryDetailScreen(id: int.parse(Get.parameters['id']!)),
    ),
    GetPage(
      name: Routes.DIARY_EDIT,
      page: () => DiaryEditScreen(diary: Get.arguments),
    ),
    GetPage(
      name: Routes.DIARY_CALENDAR,
      page: () => const DiaryCalendarScreen(),
    ),
    GetPage(
      name: Routes.CHAT,
      page: () => ChatScreen(
        userId: int.parse(Get.parameters['userId']!),
        userInfo: Get.arguments,
      ),
    ),
    GetPage(
      name: Routes.FRIENDS,
      page: () => const FriendsScreen(),
    ),
    GetPage(
      name: Routes.FRIEND_SEARCH,
      page: () => const FriendSearchScreen(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: Routes.PROFILE_EDIT,
      page: () => const ProfileEditScreen(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreen(),
    ),
    GetPage(
      name: Routes.STATISTICS,
      page: () => const StatisticsScreen(),
    ),
    GetPage(
      name: Routes.MOMENTS,
      page: () => const MomentsScreen(),
    ),
  ];
}
