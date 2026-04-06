import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../bindings/home_binding.dart';
import '../../routes/app_pages.dart';
import '../../services/storage_service.dart';
import '../../utils/app_utils.dart';

class ProfileScreen extends GetView<AuthController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(Routes.SETTINGS),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.user;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // 用户信息卡片
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => Get.toNamed(Routes.PROFILE_EDIT),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50.r,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                user['nickname']?[0] ?? '?',
                                style: TextStyle(
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.edit, size: 16.sp, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        user['nickname'] ?? user['username'],
                        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '@${user['username']}',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                      ),
                      if (user['bio']?.isNotEmpty == true) ...[
                        SizedBox(height: 12.h),
                        Text(
                          user['bio'],
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              
              // 功能列表
              _buildMenuSection([
                _MenuItem(
                  icon: Icons.bar_chart,
                  title: '数据统计',
                  onTap: () => Get.toNamed(Routes.STATISTICS),
                ),
                _MenuItem(
                  icon: Icons.public,
                  title: '朋友圈',
                  onTap: () => Get.toNamed(Routes.MOMENTS),
                ),
                _MenuItem(
                  icon: Icons.calendar_today,
                  title: '日记日历',
                  onTap: () => Get.toNamed(Routes.DIARY_CALENDAR),
                ),
              ]),
              SizedBox(height: 16.h),
              
              _buildMenuSection([
                _MenuItem(
                  icon: Icons.settings,
                  title: '设置',
                  onTap: () => Get.toNamed(Routes.SETTINGS),
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  title: '帮助与反馈',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: '关于',
                  onTap: () {},
                ),
              ]),
              SizedBox(height: 24.h),
              
              // 退出登录
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final confirm = await AppUtils.showConfirm(
                      title: '退出登录',
                      message: '确定要退出登录吗？',
                      isDanger: true,
                    );
                    if (confirm) {
                      await controller.logout();
                      Get.offAllNamed(Routes.LOGIN);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: const Text('退出登录'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMenuSection(List<_MenuItem> items) {
    return Card(
      child: Column(
        children: items.map((item) => ListTile(
          leading: Icon(item.icon, color: Theme.of(Get.context!).colorScheme.primary),
          title: Text(item.title),
          trailing: const Icon(Icons.chevron_right),
          onTap: item.onTap,
        )).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem({required this.icon, required this.title, required this.onTap});
}
