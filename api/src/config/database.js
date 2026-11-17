const dns = require('dns');
const mongoose = require('mongoose');

// Dùng Google/Cloudflare DNS để đảm bảo phân giải SRV của MongoDB Atlas ổn định trên Windows
try {
  dns.setDefaultResultOrder?.('ipv4first');
  dns.setServers(['8.8.8.8', '1.1.1.1']);
} catch (_) {}

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/task_manager_db');
    console.log(`[MongoDB] Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error(`[MongoDB] Connection Error: ${error.message}`);
    // Do not exit in development so server still runs
  }
};

module.exports = connectDB;
