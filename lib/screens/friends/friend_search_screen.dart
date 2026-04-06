import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../services/api_service.dart';
import '../../utils/app_utils.dart';

class FriendSearchScreen extends StatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  State<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends State<FriendSearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;

  Future<void> _search() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    setState(() => _isSearching = true);
    try {
      final response = await Get.find<ApiService>().get('/friends/search', queryParameters: {'keyword': keyword});
      setState(() {
        _results = List<Map<String, dynamic>>.from(response.data);
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _sendRequest(int friendId) async {
    try {
      await Get.find<ApiService>().post('/friends/request', data: {'friendId': friendId});
      AppUtils.showSuccess('好友请求已发送');
    } catch (e) {
      final error = e is DioException ? e.response?.data?['error'] : null;
      AppUtils.showError(error ?? '发送失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索用户名或昵称',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _search,
            ),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: (_) => _search(),
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty && _searchController.text.isNotEmpty
              ? Center(child: Text('未找到用户', style: TextStyle(color: Colors.grey[600])))
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final user = _results[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Text(user['nickname']?[0] ?? '?'),
                        ),
                        title: Text(user['nickname'] ?? user['username']),
                        subtitle: Text('@${user['username']}'),
                        trailing: ElevatedButton(
                          onPressed: () => _sendRequest(user['id']),
                          child: const Text('添加'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
