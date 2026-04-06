import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '../../bindings/home_binding.dart';
import '../../models/diary_model.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class DiaryListScreen extends GetView<DiaryController> {
  const DiaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的日记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => Get.toNamed(Routes.DIARY_CALENDAR),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.diaries.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.loadDiaries,
          child: MasonryGridView.count(
            padding: EdgeInsets.all(16.w),
            crossAxisCount: 2,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            itemCount: controller.diaries.length,
            itemBuilder: (context, index) {
              final diary = Diary.fromJson(controller.diaries[index]);
              return _DiaryCard(diary: diary, index: index);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.DIARY_EDIT)?.then((_) => controller.loadDiaries()),
        icon: const Icon(Icons.edit),
        label: const Text('写日记'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            '还没有日记',
            style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),
          Text(
            '点击右下角开始记录你的第一篇日记',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _DiaryCard extends StatelessWidget {
  final Diary diary;
  final int index;

  const _DiaryCard({required this.diary, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.DIARY_DETAIL.replaceAll(':id', '${diary.id}'))
            ?.then((_) => Get.find<DiaryController>().loadDiaries()),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: _getGradient(index),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (diary.moodEmoji != null)
                    Text(diary.moodEmoji!, style: const TextStyle(fontSize: 20)),
                  if (diary.weatherEmoji != null) ...[
                    SizedBox(width: 4.w),
                    Text(diary.weatherEmoji!, style: const TextStyle(fontSize: 20)),
                  ],
                  const Spacer(),
                  if (diary.isPrivate)
                    Icon(Icons.lock, size: 14, color: Colors.grey[600]),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                diary.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Text(
                diary.content,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),
              Text(
                AppUtils.getRelativeTime(diary.createdAt.toIso8601String()),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getGradient(int index) {
    final colors = [
      [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
      [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
      [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
      [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
      [const Color(0xFFFCE4EC), const Color(0xFFF8BBD9)],
      [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)],
    ];
    final colorPair = colors[index % colors.length];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colorPair,
    );
  }
}
