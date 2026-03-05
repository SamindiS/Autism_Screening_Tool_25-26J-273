# 🔥 How to Get Data from Firebase

## Overview

Your project uses **Firebase Firestore** (not Realtime Database) to store:
- **Children** (child profiles)
- **Sessions** (assessment sessions)
- **Trials** (individual game trials)
- **Clinicians** (clinician accounts)

---

## 📋 Prerequisites

1. **Firebase Service Account Key**: `senseai_backend/serviceAccountKey.json`
   - Download from: Firebase Console → Project Settings → Service Accounts
   - Click "Generate new private key"

2. **Backend Running**: The backend must be running to use API endpoints

---

## 🎯 Method 1: Export via API Endpoint (Easiest)

### Export ML Training Data (CSV)

**URL**: `http://localhost:3000/api/export/csv`

**Query Parameters**:
- `format`: `ml` (for ML training) or `raw` (raw data) - Default: `ml`
- `sessionType`: Filter by type - `color_shape`, `frog_jump`, `ai_doctor_bot`
- `group`: Filter by group - `asd`, `typically_developing`

**Examples**:

```bash
# Export all data for ML training
curl http://localhost:3000/api/export/csv?format=ml -o ml_training_data.csv

# Export only ASD group data
curl http://localhost:3000/api/export/csv?format=ml&group=asd -o asd_data.csv

# Export only Frog Jump sessions
curl http://localhost:3000/api/export/csv?format=ml&sessionType=frog_jump -o frog_jump_data.csv

# Export ASD + Color-Shape game data
curl "http://localhost:3000/api/export/csv?format=ml&group=asd&sessionType=color_shape" -o asd_color_shape.csv
```

**In Browser**:
```
http://localhost:3000/api/export/csv?format=ml
```
The CSV will download automatically.

---

## 🎯 Method 2: Standalone Export Script

### Run Export Script Directly

**Location**: `senseai_backend/scripts/export_firebase_to_csv.js`

**Usage**:
```bash
cd senseai_backend

# Basic export (ML format)
node scripts/export_firebase_to_csv.js

# Export with filters
node scripts/export_firebase_to_csv.js --format=ml --group=asd --output=asd_data.csv

# Export specific session type
node scripts/export_firebase_to_csv.js --format=ml --sessionType=frog_jump --output=frog_jump.csv

# Export raw data (all fields)
node scripts/export_firebase_to_csv.js --format=raw --output=raw_export.csv
```

**Options**:
- `--format=ml|raw`: Export format (default: `ml`)
- `--group=asd|typically_developing`: Filter by group
- `--sessionType=color_shape|frog_jump|ai_doctor_bot`: Filter by session type
- `--output=filename.csv`: Output filename (default: `export_<timestamp>.csv`)

**Output**: CSV file saved in `senseai_backend/` directory

---

## 🎯 Method 3: Direct Firebase Admin SDK (Programmatic)

### Create Your Own Script

Create a new file: `senseai_backend/scripts/get_firebase_data.js`

```javascript
const { db } = require('../firebase');

async function getFirebaseData() {
  try {
    // Get all children
    const childrenSnap = await db.collection('children').get();
    const children = [];
    childrenSnap.forEach(doc => {
      children.push({
        id: doc.id,
        ...doc.data()
      });
    });
    console.log(`✅ Found ${children.length} children`);

    // Get all sessions
    const sessionsSnap = await db.collection('sessions').get();
    const sessions = [];
    sessionsSnap.forEach(doc => {
      sessions.push({
        id: doc.id,
        ...doc.data()
      });
    });
    console.log(`✅ Found ${sessions.length} sessions`);

    // Get sessions with filters
    const filteredSessions = await db.collection('sessions')
      .where('session_type', '==', 'frog_jump')
      .where('created_at', '>', new Date('2024-01-01'))
      .get();
    
    console.log(`✅ Found ${filteredSessions.size} filtered sessions`);

    // Return data
    return {
      children,
      sessions,
      filteredSessions: filteredSessions.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }))
    };

  } catch (error) {
    console.error('❌ Error:', error);
    throw error;
  }
}

// Run the function
getFirebaseData()
  .then(data => {
    console.log('\n📊 Data Retrieved:');
    console.log(`   Children: ${data.children.length}`);
    console.log(`   Sessions: ${data.sessions.length}`);
    console.log(`   Filtered Sessions: ${data.filteredSessions.length}`);
    
    // Save to JSON file
    const fs = require('fs');
    fs.writeFileSync('firebase_export.json', JSON.stringify(data, null, 2));
    console.log('\n✅ Data saved to firebase_export.json');
  })
  .catch(err => {
    console.error('❌ Failed:', err);
    process.exit(1);
  });
```

**Run**:
```bash
cd senseai_backend
node scripts/get_firebase_data.js
```

---

## 📊 Common Firebase Queries

### Get All Children
```javascript
const childrenSnap = await db.collection('children').get();
childrenSnap.forEach(doc => {
  console.log(doc.id, doc.data());
});
```

### Get Children by Group
```javascript
const asdChildren = await db.collection('children')
  .where('group', '==', 'asd')
  .get();
```

### Get Sessions by Type
```javascript
const frogJumpSessions = await db.collection('sessions')
  .where('session_type', '==', 'frog_jump')
  .get();
```

### Get Sessions with Date Range
```javascript
const recentSessions = await db.collection('sessions')
  .where('created_at', '>=', new Date('2024-01-01'))
  .orderBy('created_at', 'desc')
  .limit(100)
  .get();
```

### Get Child with All Sessions
```javascript
const childId = 'child123';
const child = await db.collection('children').doc(childId).get();
const sessions = await db.collection('sessions')
  .where('child_id', '==', childId)
  .get();
```

