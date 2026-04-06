import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import '../../utils/app_utils.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _recentChats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentChats();
    _setupSocketListener();
  }

  void _setupSocketListener() {
    Get.find<SocketService>().addMessageListener((data) {
      _loadRecentChats();
    });
  }

  Future<void> _loadRecentChats() async {
    setState(() => _isLoading = true);
    try {
      final response = await Get.find<ApiService>().get('/chat/recent/list');
      setState(() {
        _recentChats = List<Map<String, dynamic>>.from(response.data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recentChats.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRecentChats,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _recentChats.length,
                    itemBuilder: (context, index) {
                      final chat = _recentChats[index];
                      final unreadCount = chat['unread_count'] ?? 0;
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 8.h),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                child: Text(chat['nickname']?[0] ?? '?'),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unreadCount > 99 ? '99+' : '$unreadCount',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            chat['nickname'] ?? chat['username'],
                            style: TextStyle(
                              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            chat['last_message'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                            ),
                          ),
                          trailing: Text(
                            _formatTime(chat['last_message_time']),
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                          ),
                          onTap: () => Get.toNamed(
                            Routes.CHAT.replaceAll(':userId', '${chat['contact_id']}'),
                            arguments: chat,
                          )?.then((_) => _loadRecentChats()),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text('暂无消息', style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => Get.toNamed(Routes.FRIENDS),
            child: const Text('去找好友聊天'),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '';
    final time = DateTime.parse(timeStr);
    final now = DateTime.now();
    
    if (time.year == now.year && time.month == now.month && time.day == now.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.month}/${time.day}';
  }
}
