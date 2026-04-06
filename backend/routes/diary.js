const express = require('express');
const { db } = require('../config/database');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// 创建日记
router.post('/', authMiddleware, (req, res) => {
  const { title, content, mood, weather, images, is_private = true } = req.body;
  
  if (!title || !content) {
    return res.status(400).json({ error: '标题和内容必填' });
  }

  db.run(
    `INSERT INTO diaries (user_id, title, content, mood, weather, images, is_private)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [req.userId, title, content, mood, weather, JSON.stringify(images || []), is_private ? 1 : 0],
    function(err) {
      if (err) {
        return res.status(500).json({ error: '创建日记失败' });
      }
      res.json({
        message: '日记创建成功',
        id: this.lastID
      });
    }
  );
});

// 获取我的日记列表
router.get('/my', authMiddleware, (req, res) => {
  const { page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;

  db.all(
    `SELECT d.*, u.nickname as author_name, u.avatar as author_avatar
     FROM diaries d
     JOIN users u ON d.user_id = u.id
     WHERE d.user_id = ?
     ORDER BY d.created_at DESC
     LIMIT ? OFFSET ?`,
    [req.userId, parseInt(limit), parseInt(offset)],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ error: '获取日记失败' });
      }
      res.json(rows.map(row => ({
        ...row,
        images: JSON.parse(row.images || '[]')
      })));
    }
  );
});

// 获取日记详情
router.get('/:id', authMiddleware, (req, res) => {
  db.get(
    `SELECT d.*, u.nickname as author_name, u.avatar as author_avatar
     FROM diaries d
     JOIN users u ON d.user_id = u.id
     WHERE d.id = ?`,
    [req.params.id],
    (err, row) => {
      if (err || !row) {
        return res.status(404).json({ error: '日记不存在' });
      }
      
      // 如果是私密日记且不是作者，拒绝访问
      if (row.is_private && row.user_id !== req.userId) {
        return res.status(403).json({ error: '无权查看此日记' });
      }
      
      res.json({
        ...row,
        images: JSON.parse(row.images || '[]')
      });
    }
  );
});

// 更新日记
router.put('/:id', authMiddleware, (req, res) => {
  const { title, content, mood, weather, images, is_private } = req.body;
  
  db.get('SELECT * FROM diaries WHERE id = ?', [req.params.id], (err, diary) => {
    if (err || !diary) {
      return res.status(404).json({ error: '日记不存在' });
    }
    
    if (diary.user_id !== req.userId) {
      return res.status(403).json({ error: '无权修改此日记' });
    }

    db.run(
      `UPDATE diaries 
       SET title = ?, content = ?, mood = ?, weather = ?, images = ?, is_private = ?, updated_at = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [title, content, mood, weather, JSON.stringify(images || []), is_private ? 1 : 0, req.params.id],
      function(err) {
        if (err) {
          return res.status(500).json({ error: '更新失败' });
        }
        res.json({ message: '日记更新成功' });
      }
    );
  });
});

// 删除日记
router.delete('/:id', authMiddleware, (req, res) => {
  db.get('SELECT * FROM diaries WHERE id = ?', [req.params.id], (err, diary) => {
    if (err || !diary) {
      return res.status(404).json({ error: '日记不存在' });
    }
    
    if (diary.user_id !== req.userId) {
      return res.status(403).json({ error: '无权删除此日记' });
    }

    db.run('DELETE FROM diaries WHERE id = ?', [req.params.id], function(err) {
      if (err) {
        return res.status(500).json({ error: '删除失败' });
      }
      res.json({ message: '日记删除成功' });
    });
  });
});

// 获取好友的公开日记
router.get('/friends/feed', authMiddleware, (req, res) => {
  const { page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;

  db.all(
    `SELECT d.*, u.nickname as author_name, u.avatar as author_avatar
     FROM diaries d
     JOIN users u ON d.user_id = u.id
     JOIN friendships f ON (f.user_id = ? AND f.friend_id = d.user_id)
     WHERE d.is_private = 0 AND f.status = 'accepted'
     ORDER BY d.created_at DESC
     LIMIT ? OFFSET ?`,
    [req.userId, parseInt(limit), parseInt(offset)],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ error: '获取失败' });
      }
      res.json(rows.map(row => ({
        ...row,
        images: JSON.parse(row.images || '[]')
      })));
    }
  );
});

module.exports = router;
