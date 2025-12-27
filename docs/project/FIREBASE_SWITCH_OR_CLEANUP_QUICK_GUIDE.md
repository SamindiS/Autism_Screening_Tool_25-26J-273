# Quick Guide: New Firebase Project vs Cleanup

## 🔍 Important: Where is Your Data?

### Your Data is in TWO Places:

1. **Firebase Firestore (Cloud)** ☁️
   - **Primary storage** - All your data is here
   - Children, Sessions, Trials, Clinicians
   - This is what you see in Firebase Console

2. **Device SQLite (Local)** 📱
   - **Temporary offline storage**
   - Syncs TO Firebase when online
   - **NOT the primary database**

---

## ❓ Your Questions Answered

### Q1: If I create new Firebase project, can I get saved data from device?

**Answer**: **YES, but only device data - not old Firebase data**

**What happens**:
- ✅ Device SQLite data → Will sync to NEW Firebase automatically
- ❌ Old Firebase data → Stays in old Firebase (won't transfer automatically)

**To get ALL data**:
1. Export from old Firebase first
2. Create new Firebase
3. Import exported data to new Firebase
4. Device will sync its local data too
5. Result: All data in new Firebase

---

### Q2: How to delete unwanted data in previous Firebase?

**Answer**: Multiple methods below ⬇️

---

## 🎯 Option 1: Keep Current Firebase + Upgrade (BEST) ⭐

### Why This is Best:
- ✅ Keep ALL existing data
- ✅ Device data already synced
- ✅ No migration needed
- ✅ 2 minutes to fix
- ✅ Usually costs $0/month

### Steps:
1. Firebase Console → Click "Upgrade" button
2. Select "Blaze Plan"
3. Add billing (credit card)
4. Restart backend
5. Done! Data saves immediately

**Cost**: Usually $0-5/month (often free)

---

## 🔄 Option 2: Create New Firebase + Migrate Data

### Step-by-Step Process:

#### Step 1: Export Data from OLD Firebase

**Method A: Using Backup Script** (Easiest)
```bash
cd senseai_backend
node -e "
const { createBackup } = require('./services/dataRecovery');
createBackup('migration-backup').then(r => {
  console.log('✅ Backup saved to:', r.backupPath);
  console.log('📦 This file contains ALL your data');
});
"
```

**Method B: Export to CSV**
```bash
cd senseai_backend
node scripts/export_firebase_to_csv.js
```

**Method C: Manual Export from Firebase Console**
1. Go to Firebase Console
2. Firestore Database → Data tab
3. For each collection, export manually

#### Step 2: Create NEW Firebase Project

1. Go to https://console.firebase.google.com/
2. Click "Add project" (or "+" button)
3. Name: `SenseAI-Cognitive-New` (or any name)
4. Follow setup wizard
5. **Enable Firestore Database**
6. **Download new `serviceAccountKey.json`**

#### Step 3: Import Data to NEW Firebase

**Option A: Manual Import (Small Data)**
- Use Firebase Console
- Import JSON files manually
- Create documents one by one

**Option B: Script Import (Large Data)** - I'll create this for you

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

#### Step 5: Device Will Auto-Sync

**What happens automatically**:
- Device has local SQLite data
- When device goes online → Syncs to NEW Firebase
- Your device data will appear in new Firebase
- Old Firebase data needs manual import (from Step 3)

---

## 🗑️ Option 3: Delete Unwanted Data (Keep Same Firebase)

### Method 1: Firebase Console (Easiest)

1. **Go to Firebase Console**
2. **Firestore Database → Data tab**
3. **For each collection**:
   - Click collection name (children, sessions, etc.)
   - Select unwanted documents
   - Click "Delete" button
   - Confirm deletion

**For Bulk Delete**:
- Select multiple documents (checkboxes)
- Click "Delete" button
- Confirm

### Method 2: Delete by Query

1. **Use Query Builder** in Firebase Console
2. **Filter unwanted data**:
   - By date (old data)
   - By name (test data)
   - By status (incomplete)
3. **Delete filtered results**

### Method 3: Script-Based Cleanup

I'll create a cleanup script for you:

```javascript
// senseai_backend/scripts/cleanup_firebase.js
const { db } = require('../firebase');

async function cleanup() {
  // Example: Delete test children
  const testChildren = await db.collection('children')
    .where('name', '==', 'Test')
    .get();
  
  const batch = db.batch();
  testChildren.docs.forEach(doc => batch.delete(doc.ref));
  await batch.commit();
  
  console.log(`✅ Deleted ${testChildren.size} test children`);
}

cleanup();
```

### Method 4: Delete Old Data

```javascript
// Delete sessions older than 90 days
const cutoff = Date.now() - (90 * 24 * 60 * 60 * 1000);

const oldSessions = await db.collection('sessions')
  .where('created_at', '<', cutoff)
  .get();

// Delete in batches
```

---

## 📊 Data Flow Explanation

### Current Setup:
```
Device SQLite → Backend API → Firebase Firestore
     ↓              ↓                ↓
  Local copy    Sync service    Primary storage
```

### If You Switch Firebase Projects:

**Before Switch**:
- Device SQLite: Has local data
- Old Firebase: Has all synced data

**After Switch**:
- Device SQLite: Still has local data ✅
- New Firebase: Starts empty ❌
- Old Firebase: Still has old data (separate)

**What Happens**:
1. Device local data → Syncs to NEW Firebase ✅
2. Old Firebase data → Stays in old Firebase ❌
3. **To get old data**: Must export/import manually

---

## 🎯 My Recommendation

### ⭐ BEST: Upgrade Current Firebase

**Why**:
- ✅ All data preserved
- ✅ Device already synced
- ✅ No migration needed
- ✅ 2 minutes to fix
- ✅ Usually free

**Steps**:
1. Firebase Console → Upgrade to Blaze
2. Add billing
3. Restart backend
4. Done!

---

### Alternative: Clean Up Current Firebase

**If you want to stay on free plan**:

1. **Delete test data** from Firebase Console
2. **Delete old backups** (local files, not in Firebase)
3. **Wait for daily quota reset** (read/write quotas)
4. **Monitor storage** (if > 1 GB, delete more data)

**Steps**:
1. Firebase Console → Firestore Database
2. Delete unwanted documents
3. Check Usage tab to see quota status
4. Wait for next day (for read/write quotas)

---

## 🔧 Quick Commands

### Export All Data (Before Switching):
```bash
cd senseai_backend
node -e "
const { createBackup } = require('./services/dataRecovery');
createBackup('full-backup-before-switch').then(console.log);
"
```

### Check Current Usage:
- Firebase Console → Firestore → Usage tab
- See: Storage, Reads, Writes, Deletes

### Delete Local Backups (Free Space):
```bash
cd senseai_backend/backups
# Delete old backup files manually
```

---

## 📋 Decision Matrix

| Scenario | Solution | Time | Cost |
|----------|----------|------|------|
| Need all data | Upgrade Firebase | 2 min | $0-5/mo |
| Want fresh start | New Firebase + Migrate | 30 min | $0-5/mo |
| Just need space | Cleanup old data | 10 min | $0 |
| Have billing issues | Cleanup + Wait | 1 day | $0 |

---

## ✅ Quick Answer to Your Questions

### Q1: New Firebase + Device Data?
**Answer**: 
- ✅ Device data WILL sync to new Firebase automatically
- ❌ Old Firebase data WON'T transfer automatically
- ✅ To get ALL data: Export old Firebase → Import to new → Device syncs

### Q2: Delete Unwanted Data?
**Answer**: 
- ✅ Firebase Console → Select documents → Delete
- ✅ Use Query Builder to filter and delete
- ✅ I can create cleanup script for you

---

## 🚀 What I Recommend

**Just upgrade to Blaze plan!**

- Fastest solution (2 minutes)
- Keeps all your data
- Usually costs $0/month
- No migration needed
- No risk of data loss

**Only create new project if**:
- You want completely fresh start
- You don't need old data
- You're okay with manual migration

---

**Want me to create a cleanup script or migration script? Just ask!** 🛠️

