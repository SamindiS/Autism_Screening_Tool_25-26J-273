/**
 * Script to create .env file from Firebase JSON
 * Run: node create-env.js
 */

const fs = require('fs');
const path = require('path');

console.log('🔧 Creating .env file from Firebase JSON...\n');

// Read Firebase JSON file
const jsonPath = path.join(__dirname, 'senseai-cognitive-firebase-adminsdk-fbsvc-f7bb21e9f5.json');

if (!fs.existsSync(jsonPath)) {
  console.error('❌ Error: Firebase JSON file not found!');
  console.error('Expected: senseai-cognitive-firebase-adminsdk-fbsvc-f7bb21e9f5.json');
  process.exit(1);
}

const firebaseConfig = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

// Create .env content
const envContent = `# Firebase Configuration
FIREBASE_PROJECT_ID=${firebaseConfig.project_id}
FIREBASE_CLIENT_EMAIL=${firebaseConfig.client_email}
FIREBASE_PRIVATE_KEY="${firebaseConfig.private_key}"

# Server Configuration
PORT=3000
NODE_ENV=development

# ML API Configuration (optional)
ML_API_URL=http://localhost:5000/predict
ML_API_KEY=optional

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8081,http://localhost:19006,http://10.0.2.2:3000

# Storage Configuration
STORAGE_BUCKET=senseai-cognitive.firebasestorage.app
`;

// Write to .env file
const envPath = path.join(__dirname, '.env');
fs.writeFileSync(envPath, envContent, 'utf8');

console.log('✅ .env file created successfully!');
console.log('\n📁 Location:', envPath);
console.log('\n✅ Values set:');
console.log('  - FIREBASE_PROJECT_ID:', firebaseConfig.project_id);
console.log('  - FIREBASE_CLIENT_EMAIL:', firebaseConfig.client_email);
console.log('  - FIREBASE_PRIVATE_KEY: [HIDDEN - Length:', firebaseConfig.private_key.length, 'chars]');
console.log('\n🚀 Next step: Run "npm run dev" to start the backend!');
console.log('\n✅ Done!');




