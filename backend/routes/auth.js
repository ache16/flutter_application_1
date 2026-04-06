const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { db } = require('../config/database');
const { JWT_SECRET } = require('../middleware/auth');

const router = express.Router();

// 注册
router.post('/register', async (req, res) => {
  const { username, password, nickname, email } = req.body;
  
  if (!username || !password) {
    return res.status(400).json({ error: '用户名和密码必填' });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    
    db.run(
      'INSERT INTO users (username, password_hash, nickname, email) VALUES (?, ?, ?, ?)',
      [username, hashedPassword, nickname || username, email || null],
      function(err) {
        if (err) {
          if (err.message.includes('UNIQUE constraint failed')) {
            return res.status(400).json({ error: '用户名或邮箱已存在' });
          }
          return res.status(500).json({ error: '注册失败' });
        }
        
        const token = jwt.sign(
          { userId: this.lastID, username },
          JWT_SECRET,
          { expiresIn: '7d' }
        );
        
        res.json({
          message: '注册成功',
          token,
          user: {
            id: this.lastID,
            username,
            nickname: nickname || username
          }
        });
      }
    );
  } catch (err) {
    res.status(500).json({ error: '服务器错误' });
  }
});

// 登录
router.post('/login', (req, res) => {
  const { username, password } = req.body;
  
  if (!username || !password) {
    return res.status(400).json({ error: '用户名和密码必填' });
  }

  db.get(
    'SELECT * FROM users WHERE username = ?',
    [username],
    async (err, user) => {
      if (err || !user) {
        return res.status(401).json({ error: '用户名或密码错误' });
      }

      const isValid = await bcrypt.compare(password, user.password_hash);
      if (!isValid) {
        return res.status(401).json({ error: '用户名或密码错误' });
      }

      const token = jwt.sign(
        { userId: user.id, username: user.username },
        JWT_SECRET,
        { expiresIn: '7d' }
      );

      res.json({
        message: '登录成功',
        token,
        user: {
          id: user.id,
          username: user.username,
          nickname: user.nickname,
          avatar: user.avatar,
          bio: user.bio
        }
      });
    }
  );
});

// 获取用户信息
router.get('/profile', require('../middleware/auth').authMiddleware, (req, res) => {
  db.get(
    'SELECT id, username, nickname, avatar, email, bio, created_at FROM users WHERE id = ?',
    [req.userId],
    (err, user) => {
      if (err || !user) {
        return res.status(404).json({ error: '用户不存在' });
      }
      res.json(user);
    }
  );
});

// 更新用户信息
router.put('/profile', require('../middleware/auth').authMiddleware, (req, res) => {
  const { nickname, avatar, bio } = req.body;
  
  db.run(
    'UPDATE users SET nickname = ?, avatar = ?, bio = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
    [nickname, avatar, bio, req.userId],
    function(err) {
      if (err) {
        return res.status(500).json({ error: '更新失败' });
      }
      res.json({ message: '更新成功' });
    }
  );
});

module.exports = router;
