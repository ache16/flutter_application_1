import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../bindings/home_binding.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isPasswordVisible = false.obs;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),
                
                // Logo
                Center(
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '六',
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                
                SizedBox(height: 40.h),
                
                // 标题
                Text(
                  '欢迎回来',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
                
                SizedBox(height: 8.h),
                
                Text(
                  '登录继续记录你的生活',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                
                SizedBox(height: 40.h),
                
                // 用户名
                CustomTextField(
                  controller: usernameController,
                  hint: '用户名',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入用户名';
                    }
                    if (value.length < 3) {
                      return '用户名至少3位';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms),
                
                SizedBox(height: 16.h),
                
                // 密码
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
                )).animate().fadeIn(delay: 500.ms),
                
                SizedBox(height: 24.h),
                
                // 登录按钮
                Obx(() => CustomButton(
                  text: '登录',
                  isLoading: controller.isLoading,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final success = await controller.login(
                      usernameController.text.trim(),
                      passwordController.text,
                    );
                    
                    if (success) {
                      AppUtils.showSuccess('登录成功');
                      Get.offAllNamed(Routes.HOME);
                    } else {
                      AppUtils.showError('用户名或密码错误');
                    }
                  },
                )).animate().fadeIn(delay: 600.ms),
                
                SizedBox(height: 20.h),
                
                // 注册链接
                Center(
                  child: TextButton(
                    onPressed: () => Get.toNamed(Routes.REGISTER),
                    child: Text(
                      '还没有账号？立即注册',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
