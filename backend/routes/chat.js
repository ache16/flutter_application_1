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
  const userId = req.userId;
  
  // 先获取有聊天记录的联系人ID列表
  db.all(
    `SELECT 
       CASE 
         WHEN sender_id = ? THEN receiver_id 
         ELSE sender_id 
       END as contact_id,
       MAX(created_at) as last_message_time
     FROM messages 
     WHERE sender_id = ? OR receiver_id = ?
     GROUP BY contact_id
     ORDER BY last_message_time DESC
     LIMIT 20`,
    [userId, userId, userId],
    (err, contacts) => {
      if (err) {
        console.error('获取联系人失败:', err);
        return res.status(500).json({ error: '获取最近联系人失败' });
      }
      
      if (contacts.length === 0) {
        return res.json([]);
      }
      
      // 获取每个联系人的详细信息
      const contactIds = contacts.map(c => c.contact_id);
      const placeholders = contactIds.map(() => '?').join(',');
      
      db.all(
        `SELECT id, nickname, avatar, username FROM users WHERE id IN (${placeholders})`,
        contactIds,
        (err, users) => {
          if (err) {
            console.error('获取用户信息失败:', err);
            return res.status(500).json({ error: '获取用户信息失败' });
          }
          
          // 获取最后一条消息和未读数
          const result = contacts.map(contact => {
            const user = users.find(u => u.id === contact.contact_id) || {};
            return {
              contact_id: contact.contact_id,
              nickname: user.nickname,
              avatar: user.avatar,
              username: user.username,
              last_message_time: contact.last_message_time
            };
          });
          
          // 异步获取每条的最后消息和未读数
          let completed = 0;
          result.forEach((item, index) => {
            // 获取最后一条消息
            db.get(
              `SELECT content FROM messages 
               WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)
               ORDER BY created_at DESC LIMIT 1`,
              [userId, item.contact_id, item.contact_id, userId],
              (err, msg) => {
                if (msg) result[index].last_message = msg.content;
                
                // 获取未读数
                db.get(
                  `SELECT COUNT(*) as count FROM messages 
                   WHERE sender_id = ? AND receiver_id = ? AND is_read = 0`,
                  [item.contact_id, userId],
                  (err, unread) => {
                    result[index].unread_count = unread ? unread.count : 0;
                    completed++;
                    if (completed === result.length) {
                      res.json(result);
                    }
                  }
                );
              }
            );
          });
        }
      );
    }
  );
});

module.exports = router;
