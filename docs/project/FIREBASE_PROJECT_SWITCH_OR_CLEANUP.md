# Firebase Project Switch vs Cleanup Guide

## 🔍 Important: Where is Your Data?

### Data Storage Locations:

1. **Firebase Firestore (Cloud)** ☁️
   - All data is stored in Firebase
   - Children, Sessions, Trials, Clinicians
   - This is your **primary database**

2. **Device SQLite (Local)** 📱
   - Temporary offline storage
   - Syncs to Firebase when online
   - **NOT the primary storage**

### ⚠️ Critical Understanding:

**If you create a NEW Firebase project:**
- ❌ Your existing data stays in the OLD Firebase project
- ❌ New project starts EMPTY
- ❌ Device data will sync to NEW (empty) Firebase
- ❌ You'll lose access to old data unless you migrate it

---

## 🎯 Option 1: Keep Current Firebase + Upgrade (RECOMMENDED)

### Why This is Better:
- ✅ Keep all existing data
- ✅ No data migration needed
- ✅ Just upgrade plan (2 minutes)
- ✅ All data immediately accessible

### Steps:
1. Upgrade to Blaze plan (in current Firebase)
2. Restart backend
3. Continue using - all data preserved

**Cost**: $0-5/month (usually free)

---

## 🔄 Option 2: Create New Firebase + Migrate Data

### If You Really Want a New Project:

#### Step 1: Export Data from Old Firebase

**Method A: Using Backend Script**
```bash
cd senseai_backend
node scripts/export_firebase_to_csv.js
```
This creates CSV files with all your data.

**Method B: Manual Export from Firebase Console**
1. Go to Firebase Console → Firestore Database
2. For each collection (children, sessions, trials, clinicians):
   - Click collection
   - Export data manually
   - Or use Firebase CLI

**Method C: Use Backup Script**
```bash
cd senseai_backend
node -e "
const { createBackup } = require('./services/dataRecovery');
createBackup('migration-backup').then(console.log);
"
```

#### Step 2: Create New Firebase Project

1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Name: `SenseAI-Cognitive-v2` (or any name)
4. Follow setup wizard
5. Enable Firestore Database
6. Download new `serviceAccountKey.json`

#### Step 3: Import Data to New Firebase

**Option A: Manual Import (Small Data)**
- Use Firebase Console
- Import JSON files manually

**Option B: Script Import (Large Data)**
- Write import script using new service account
- Import from CSV/JSON backups

#### Step 4: Update Backend

1. **Backup old key**:
   ```bash
   cp senseai_backend/serviceAccountKey.json senseai_backend/serviceAccountKey.json.old
   ```

2. **Replace with new key**:
   - Copy new `serviceAccountKey.json` to `senseai_backend/`
   - Replace the old file

3. **Restart backend**:
   ```bash
   cd senseai_backend
   npm start
   ```

#### Step 5: Device Data Sync

**Important**: Device SQLite has local data that will sync to NEW Firebase

- When device goes online, it will sync local data to new Firebase
- This is good - your local data will be preserved
- But you'll need to manually import old Firebase data first

---

## 🗑️ Option 3: Clean Up Old Firebase (Keep Same Project)

### Delete Unwanted Data

#### Method 1: Firebase Console (Manual)

1. **Go to Firestore Database**
2. **Select Collection** (children, sessions, trials, etc.)
3. **Delete Documents**:
   - Click on document
   - Click delete icon
   - Confirm deletion

**For Bulk Delete**:
- Select multiple documents
- Click "Delete" button
- Confirm

#### Method 2: Using Backend Script

Create a cleanup script:

```javascript
// senseai_backend/scripts/cleanup_firebase.js
const { db } = require('../firebase');

async function cleanupTestData() {
  console.log('🧹 Starting cleanup...');
  
  // Delete test children (example: children with name "Test")
  const childrenSnap = await db.collection('children')
    .where('name', '==', 'Test')
    .get();
  
  const batch = db.batch();
  childrenSnap.docs.forEach(doc => {
    batch.delete(doc.ref);
  });
  
  await batch.commit();
  console.log(`✅ Deleted ${childrenSnap.size} test children`);
}

cleanupTestData();
```

#### Method 3: Delete by Date

```javascript
// Delete data older than 30 days
const cutoffDate = Date.now() - (30 * 24 * 60 * 60 * 1000);

const sessionsSnap = await db.collection('sessions')
  .where('created_at', '<', cutoffDate)
  .get();

// Delete in batches
```

#### Method 4: Delete Orphaned Records

Use integrity check to find orphaned data:

```bash
# Run integrity check
curl http://localhost:3000/api/integrity/check

# Then manually delete orphaned records from Firebase Console
```

---

## 📊 Data Migration Strategy

### If You Must Switch Projects:

#### Complete Migration Process:

1. **Export All Data**:
   ```bash
   # Export to CSV
   cd senseai_backend
   node scripts/export_firebase_to_csv.js
   
   # Or create full backup
   node -e "const { createBackup } = require('./services/dataRecovery'); createBackup('full-backup').then(console.log);"
   ```

2. **Create New Firebase Project**:
   - New project name
   - Enable Firestore
   - Download new service account key

3. **Import Data to New Project**:
   - Use Firebase Console (small data)
   - Or write import script (large data)

4. **Update Backend**:
   - Replace `serviceAccountKey.json`
   - Restart backend

5. **Device Will Sync**:
   - Device SQLite data will sync to new Firebase
   - This is automatic when device goes online

---

## ⚠️ Important Considerations

### Device Data Behavior:

**When you switch Firebase projects:**

