const { db } = require('./database');

const setupSocketIO = (io) => {
  const userSockets = new Map(); // userId -> socketId

  io.on('connection', (socket) => {
    console.log('用户连接:', socket.id);

    // 用户登录后关联 socket
    socket.on('join', (userId) => {
      userSockets.set(userId, socket.id);
      console.log(`用户 ${userId} 加入聊天`);
    });

    // 发送私聊消息
    socket.on('private_message', async (data) => {
      const { senderId, receiverId, content, type = 'text' } = data;
      
      // 保存消息到数据库
      const query = `
        INSERT INTO messages (sender_id, receiver_id, content, type)
        VALUES (?, ?, ?, ?)
      `;
      
      db.run(query, [senderId, receiverId, content, type], function(err) {
        if (err) {
          console.error('保存消息失败:', err);
          return;
        }

        const messageId = this.lastID;
        
        // 发送给接收者（如果在线）
        const receiverSocketId = userSockets.get(receiverId.toString());
        if (receiverSocketId) {
          io.to(receiverSocketId).emit('new_message', {
            id: messageId,
            senderId,
            receiverId,
            content,
            type,
            created_at: new Date().toISOString()
          });
        }

        // 确认发送成功
        socket.emit('message_sent', { id: messageId });
      });
    });

    // 断开连接
    socket.on('disconnect', () => {
      for (const [userId, socketId] of userSockets.entries()) {
        if (socketId === socket.id) {
          userSockets.delete(userId);
          console.log(`用户 ${userId} 断开连接`);
          break;
        }
      }
    });
  });

  global.userSockets = userSockets;
};

module.exports = { setupSocketIO };
