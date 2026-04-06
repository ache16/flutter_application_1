import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../bindings/home_binding.dart';
import '../../models/diary_model.dart';
import '../../routes/app_pages.dart';
import '../../utils/app_utils.dart';

class DiaryCalendarScreen extends GetView<DiaryController> {
  const DiaryCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日记日历'),
      ),
      body: Obx(() {
        final diaries = controller.diaries.map((d) => Diary.fromJson(d)).toList();
        final diaryMap = <DateTime, List<Diary>>{};
        
        for (var diary in diaries) {
          final date = DateTime(diary.createdAt.year, diary.createdAt.month, diary.createdAt.day);
          diaryMap[date] = [...(diaryMap[date] ?? []), diary];
        }

        return Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: controller.selectedDate,
              selectedDayPredicate: (day) => isSameDay(day, controller.selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                controller.selectDate(selectedDay);
              },
              eventLoader: (day) => diaryMap[day] ?? [],
              calendarStyle: CalendarStyle(
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const Divider(),
            Expanded(
              child: _buildDiaryList(diaryMap[controller.selectedDate] ?? []),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDiaryList(List<Diary> diaries) {
    if (diaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 60, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text('这一天没有日记', style: TextStyle(color: Colors.grey[500])),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(Routes.DIARY_EDIT)?.then((_) => controller.loadDiaries()),
              icon: const Icon(Icons.edit),
              label: const Text('写一篇'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: diaries.length,
      itemBuilder: (context, index) {
        final diary = diaries[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: ListTile(
            leading: diary.moodEmoji != null
                ? Text(diary.moodEmoji!, style: const TextStyle(fontSize: 24))
                : null,
            title: Text(diary.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              diary.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              '${diary.createdAt.hour.toString().padLeft(2, '0')}:${diary.createdAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
            onTap: () => Get.toNamed(Routes.DIARY_DETAIL.replaceAll(':id', '${diary.id}')),
          ),
        );
      },
    );
  }
}
