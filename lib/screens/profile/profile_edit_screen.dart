import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../bindings/auth_binding.dart';
import '../../bindings/home_binding.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ProfileEditScreen extends GetView<AuthController> {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    final nicknameController = TextEditingController(text: user?['nickname'] ?? '');
    final bioController = TextEditingController(text: user?['bio'] ?? '');
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              try {
                await Get.find<ApiService>().put('/auth/profile', data: {
                  'nickname': nicknameController.text.trim(),
                  'bio': bioController.text.trim(),
                });
                
                // 更新本地用户信息
                final updatedUser = Map<String, dynamic>.from(user!);
                updatedUser['nickname'] = nicknameController.text.trim();
                updatedUser['bio'] = bioController.text.trim();
                await Get.find<StorageService>().setUser(updatedUser);
                controller.user = updatedUser;
                
                AppUtils.showSuccess('资料已更新');
                Get.back();
              } catch (e) {
                AppUtils.showError('更新失败');
              }
            },
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // 头像
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60.r,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        user?['nickname']?[0] ?? '?',
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, size: 20.sp, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              
              CustomTextField(
                controller: nicknameController,
                label: '昵称',
                hint: '输入昵称',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入昵称';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              
              CustomTextField(
                controller: bioController,
                label: '简介',
                hint: '写点什么介绍自己...',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
