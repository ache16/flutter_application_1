require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');

const authRoutes = require('./routes/auth');
const diaryRoutes = require('./routes/diary');
const friendRoutes = require('./routes/friend');
const chatRoutes = require('./routes/chat');
const { initDatabase } = require('./config/database');
const { setupSocketIO } = require('./config/socket');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 静态文件（图片上传）
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 路由
app.use('/api/auth', authRoutes);
app.use('/api/diary', diaryRoutes);
app.use('/api/friends', friendRoutes);
app.use('/api/chat', chatRoutes);

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Socket.IO 设置
setupSocketIO(io);

// 初始化数据库并启动服务器
initDatabase().then(() => {
  server.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 小六印记服务器运行在端口 ${PORT}`);
    console.log(`📡 服务器IP: 211.159.186.157`);
  });
}).catch(err => {
  console.error('数据库初始化失败:', err);
});

module.exports = { app, io };