### Get Single Document
```javascript
const sessionId = 'session123';
const session = await db.collection('sessions').doc(sessionId).get();
if (session.exists) {
  console.log(session.data());
}
```

---

## 🔧 Advanced: Export Specific Collections

### Export Only Children
```javascript
const { db } = require('./firebase');
const fs = require('fs');

async function exportChildren() {
  const childrenSnap = await db.collection('children').get();
  const children = [];
  childrenSnap.forEach(doc => {
    children.push({ id: doc.id, ...doc.data() });
  });
  
  fs.writeFileSync('children_export.json', JSON.stringify(children, null, 2));
  console.log(`✅ Exported ${children.length} children`);
}

exportChildren();
```

### Export Only Sessions
```javascript
const { db } = require('./firebase');
const fs = require('fs');

async function exportSessions() {
  const sessionsSnap = await db.collection('sessions').get();
  const sessions = [];
  sessionsSnap.forEach(doc => {
    sessions.push({ id: doc.id, ...doc.data() });
  });
  
  fs.writeFileSync('sessions_export.json', JSON.stringify(sessions, null, 2));
  console.log(`✅ Exported ${sessions.length} sessions`);
}

exportSessions();
```

---

## 📁 Data Structure in Firebase

### Collections:

1. **`children`** - Child profiles
   ```json
   {
     "id": "child123",
     "child_code": "LRH-001",
     "name": "Child Name",
     "age_in_months": 48,
     "gender": "male",
     "group": "asd",
     "created_at": 1234567890
   }
   ```

2. **`sessions`** - Assessment sessions
   ```json
   {
     "id": "session123",
     "child_id": "child123",
     "session_type": "frog_jump",
     "age_group": "3.5-5.5",
     "game_results": { ... },
     "questionnaire_results": { ... },
     "reflection_results": { ... },
     "created_at": 1234567890
   }
   ```

3. **`trials`** - Individual game trials
   ```json
   {
     "id": "trial123",
     "session_id": "session123",
     "trial_number": 1,
     "response_time": 500,
     "correct": true
   }
   ```

4. **`clinicians`** - Clinician accounts
   ```json
   {
     "id": "clinician123",
     "name": "Dr. Smith",
     "email": "doctor@example.com"
   }
   ```

---

## 🚀 Quick Start Examples

### Example 1: Export All Data for ML Training
```bash
cd senseai_backend
node scripts/export_firebase_to_csv.js --format=ml --output=master_training_dataset.csv
```

### Example 2: Export Only Real Data (No Test Data)
```bash
# First, identify test children (usually have "test" in name or code)
# Then export excluding them via API or script
curl "http://localhost:3000/api/export/csv?format=ml" -o real_data.csv
```

### Example 3: Export by Age Group
```javascript
// Create script: export_by_age.js
const { db } = require('./firebase');
const fs = require('fs');

async function exportByAge() {
  const sessions = await db.collection('sessions').get();
  const ageGroups = {
    '2-3.5': [],
    '3.5-5.5': [],
    '5.5-6.9': []
  };
  
  sessions.forEach(doc => {
    const session = doc.data();
    const ageGroup = session.age_group;
    if (ageGroups[ageGroup]) {
      ageGroups[ageGroup].push({ id: doc.id, ...session });
    }
  });
  
  for (const [age, data] of Object.entries(ageGroups)) {
    fs.writeFileSync(`${age}_sessions.json`, JSON.stringify(data, null, 2));
    console.log(`✅ Exported ${data.length} sessions for age ${age}`);
  }
}

exportByAge();
```

---

## ⚠️ Important Notes

1. **Firebase Quota**: Be aware of read quotas (free tier: 50K reads/day)
2. **Indexes**: Some queries require composite indexes (Firebase will prompt you)
3. **Authentication**: Ensure `serviceAccountKey.json` is valid
4. **Large Datasets**: Use pagination for large exports:
   ```javascript
   let lastDoc = null;
   const batchSize = 100;
   do {
     let query = db.collection('sessions').limit(batchSize);
     if (lastDoc) query = query.startAfter(lastDoc);
     const snapshot = await query.get();
     // Process batch...
     lastDoc = snapshot.docs[snapshot.docs.length - 1];
   } while (lastDoc);
   ```

---

## 🎯 Recommended Workflow

1. **For ML Training**: Use Method 1 (API) or Method 2 (Script)
   ```bash
   node scripts/export_firebase_to_csv.js --format=ml --output=ml_training_data.csv
   ```

2. **For Data Analysis**: Use Method 3 (Custom Script) to get JSON
   ```javascript
   // Get structured data for analysis
   const data = await getFirebaseData();
   ```

3. **For Quick Checks**: Use Firebase Console
   - Go to: https://console.firebase.google.com/
   - Navigate to Firestore Database
   - Browse collections directly

---

## 📝 Summary

**Easiest Method**: API Endpoint
```
http://localhost:3000/api/export/csv?format=ml
```

**Most Flexible**: Standalone Script
```bash
node scripts/export_firebase_to_csv.js --format=ml --group=asd
```

**Most Control**: Custom Script
```javascript
const { db } = require('./firebase');
// Write your own queries
```

---

## 🔗 Related Files

- `senseai_backend/firebase.js` - Firebase initialization
- `senseai_backend/routes/export.js` - API export routes
- `senseai_backend/scripts/export_firebase_to_csv.js` - Export script
- `senseai_backend/serviceAccountKey.json` - Firebase credentials (keep secure!)

---

✅ **You're all set!** Choose the method that works best for your needs.
