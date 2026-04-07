#!/usr/bin/env node

/**
 * 小六印记数据库查看工具
 * 用法: node db-viewer.js [表名] [操作]
 * 
 * 示例:
 *   node db-viewer.js              # 显示所有表
 *   node db-viewer.js users        # 查看 users 表所有数据
 *   node db-viewer.js users count  # 查看 users 表记录数
 *   node db-viewer.js users add    # 交互式添加用户
 */

const path = require('path');
const { db } = require(path.join(__dirname, 'config/database'));
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const table = process.argv[2];
const action = process.argv[3] || 'list';

function showTables() {
  console.log('\n📊 数据库表列表\n');
  db.all("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'", (err, rows) => {
    if (err) {
      console.error('❌ 错误:', err.message);
      process.exit(1);
    }
    rows.forEach((r, i) => {
      console.log(`  ${i + 1}. ${r.name}`);
    });
    console.log('\n💡 用法: node db-viewer.js [表名] [操作]');
    console.log('   操作: list(默认) | count | schema | add | delete');
    process.exit(0);
  });
}

function showSchema(table) {
  console.log(`\n📋 ${table} 表结构\n`);
  db.all(`PRAGMA table_info(${table})`, (err, cols) => {
    if (err) {
      console.error('❌ 错误:', err.message);
      process.exit(1);
    }
    console.log('  字段名          类型         可空    默认值');
    console.log('  ' + '-'.repeat(50));
    cols.forEach(c => {
      const name = c.name.padEnd(15);
      const type = c.type.padEnd(12);
      const notnull = c.notnull ? 'NOT NULL' : 'NULL';
      const dflt = c.dflt_value || '';
      console.log(`  ${name}${type}${notnull.padEnd(8)} ${dflt}`);
    });
    process.exit(0);
  });
}

function countRecords(table) {
  console.log(`\n🔢 ${table} 表记录数\n`);
  db.get(`SELECT COUNT(*) as count FROM ${table}`, (err, row) => {
    if (err) {
      console.error('❌ 错误:', err.message);
      process.exit(1);
    }
    console.log(`  总记录数: ${row.count}`);
    process.exit(0);
  });
}

function listRecords(table) {
  console.log(`\n📄 ${table} 表数据\n`);
  db.all(`SELECT * FROM ${table} LIMIT 100`, (err, rows) => {
    if (err) {
      console.error('❌ 错误:', err.message);
      process.exit(1);
    }
    if (rows.length === 0) {
      console.log('  (暂无数据)');
    } else {
      console.log(JSON.stringify(rows, null, 2));
    }
    console.log(`\n  显示 ${rows.length} 条记录 (最多100条)`);
    process.exit(0);
  });
}

function addUser() {
  console.log('\n➕ 添加新用户\n');
  
  const user = {};
  
  rl.question('用户名: ', (username) => {
    user.username = username;
    rl.question('昵称 (默认同用户名): ', (nickname) => {
      user.nickname = nickname || username;
      rl.question('邮箱 (可选): ', (email) => {
        user.email = email || null;
        rl.question('密码: ', (password) => {
          const bcrypt = require('bcryptjs');
          const passwordHash = bcrypt.hashSync(password, 10);
          
          db.run(
            'INSERT INTO users (username, nickname, email, password_hash) VALUES (?, ?, ?, ?)',
            [user.username, user.nickname, user.email, passwordHash],
            function(err) {
              if (err) {
                console.error('\n❌ 添加失败:', err.message);
              } else {
                console.log(`\n✅ 用户添加成功! ID: ${this.lastID}`);
              }
              rl.close();
              process.exit(0);
            }
          );
        });
      });
    });
  });
}

function deleteRecord(table) {
  rl.question(`\n⚠️  输入要删除的 ${table} ID: `, (id) => {
    db.run(`DELETE FROM ${table} WHERE id = ?`, [id], function(err) {
      if (err) {
        console.error('\n❌ 删除失败:', err.message);
      } else if (this.changes === 0) {
        console.log('\n⚠️  未找到该记录');
      } else {
        console.log(`\n✅ 已删除 ${table} ID=${id}`);
      }
      rl.close();
      process.exit(0);
    });
  });
}

// 主程序
if (!table) {
  showTables();
} else {
  switch (action) {
    case 'schema':
      showSchema(table);
      break;
    case 'count':
      countRecords(table);
      break;
    case 'add':
      if (table === 'users') {
        addUser();
      } else {
        console.log('❌ 暂不支持添加到该表');
        process.exit(1);
      }
      break;
    case 'delete':
      deleteRecord(table);
      break;
    case 'list':
    default:
      listRecords(table);
  }
}
