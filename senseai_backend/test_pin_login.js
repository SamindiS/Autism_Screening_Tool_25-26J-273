/**
 * Test PIN Login Script
 * 
 * Usage: node test_pin_login.js <PIN>
 * Example: node test_pin_login.js 1234
 * 
 * This script tests the PIN login functionality directly,
 * helping to diagnose login issues.
 */

const bcrypt = require('bcrypt');
const { db } = require('./firebase');

async function testPinLogin(pin) {
  try {
    console.log('\n' + '='.repeat(50));
    console.log('🧪 TESTING PIN LOGIN');
    console.log('='.repeat(50));
    console.log(`📌 Testing PIN: ${pin}`);
    console.log(`📌 PIN length: ${pin.length}`);
    console.log(`📌 PIN type: ${typeof pin}`);
    console.log(`📌 PIN trimmed: "${pin.trim()}"`);
    
    // Get all clinicians
    const collection = db.collection('clinicians');
    const allClinicians = await collection.get();
    
    console.log(`\n📋 Found ${allClinicians.docs.length} clinicians in database\n`);
    
    if (allClinicians.docs.length === 0) {
      console.log('❌ No clinicians found in database!');
      console.log('   Please register a clinician first.');
      return;
    }
    
    const pinToCompare = String(pin).trim();
    let foundMatch = false;
    
    // Test each clinician
    for (const doc of allClinicians.docs) {
      const data = doc.data();
      const clinicianId = doc.id;
      const clinicianName = data.name || 'Unknown';
      
      console.log(`\n🔍 Testing clinician: ${clinicianId} (${clinicianName})`);
      
      // Check if pin_hash exists
      if (!data.pin_hash) {
        console.log(`   ⚠️  No pin_hash found for this clinician`);
        continue;
      }
      
      console.log(`   📝 pin_hash exists: ${data.pin_hash.substring(0, 20)}...`);
      
      // Compare PIN
      const match = await bcrypt.compare(pinToCompare, data.pin_hash);
      
      if (match) {
        console.log(`   ✅ PIN MATCH! Login would succeed for this clinician.`);
        foundMatch = true;
        console.log(`\n✅ SUCCESS: PIN "${pinToCompare}" matches clinician ${clinicianId} (${clinicianName})`);
        break;
      } else {
        console.log(`   ❌ PIN mismatch - this is not the correct PIN for this clinician`);
      }
    }
    
    if (!foundMatch) {
      console.log(`\n❌ FAILED: PIN "${pinToCompare}" does not match any clinician`);
      console.log('\n💡 Possible issues:');
      console.log('   1. PIN is incorrect');
      console.log('   2. PIN was not hashed correctly during registration');
      console.log('   3. PIN has extra spaces or characters');
      console.log('   4. Clinician was registered with a different PIN');
      console.log('\n💡 Try:');
      console.log('   - Re-register the clinician with this PIN');
      console.log('   - Check if PIN has leading/trailing spaces');
      console.log('   - Verify the PIN used during registration');
    }
    
    console.log('\n' + '='.repeat(50));
    
  } catch (error) {
    console.error('\n❌ Error testing PIN login:', error);
    console.error('Stack:', error.stack);
  }
}

// Get PIN from command line
const pin = process.argv[2];

if (!pin) {
  console.error('Usage: node test_pin_login.js <PIN>');
  console.error('Example: node test_pin_login.js 1234');
  process.exit(1);
}

// Run test
testPinLogin(pin)
  .then(() => {
    console.log('\n✅ Test completed');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Test failed:', error);
    process.exit(1);
  });