1. **Device has local SQLite data**:
   - This data will sync to NEW Firebase
   - Good: Local data is preserved
   - Bad: Old Firebase data won't automatically transfer

2. **To preserve old Firebase data**:
   - Must export from old Firebase first
   - Import to new Firebase
   - Then device sync will work with all data

3. **If you don't migrate**:
   - Device local data → New Firebase ✅
   - Old Firebase data → Lost ❌ (unless you export first)

---

## 🎯 Recommended Approach

### Best Solution: Upgrade Current Firebase

**Why**:
- ✅ Keep all existing data
- ✅ No migration needed
- ✅ Device data already synced
- ✅ 2 minutes to fix
- ✅ Usually costs $0/month

**Steps**:
1. Firebase Console → Upgrade to Blaze
2. Add billing
3. Restart backend
4. Done!

---

## 🧹 Cleanup Current Firebase (If You Stay)

### Quick Cleanup Steps:

1. **Delete Test Data**:
   ```bash
   # In Firebase Console
   # Go to each collection
   # Delete test/duplicate records
   ```

2. **Delete Old Backups**:
   ```bash
   # Local backups (not in Firebase)
   cd senseai_backend/backups
   # Delete old backup files
   ```

3. **Delete Orphaned Records**:
   - Run integrity check
   - Delete orphaned sessions/trials
   - Clean up invalid references

4. **Check Storage**:
   - Firebase Console → Usage tab
   - See what's using space
   - Delete large/unnecessary documents

---

## 📋 Step-by-Step: Clean Up Old Firebase

### Method 1: Firebase Console (Easiest)

1. **Go to Firebase Console**
2. **Firestore Database → Data tab**
3. **For each collection**:
   - Click collection name
   - Review documents
   - Select unwanted documents
   - Click "Delete"
   - Confirm

### Method 2: Delete by Query

1. **Use Query Builder** in Firebase Console
2. **Filter by**:
   - Date (old data)
   - Name (test data)
   - Status (incomplete data)
3. **Delete filtered results**

### Method 3: Script-Based Cleanup

Create cleanup script:

```javascript
// senseai_backend/scripts/cleanup_old_data.js
const { db } = require('../firebase');

async function cleanup() {
  // Delete sessions older than 90 days
  const cutoff = Date.now() - (90 * 24 * 60 * 60 * 1000);
  
  const oldSessions = await db.collection('sessions')
    .where('created_at', '<', cutoff)
    .get();
  
  const batch = db.batch();
  oldSessions.docs.forEach(doc => batch.delete(doc.ref));
  await batch.commit();
  
  console.log(`Deleted ${oldSessions.size} old sessions`);
}

cleanup();
```

---

## 🔄 Complete Migration Process (If Needed)

### Full Data Migration:

1. **Export from Old Firebase**:
   ```bash
   # Create full backup
   cd senseai_backend
   node -e "
   const { createBackup } = require('./services/dataRecovery');
   createBackup('migration-backup-before-switch').then(r => {
     console.log('Backup created:', r.backupPath);
   });
   "
   ```

2. **Create New Firebase Project**:
   - New project in Firebase Console
   - Enable Firestore
   - Download new service account key

3. **Import Script** (create this):
   ```javascript
   // senseai_backend/scripts/import_to_new_firebase.js
   const admin = require('firebase-admin');
   const fs = require('fs');
   
   // Initialize with NEW service account
   const newServiceAccount = require('../serviceAccountKey.json');
   admin.initializeApp({
     credential: admin.credential.cert(newServiceAccount)
   });
   
   const db = admin.firestore();
   
   // Load backup
   const backup = JSON.parse(fs.readFileSync('./backups/migration-backup-before-switch.json'));
   
   // Import data
   async function importData() {
     const batch = db.batch();
     
     // Import children
     backup.data.children.forEach(child => {
       const ref = db.collection('children').doc(child.id);
       const { id, ...data } = child;
       batch.set(ref, data);
     });
     
     // Import sessions, trials, clinicians similarly
     
     await batch.commit();
     console.log('Import complete!');
   }
   
   importData();
   ```

4. **Update Backend**:
   - Replace `serviceAccountKey.json` with new one
   - Restart backend

5. **Device Sync**:
   - Device will sync local data to new Firebase
   - All data now in new project

---

## 💡 My Recommendation

### Don't Create New Project - Just Upgrade!

**Reasons**:
1. ✅ All your data is already there
2. ✅ Device is already synced
3. ✅ No migration needed
4. ✅ Upgrade takes 2 minutes
5. ✅ Usually costs $0/month
6. ✅ No risk of data loss

**Only create new project if**:
- You want to start completely fresh
- You don't need old data
- You're okay losing existing data

---

## 🚀 Quick Decision Guide

### Choose Based on Your Needs:

**Need to keep all data?** → **Upgrade current Firebase** ⭐

**Want fresh start?** → **Create new Firebase** (but export old data first!)

**Just need to free space?** → **Clean up current Firebase**

**Have billing issues?** → **Clean up + wait for quota reset**

---

## 📝 Summary

### Option 1: Upgrade (Easiest) ⭐
- Keep all data
- 2 minutes
- Usually free
- **Recommended**

### Option 2: New Project + Migrate
- Export old data first
- Create new project
- Import data
- Update backend
- Device syncs automatically
- **More work, but clean start**

### Option 3: Cleanup Current
- Delete unwanted data
- Wait for quota reset
- Continue using
- **Temporary solution**

---

**My strong recommendation: Just upgrade to Blaze plan. It's the fastest, safest, and usually free solution!** 🎯

