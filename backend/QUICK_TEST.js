/**
 * Quick test script to verify backend setup
 * Run: node QUICK_TEST.js
 */

const readline = require('readline');
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

console.log('\n🧪 SenseAI Backend Quick Test');
console.log('============================\n');

// Test 1: Check if .env exists
console.log('1️⃣ Checking if .env file exists...');
const fs = require('fs');
const path = require('path');

const envPath = path.join(__dirname, '.env');
if (fs.existsSync(envPath)) {
  console.log('✅ .env file found!\n');
  
  // Test 2: Try to load environment variables
  console.log('2️⃣ Checking environment variables...');
  require('dotenv').config();
  
  const requiredVars = [
    'FIREBASE_PROJECT_ID',
    'FIREBASE_CLIENT_EMAIL',
    'FIREBASE_PRIVATE_KEY',
    'PORT',
    'STORAGE_BUCKET'
  ];
  
  let allPresent = true;
  requiredVars.forEach(varName => {
    if (process.env[varName]) {
      console.log(`✅ ${varName}: Set`);
    } else {
      console.log(`❌ ${varName}: Missing`);
      allPresent = false;
    }
  });
  
  if (allPresent) {
    console.log('\n✅ All required environment variables are set!');
    console.log('\n3️⃣ Ready to start server!');
    console.log('   Run: npm run dev\n');
  } else {
    console.log('\n❌ Missing some environment variables.');
    console.log('   Please check your .env file.\n');
  }
  
} else {
  console.log('❌ .env file NOT found!');
  console.log('\n📝 Please create .env file:');
  console.log('   1. Read: CREATE_ENV_FILE.md');
  console.log('   2. Download Firebase service account key');
  console.log('   3. Create .env in backend/ folder');
  console.log('   4. Run this test again\n');
}

rl.question('\nPress Enter to exit...', () => {
  rl.close();
});




