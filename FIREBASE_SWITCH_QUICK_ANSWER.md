# Quick Answer: New Firebase Project & Data

## ❓ Your Questions

### Q1: If I create new Firebase project, can I get saved data from device?

**Answer**: **YES, but only device data - not old Firebase data**

**What happens**:
- ✅ **Device SQLite data** → Will automatically sync to NEW Firebase
- ❌ **Old Firebase data** → Stays in old Firebase (won't transfer automatically)

**To get ALL data**:
1. Export from old Firebase first
2. Create new Firebase project
3. Import exported data to new Firebase
4. Device will sync its local data too
5. Result: All data in new Firebase ✅

---

### Q2: How to delete unwanted data in previous Firebase?

**Answer**: Multiple methods available

**Method 1: Firebase Console (Easiest)**
1. Go to Firebase Console
2. Firestore Database → Data tab
3. Select unwanted documents
4. Click "Delete"
5. Confirm

**Method 2: Use Cleanup Script**
```bash
cd senseai_backend
node scripts/cleanup_firebase_data.js --delete-test-children --dry-run
```

**Method 3: Delete by Query**
- Use Query Builder in Firebase Console
- Filter by date, name, status
- Delete filtered results

---

## 🎯 My Recommendation

### ⭐ BEST: Upgrade Current Firebase (2 minutes)

**Why**:
- ✅ Keep ALL existing data
- ✅ Device data already synced
- ✅ No migration needed
- ✅ Usually costs $0/month

**Steps**:
1. Firebase Console → Click "Upgrade"
2. Select "Blaze Plan"
3. Add billing
4. Restart backend
5. Done!

---

## 🔄 If You Must Create New Project

### Complete Process:

1. **Export from Old Firebase**:
   ```bash
   cd senseai_backend
   node scripts/migrate_to_new_firebase.js --export
   ```

2. **Create New Firebase Project**:
   - Firebase Console → Add project
   - Enable Firestore
   - Download new serviceAccountKey.json

3. **Update Backend**:
   ```bash
   # Backup old key
   cp senseai_backend/serviceAccountKey.json senseai_backend/serviceAccountKey.json.old
   
   # Replace with new key
   # (Copy new serviceAccountKey.json to senseai_backend/)
   ```

4. **Import to New Firebase**:
   ```bash
   node scripts/migrate_to_new_firebase.js --import --backup=migration-export-XXXX.json
   ```

5. **Device Auto-Syncs**:
   - Device local data will sync to new Firebase automatically
   - All data now in new Firebase ✅

---

## 🗑️ Delete Unwanted Data

### Quick Cleanup:

```bash
# Preview what will be deleted
cd senseai_backend
node scripts/cleanup_firebase_data.js --delete-test-children --dry-run

# Actually delete test children
node scripts/cleanup_firebase_data.js --delete-test-children

# Delete old sessions (90+ days)
node scripts/cleanup_firebase_data.js --delete-old-sessions

# Delete orphaned records
node scripts/cleanup_firebase_data.js --delete-orphaned
```

---

## 📊 Summary

| Question | Answer |
|----------|--------|
| **Device data with new Firebase?** | ✅ Yes, device data syncs automatically |
| **Old Firebase data with new project?** | ❌ No, must export/import manually |
| **How to delete unwanted data?** | ✅ Use Firebase Console or cleanup script |
| **Best solution?** | ⭐ Upgrade current Firebase (2 min, usually free) |

---

**Recommendation: Just upgrade to Blaze plan - it's the fastest and safest solution!** 🚀


