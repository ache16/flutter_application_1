const express = require('express');
const { db } = require('../config/database');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// 搜索用户
router.get('/search', authMiddleware, (req, res) => {
  const { keyword } = req.query;
  
  if (!keyword) {
    return res.status(400).json({ error: '搜索关键词必填' });
  }

  db.all(
    `SELECT id, username, nickname, avatar, bio 
     FROM users 
     WHERE (username LIKE ? OR nickname LIKE ?) AND id != ?
     LIMIT 20`,
    [`%${keyword}%`, `%${keyword}%`, req.userId],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ error: '搜索失败' });
      }
      res.json(rows);
    }
  );
});

// 发送好友请求
router.post('/request', authMiddleware, (req, res) => {
  const { friendId } = req.body;
  
  if (!friendId || friendId == req.userId) {
    return res.status(400).json({ error: '无效的用户ID' });
  }

  // 检查是否已经是好友或有待处理的请求
  db.get(
    'SELECT * FROM friendships WHERE (user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)',
    [req.userId, friendId, friendId, req.userId],
    (err, existing) => {
      if (err) {
        return res.status(500).json({ error: '查询失败' });
      }
      
      if (existing) {
        if (existing.status === 'accepted') {
          return res.status(400).json({ error: '已经是好友' });
        }
        if (existing.user_id == req.userId) {
          return res.status(400).json({ error: '好友请求已发送' });
        }
        if (existing.friend_id == req.userId) {
          return res.status(400).json({ error: '对方已发送请求，请直接接受' });
        }
      }

      db.run(
        'INSERT INTO friendships (user_id, friend_id, status) VALUES (?, ?, ?)',
        [req.userId, friendId, 'pending'],
        function(err) {
          if (err) {
            return res.status(500).json({ error: '发送请求失败' });
          }
          res.json({ message: '好友请求已发送', id: this.lastID });
        }
      );
    }
  );
});

// 接受/拒绝好友请求
router.put('/request/:id', authMiddleware, (req, res) => {
  const { action } = req.body; // 'accept' or 'reject'
  
  db.get(
    'SELECT * FROM friendships WHERE id = ? AND friend_id = ? AND status = ?',
    [req.params.id, req.userId, 'pending'],
    (err, request) => {
      if (err || !request) {
        return res.status(404).json({ error: '请求不存在' });
      }

      if (action === 'accept') {
        db.run(
          'UPDATE friendships SET status = ? WHERE id = ?',
          ['accepted', req.params.id],
          function(err) {
            if (err) {
              return res.status(500).json({ error: '接受请求失败' });
            }
            res.json({ message: '已成为好友' });
          }
        );
      } else {
        db.run(
          'DELETE FROM friendships WHERE id = ?',
          [req.params.id],
          function(err) {
            if (err) {
              return res.status(500).json({ error: '拒绝请求失败' });
            }
            res.json({ message: '已拒绝好友请求' });
          }
        );
      }
    }
  );
});

// 获取好友列表
router.get('/list', authMiddleware, (req, res) => {
  db.all(
    `SELECT u.id, u.username, u.nickname, u.avatar, u.bio, f.created_at as friendship_date
     FROM friendships f
     JOIN users u ON (f.user_id = ? AND f.friend_id = u.id) OR (f.friend_id = ? AND f.user_id = u.id)
     WHERE f.status = 'accepted'`,
    [req.userId, req.userId],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ error: '获取好友列表失败' });
      }
      res.json(rows);
    }
  );
});

// 获取待处理的好友请求
router.get('/requests/pending', authMiddleware, (req, res) => {
  db.all(
    `SELECT f.id as request_id, u.id, u.username, u.nickname, u.avatar, f.created_at
     FROM friendships f
     JOIN users u ON f.user_id = u.id
     WHERE f.friend_id = ? AND f.status = 'pending'`,
    [req.userId],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ error: '获取请求失败' });
      }
      res.json(rows);
    }
  );
});

// 删除好友
router.delete('/:friendId', authMiddleware, (req, res) => {
  db.run(
    `DELETE FROM friendships 
     WHERE (user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)`,
    [req.userId, req.params.friendId, req.params.friendId, req.userId],
    function(err) {
      if (err) {
        return res.status(500).json({ error: '删除好友失败' });
      }
      res.json({ message: '已删除好友' });
    }
  );
});

module.exports = router;
