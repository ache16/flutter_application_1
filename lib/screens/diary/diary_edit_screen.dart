import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../utils/app_utils.dart';

class DiaryEditScreen extends StatefulWidget {
  final Map<String, dynamic>? diary;

  const DiaryEditScreen({super.key, this.diary});

  @override
  State<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends State<DiaryEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _scrollController = ScrollController();

  String? _selectedMood;
  String? _selectedWeather;
  bool _isPrivate = false;
  bool _isSaving = false;

  final List<Map<String, String>> _moods = [
    {'emoji': '😊', 'name': 'happy', 'label': '开心'},
    {'emoji': '😢', 'name': 'sad', 'label': '难过'},
    {'emoji': '😠', 'name': 'angry', 'label': '生气'},
    {'emoji': '😰', 'name': 'anxious', 'label': '焦虑'},
    {'emoji': '😍', 'name': 'love', 'label': '喜欢'},
    {'emoji': '😴', 'name': 'tired', 'label': '疲惫'},
    {'emoji': '🤔', 'name': 'thinking', 'label': '思考'},
    {'emoji': '😎', 'name': 'cool', 'label': '酷'},
    {'emoji': '🤩', 'name': 'excited', 'label': '兴奋'},
    {'emoji': '😌', 'name': 'calm', 'label': '平静'},
  ];

  final List<Map<String, String>> _weathers = [
    {'emoji': '☀️', 'name': 'sunny', 'label': '晴天'},
    {'emoji': '☁️', 'name': 'cloudy', 'label': '多云'},
    {'emoji': '🌧️', 'name': 'rainy', 'label': '下雨'},
    {'emoji': '⛈️', 'name': 'stormy', 'label': '雷雨'},
    {'emoji': '🌨️', 'name': 'snowy', 'label': '下雪'},
    {'emoji': '🌤️', 'name': 'partly_cloudy', 'label': '局部多云'},
    {'emoji': '💨', 'name': 'windy', 'label': '大风'},
    {'emoji': '🌫️', 'name': 'foggy', 'label': '雾霾'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.diary != null) {
      _titleController.text = widget.diary!['title'] ?? '';
      _contentController.text = widget.diary!['content'] ?? '';
      _selectedMood = widget.diary!['mood'];
      _selectedWeather = widget.diary!['weather'];
      _isPrivate = widget.diary!['is_private'] == 1 || widget.diary!['is_private'] == true;
    }
  }

  Future<void> _saveDiary() async {
    if (_titleController.text.trim().isEmpty) {
      AppUtils.showError('请输入标题');
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      AppUtils.showError('请输入内容');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'mood': _selectedMood,
        'weather': _selectedWeather,
        'is_private': _isPrivate,
      };

      if (widget.diary != null) {
        await Get.find<ApiService>().put('/diary/${widget.diary!['id']}', data: data);
      } else {
        await Get.find<ApiService>().post('/diary/', data: data);
      }

      AppUtils.showSuccess(widget.diary != null ? '日记已更新' : '日记已保存');
      Get.back(result: true);
    } catch (e) {
      AppUtils.showError('保存失败');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diary != null ? '编辑日记' : '写日记'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveDiary,
              child: const Text('保存', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            TextField(
              controller: _titleController,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '标题',
                hintStyle: TextStyle(fontSize: 24.sp, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SizedBox(height: 16.h),
            
            // 心情选择
            _buildSectionTitle('心情'),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood['name'];
                return ChoiceChip(
                  avatar: Text(mood['emoji']!, style: const TextStyle(fontSize: 18)),
                  label: Text(mood['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedMood = selected ? mood['name'] : null);
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),
            
            // 天气选择
            _buildSectionTitle('天气'),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _weathers.map((weather) {
                final isSelected = _selectedWeather == weather['name'];
                return ChoiceChip(
                  avatar: Text(weather['emoji']!, style: const TextStyle(fontSize: 18)),
                  label: Text(weather['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedWeather = selected ? weather['name'] : null);
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),
            
            // 内容
            _buildSectionTitle('内容'),
            SizedBox(height: 8.h),
            TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 10,
              style: TextStyle(fontSize: 16.sp, height: 1.8),
              decoration: InputDecoration(
                hintText: '写下今天的故事...',
                hintStyle: TextStyle(fontSize: 16.sp, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SizedBox(height: 20.h),
            
            // 隐私设置
            SwitchListTile(
              title: const Text('私密日记'),
              subtitle: const Text('仅自己可见'),
              value: _isPrivate,
              onChanged: (value) => setState(() => _isPrivate = value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
