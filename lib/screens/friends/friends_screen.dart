import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../services/api_service.dart';
import '../../utils/app_utils.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final friendsRes = await Get.find<ApiService>().get('/friends/list');
      final requestsRes = await Get.find<ApiService>().get('/friends/requests/pending');
      setState(() {
        _friends = List<Map<String, dynamic>>.from(friendsRes.data);
        _requests = List<Map<String, dynamic>>.from(requestsRes.data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRequest(int requestId) async {
    try {
      await Get.find<ApiService>().put('/friends/request/$requestId', data: {'action': 'accept'});
      AppUtils.showSuccess('已成为好友');
      _loadData();
    } catch (e) {
      AppUtils.showError('操作失败');
    }
  }

  Future<void> _rejectRequest(int requestId) async {
    try {
      await Get.find<ApiService>().put('/friends/request/$requestId', data: {'action': 'reject'});
      _loadData();
    } catch (e) {
      AppUtils.showError('操作失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('好友'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Get.toNamed(Routes.FRIEND_SEARCH)?.then((_) => _loadData()),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '好友 (${_friends.length})'),
            Tab(child: Badge(
              isLabelVisible: _requests.isNotEmpty,
              label: Text('${_requests.length}'),
              child: const Text('请求'),
            )),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(),
                _buildRequestsList(),
              ],
            ),
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return _buildEmptyState('还没有好友', Icons.people_outline, '去添加好友', () {
        Get.toNamed(Routes.FRIEND_SEARCH);
      });
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Text(friend['nickname']?[0] ?? '?'),
              ),
              title: Text(friend['nickname'] ?? friend['username']),
              subtitle: Text(friend['bio']?.isNotEmpty == true ? friend['bio'] : '暂无简介'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () => Get.toNamed(
                      Routes.CHAT.replaceAll(':userId', '${friend['id']}'),
                      arguments: friend,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsList() {
    if (_requests.isEmpty) {
      return _buildEmptyState('暂无好友请求', Icons.person_add_disabled, null, null);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Text(request['nickname']?[0] ?? '?'),
            ),
            title: Text(request['nickname'] ?? request['username']),
            subtitle: Text('@${request['username']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _acceptRequest(request['request_id']),
                  child: const Text('接受'),
                ),
                TextButton(
                  onPressed: () => _rejectRequest(request['request_id']),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text('忽略'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, IconData icon, String? buttonText, VoidCallback? onPressed) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(title, style: TextStyle(color: Colors.grey[600])),
          if (buttonText != null) ...[
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
