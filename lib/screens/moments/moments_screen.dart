import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';

class MomentsScreen extends StatelessWidget {
  const MomentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟朋友圈数据
    final moments = [
      {
        'user': {'nickname': '小明', 'avatar': null},
        'content': '今天天气真好，出去散步了！',
        'images': [],
        'mood': '😊',
        'time': '10分钟前',
        'likes': 12,
        'comments': 3,
      },
      {
        'user': {'nickname': '小红', 'avatar': null},
        'content': '读完了一本好书，收获很多。',
        'images': [],
        'mood': '🤔',
        'time': '1小时前',
        'likes': 8,
        'comments': 5,
      },
      {
        'user': {'nickname': '小李', 'avatar': null},
        'content': '今天的工作完成了，开心！',
        'images': [],
        'mood': '😎',
        'time': '3小时前',
        'likes': 15,
        'comments': 2,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('朋友圈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: moments.length,
        itemBuilder: (context, index) {
          final moment = moments[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: Text((moment['user']['nickname'] as String)[0]),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              moment['user']['nickname'] as String,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                            ),
                            Text(
                              moment['time'] as String,
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      Text(moment['mood'] as String, style: TextStyle(fontSize: 20.sp)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    moment['content'] as String,
                    style: TextStyle(fontSize: 15.sp, height: 1.5),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 18.sp, color: Colors.grey[500]),
                      SizedBox(width: 4.w),
                      Text('${moment['likes']}', style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
                      SizedBox(width: 16.w),
                      Icon(Icons.chat_bubble_outline, size: 18.sp, color: Colors.grey[500]),
                      SizedBox(width: 4.w),
                      Text('${moment['comments']}', style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
