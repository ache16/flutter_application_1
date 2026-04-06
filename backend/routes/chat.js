const express = require('express');
const { db } = require('../config/database');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// 获取聊天记录
router.get('/:friendId', authMiddleware, (req, res) => {
  const { page = 1, limit = 50 } = req.query;
  const offset = (page - 1) * limit;

  db.all(
    `SELECT m.*, 
            s.nickname as sender_name, s.avatar as sender_avatar,
            r.nickname as receiver_name, r.avatar as receiver_avatar
     FROM messages m
     JOIN users s ON m.sender_id = s.id
     JOIN users r ON m.receiver_id = r.id
     WHERE (m.sender_id = ? AND m.receiver_id = ?) OR (m.sender_id = ? AND m.receiver_id = ?)
     ORDER BY m.created_at DESC
     LIMIT ? OFFSET ?`,
    [req.userId, req.params.friendId, req.params.friendId, req.userId, parseInt(limit), parseInt(offset)],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ error: '获取聊天记录失败' });
      }
      
      // 标记为已读
      db.run(
        'UPDATE messages SET is_read = 1 WHERE receiver_id = ? AND sender_id = ?',
        [req.userId, req.params.friendId]
      );
      
      res.json(rows.reverse()); // 按时间正序返回
    }
  );
});

// 发送消息（HTTP方式，用于Socket.io不可用的情况）
router.post('/:friendId', authMiddleware, (req, res) => {
  const { content, type = 'text' } = req.body;
  
  if (!content) {
    return res.status(400).json({ error: '消息内容不能为空' });
  }

  db.run(
    'INSERT INTO messages (sender_id, receiver_id, content, type) VALUES (?, ?, ?, ?)',
    [req.userId, req.params.friendId, content, type],
    function(err) {
      if (err) {
        return res.status(500).json({ error: '发送消息失败' });
      }
      
      // 获取刚插入的消息
      db.get(
        `SELECT m.*, 
                s.nickname as sender_name, s.avatar as sender_avatar,
                r.nickname as receiver_name, r.avatar as receiver_avatar
         FROM messages m
         JOIN users s ON m.sender_id = s.id
         JOIN users r ON m.receiver_id = r.id
         WHERE m.id = ?`,
        [this.lastID],
        (err, row) => {
          if (err) {
            return res.status(500).json({ error: '获取消息失败' });
          }
          res.json(row);
        }
      );
    }
  );
});

// 获取未读消息数量
router.get('/unread/count', authMiddleware, (req, res) => {
  db.all(
    `SELECT sender_id, COUNT(*) as count 
     FROM messages 
     WHERE receiver_id = ? AND is_read = 0 
     GROUP BY sender_id`,
    [req.userId],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ error: '获取未读消息失败' });
      }
      const result = {};
      rows.forEach(row => {
        result[row.sender_id] = row.count;
      });
      res.json(result);
    }
  );
});

// 获取最近联系人列表
router.get('/recent/list', authMiddleware, (req, res) => {
  db.all(
    `SELECT 
       CASE 
         WHEN m.sender_id = ? THEN m.receiver_id 
         ELSE m.sender_id 
       END as contact_id,
       u.nickname, u.avatar, u.username,
       MAX(m.created_at) as last_message_time,
       (SELECT content FROM messages 
        WHERE ((sender_id = ? AND receiver_id = contact_id) OR (sender_id = contact_id AND receiver_id = ?))
        ORDER BY created_at DESC LIMIT 1) as last_message,
       (SELECT COUNT(*) FROM messages WHERE sender_id = contact_id AND receiver_id = ? AND is_read = 0) as unread_count
     FROM messages m
     JOIN users u ON u.id = CASE WHEN m.sender_id = ? THEN m.receiver_id ELSE m.sender_id END
     WHERE m.sender_id = ? OR m.receiver_id = ?
     GROUP BY contact_id
     ORDER BY last_message_time DESC
     LIMIT 20`,
    [req.userId, req.userId, req.userId, req.userId, req.userId, req.userId, req.userId],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ error: '获取最近联系人失败' });
      }
      res.json(rows);
    }
  );
});

module.exports = router;
