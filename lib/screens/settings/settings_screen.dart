import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final storage = Get.find<StorageService>();
    setState(() {
      _notificationsEnabled = storage.getNotificationEnabled();
      _themeMode = storage.getThemeMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSectionTitle('外观'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('深色模式'),
                  trailing: DropdownButton<String>(
                    value: _themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'light', child: Text('关闭')),
                      DropdownMenuItem(value: 'dark', child: Text('开启')),
                      DropdownMenuItem(value: 'system', child: Text('跟随系统')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _themeMode = value);
                        Get.find<StorageService>().setThemeMode(value);
                        // 应用主题
                        if (value == 'dark') {
                          Get.changeThemeMode(ThemeMode.dark);
                        } else if (value == 'light') {
                          Get.changeThemeMode(ThemeMode.light);
                        } else {
                          Get.changeThemeMode(ThemeMode.system);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          
          _buildSectionTitle('通知'),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('消息通知'),
              subtitle: const Text('接收新消息提醒'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                Get.find<StorageService>().setNotificationEnabled(value);
              },
            ),
          ),
          SizedBox(height: 16.h),
          
          _buildSectionTitle('数据'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('备份数据'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('恢复数据'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('清除缓存', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await Get.find<StorageService>().clearCache();
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('缓存已清除')),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          
          _buildSectionTitle('关于'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('版本'),
                  trailing: Text('1.0.0', style: TextStyle(color: Colors.grey[600])),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('用户协议'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('隐私政策'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
