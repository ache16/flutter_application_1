import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final nicknameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isPasswordVisible = false.obs;
    final isConfirmVisible = false.obs;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '创建账号',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                
                SizedBox(height: 8.h),
                
                Text(
                  '开始记录你的生活点滴',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                
                SizedBox(height: 40.h),
                
                CustomTextField(
                  controller: usernameController,
                  hint: '用户名',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入用户名';
                    }
                    if (!AppUtils.isValidUsername(value)) {
                      return '用户名3-20位，只能包含字母、数字、下划线';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 100.ms),
                
                SizedBox(height: 16.h),
                
                CustomTextField(
                  controller: nicknameController,
                  hint: '昵称',
                  prefixIcon: Icons.face_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入昵称';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms),
                
                SizedBox(height: 16.h),
                
                Obx(() => CustomTextField(
                  controller: passwordController,
                  hint: '密码',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !isPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible.value 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () => isPasswordVisible.toggle(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 6) {
                      return '密码至少6位';
                    }
                    return null;
                  },
                )).animate().fadeIn(delay: 300.ms),
                
                SizedBox(height: 16.h),
                
                Obx(() => CustomTextField(
                  controller: confirmPasswordController,
                  hint: '确认密码',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !isConfirmVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmVisible.value 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () => isConfirmVisible.toggle(),
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return '两次密码不一致';
                    }
                    return null;
                  },
                )).animate().fadeIn(delay: 400.ms),
                
                SizedBox(height: 24.h),
                
                Obx(() => CustomButton(
                  text: '注册',
                  isLoading: controller.isLoading,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final success = await controller.register(
                      usernameController.text.trim(),
                      passwordController.text,
                      nicknameController.text.trim(),
                    );
                    
                    if (success) {
                      AppUtils.showSuccess('注册成功');
                      Get.offAllNamed(Routes.HOME);
                    } else {
                      AppUtils.showError('注册失败，用户名可能已被使用');
                    }
                  },
                )).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
