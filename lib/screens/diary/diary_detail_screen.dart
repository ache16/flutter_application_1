import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../models/diary_model.dart';
import '../../routes/app_pages.dart';
import '../../services/api_service.dart';
import '../../utils/app_utils.dart';

class DiaryDetailScreen extends StatefulWidget {
  final int id;

  const DiaryDetailScreen({super.key, required this.id});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  Diary? _diary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiary();
  }

  Future<void> _loadDiary() async {
    try {
      final response = await Get.find<ApiService>().get('/diary/${widget.id}');
      setState(() {
        _diary = Diary.fromJson(response.data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      AppUtils.showError('加载失败');
      Get.back();
    }
  }

  Future<void> _deleteDiary() async {
    final confirm = await AppUtils.showConfirm(
      title: '删除日记',
      message: '确定要删除这篇日记吗？此操作不可恢复。',
      confirmText: '删除',
      isDanger: true,
    );

    if (!confirm) return;

    try {
      await Get.find<ApiService>().delete('/diary/${widget.id}');
      AppUtils.showSuccess('已删除');
      Get.back(result: true);
    } catch (e) {
      AppUtils.showError('删除失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _diary != null
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Get.toNamed(Routes.DIARY_EDIT, arguments: _diary!.toJson())
                      ?.then((_) => _loadDiary()),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteDiary,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _diary == null
              ? const Center(child: Text('日记不存在'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_diary!.moodEmoji != null)
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(_diary!.moodEmoji!, style: TextStyle(fontSize: 24.sp)),
                ),
              if (_diary!.weatherEmoji != null) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(_diary!.weatherEmoji!, style: TextStyle(fontSize: 24.sp)),
                ),
              ],
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            _diary!.title,
            style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.access_time, size: 14.sp, color: Colors.grey[500]),
              SizedBox(width: 4.w),
              Text(
                AppUtils.formatDate(_diary!.createdAt, format: 'yyyy年MM月dd日 HH:mm'),
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
              ),
              if (_diary!.isPrivate) ...[
                SizedBox(width: 12.w),
                Icon(Icons.lock, size: 14.sp, color: Colors.grey[500]),
                SizedBox(width: 4.w),
                Text('私密', style: TextStyle(fontSize: 13.sp, color: Colors.grey[500])),
              ],
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            _diary!.content,
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.8,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
