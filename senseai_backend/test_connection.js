/**
 * Quick Connection Test Script
 * Run this to test if your backend is accessible
 * 
 * Usage:
 *   node test_connection.js
 *   node test_connection.js YOUR_IP_ADDRESS
 */

const http = require('http');

const testIP = process.argv[2] || 'localhost';
const testURL = `http://${testIP}:3000/health`;

console.log('='.repeat(50));
console.log('Backend Connection Test');
console.log('='.repeat(50));
console.log(`Testing: ${testURL}`);
console.log('');

const startTime = Date.now();

const req = http.get(testURL, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    const duration = Date.now() - startTime;
    
    if (res.statusCode === 200) {
      console.log('✅ SUCCESS!');
      console.log(`   Status: ${res.statusCode}`);
      console.log(`   Response: ${data}`);
      console.log(`   Time: ${duration}ms`);
      console.log('');
      console.log('✅ Your backend is running and accessible!');
      console.log(`   Use this URL in your app: http://${testIP}:3000`);
    } else {
      console.log('❌ FAILED!');
      console.log(`   Status: ${res.statusCode}`);
      console.log(`   Response: ${data}`);
      console.log('');
      console.log('⚠️  Backend responded but with error status');
    }
  });
});

req.on('error', (error) => {
  const duration = Date.now() - startTime;
  
  console.log('❌ CONNECTION FAILED!');
  console.log(`   Error: ${error.message}`);
  console.log(`   Time: ${duration}ms`);
  console.log('');
  
  if (error.code === 'ECONNREFUSED') {
    console.log('🔧 Troubleshooting:');
    console.log('   1. Is backend running? Run: npm start');
    console.log('   2. Is port 3000 correct?');
    console.log('   3. Check if another app is using port 3000');
  } else if (error.code === 'ENOTFOUND' || error.code === 'EAI_AGAIN') {
    console.log('🔧 Troubleshooting:');
    console.log('   1. Check IP address is correct');
    console.log('   2. For localhost, use: node test_connection.js');
    console.log('   3. For network IP, use: node test_connection.js 192.168.1.100');
  } else if (error.code === 'ETIMEDOUT') {
    console.log('🔧 Troubleshooting:');
    console.log('   1. Check Windows Firewall allows port 3000');
    console.log('   2. Check both devices are on same Wi-Fi');
    console.log('   3. Try pinging the IP address');
  } else {
    console.log('🔧 Troubleshooting:');
    console.log('   1. Check network connection');
    console.log('   2. Check firewall settings');
    console.log('   3. Verify IP address');
  }
});

req.setTimeout(5000, () => {
  req.destroy();
  console.log('❌ TIMEOUT!');
  console.log('   Connection timed out after 5 seconds');
  console.log('');
  console.log('🔧 Troubleshooting:');
  console.log('   1. Check if backend is running');
  console.log('   2. Check Windows Firewall');
  console.log('   3. Check network connection');
  console.log('   4. Verify IP address is correct');
});

console.log('Testing connection...');
console.log('');


