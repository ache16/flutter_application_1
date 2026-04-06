import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_utils.dart';

class ChatScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic>? userInfo;

  const ChatScreen({super.key, required this.userId, this.userInfo});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupSocketListener();
  }

  void _setupSocketListener() {
    Get.find<SocketService>().addMessageListener((data) {
      if (data['senderId'] == widget.userId || data['receiverId'] == widget.userId) {
        setState(() {
          _messages.add({
            'id': data['id'],
            'sender_id': int.parse(data['senderId']),
            'receiver_id': int.parse(data['receiverId']),
            'content': data['content'],
            'type': data['type'],
            'created_at': data['created_at'],
          });
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final response = await Get.find<ApiService>().get('/chat/${widget.userId}');
      setState(() {
        _messages.addAll(List<Map<String, dynamic>>.from(response.data));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final user = Get.find<StorageService>().getUser();
    
    setState(() {
      _messages.add({
        'sender_id': user?['id'],
        'receiver_id': widget.userId,
        'content': content,
        'type': 'text',
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    _messageController.clear();
    _scrollToBottom();

    Get.find<SocketService>().sendMessage(widget.userId.toString(), content);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Get.find<StorageService>().getUser();
    final nickname = widget.userInfo?['nickname'] ?? widget.userInfo?['username'] ?? '聊天';
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(nickname),
            if (_isTyping)
              Text('正在输入...', style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat, size: 60, color: Colors.grey[300]),
                            SizedBox(height: 16.h),
                            Text('开始聊天吧', style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.w),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message['sender_id'] == user?['id'];
                          
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(
                                bottom: 8.h,
                                left: isMe ? 60.w : 0,
                                right: isMe ? 0 : 60.w,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: isMe 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20.r).copyWith(
                                  bottomRight: isMe ? const Radius.circular(4) : null,
                                  bottomLeft: !isMe ? const Radius.circular(4) : null,
                                ),
                              ),
                              child: Text(
                                message['content'],
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: '输入消息...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    Get.find<SocketService>().removeMessageListener((_) {});
    super.dispose();
  }
}
