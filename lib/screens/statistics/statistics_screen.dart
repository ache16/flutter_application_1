import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../bindings/home_binding.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            SizedBox(height: 24.h),
            _buildMoodChart(),
            SizedBox(height: 24.h),
            _buildActivityChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: '日记总数',
            value: '128',
            icon: Icons.book,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _StatCard(
            title: '连续记录',
            value: '15天',
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _StatCard(
            title: '好友数量',
            value: '23',
            icon: Icons.people,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('心情分布', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _showingSections(),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 16.w,
              children: [
                _buildLegend('开心', Colors.yellow),
                _buildLegend('平静', Colors.green),
                _buildLegend('难过', Colors.blue),
                _buildLegend('生气', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    return [
      PieChartSectionData(
        color: Colors.yellow,
        value: 40,
        title: '40%',
        radius: _touchedIndex == 0 ? 60 : 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 30,
        title: '30%',
        radius: _touchedIndex == 1 ? 60 : 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: 20,
        title: '20%',
        radius: _touchedIndex == 2 ? 60 : 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: 10,
        title: '10%',
        radius: _touchedIndex == 3 ? 60 : 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12.w, height: 12.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 4.w),
        Text(label, style: TextStyle(fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildActivityChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('最近7天活跃', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['一', '二', '三', '四', '五', '六', '日'];
                          return Text(days[value.toInt()], style: TextStyle(fontSize: 12.sp));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _makeGroupData(0, 3),
                    _makeGroupData(1, 1),
                    _makeGroupData(2, 4),
                    _makeGroupData(3, 2),
                    _makeGroupData(4, 5),
                    _makeGroupData(5, 2),
                    _makeGroupData(6, 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, int y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          color: Theme.of(context).colorScheme.primary,
          width: 20.w,
          borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 8.h),
            Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
