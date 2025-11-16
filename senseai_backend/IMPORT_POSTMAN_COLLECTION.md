# How to Import Postman Collection

## Step-by-Step Guide

### Method 1: Import from File (Recommended)

1. **Open Postman**
   - Launch the Postman application (desktop or web)

2. **Click Import Button**
   - Click the **"Import"** button in the top left corner
   - Or use the keyboard shortcut: `Ctrl + O` (Windows/Linux) or `Cmd + O` (Mac)

3. **Select the Collection File**
   - Click **"Upload Files"** or **"Choose Files"**
   - Navigate to: `senseai_backend/SenseAI_Backend.postman_collection.json`
   - Select the file and click **"Open"**

4. **Confirm Import**
   - Postman will show a preview of what will be imported
   - Click **"Import"** to confirm

5. **Collection Appears**
   - You'll see "SenseAI Backend API" collection in the left sidebar
   - All endpoints are organized in folders:
     - Health Check
     - Clinicians
     - Children
     - Sessions
     - Trials

---

### Method 2: Import from URL

1. **Open Postman**
2. **Click Import**
3. **Select "Link" tab**
4. **Paste Collection URL** (if hosted online)
5. **Click "Continue"** and then **"Import"**

---

### Method 3: Copy-Paste JSON

1. **Open Postman**
2. **Click Import**
3. **Select "Raw text" tab**
4. **Copy the entire JSON** from `SenseAI_Backend.postman_collection.json`
5. **Paste it** into the text area
6. **Click "Continue"** and then **"Import"**

---

## After Importing

### 1. Set the Base URL Variable

The collection uses a variable `{{base_url}}` which defaults to `http://localhost:3000`.

**To change it:**

1. Right-click on the collection name: **"SenseAI Backend API"**
2. Select **"Edit"**
3. Go to the **"Variables"** tab
4. Update the `base_url` value if needed (e.g., `http://192.168.1.100:3000` for network access)
5. Click **"Update"**

### 2. Start Your Backend Server

Make sure your backend is running:

```bash
cd senseai_backend
npm start
```

### 3. Test the Collection

1. **Start with Health Check**
   - Click on **"Health Check"** in the collection
   - Click **"Send"**
   - You should get: `{"status": "OK", ...}`

2. **Test Other Endpoints**
   - Expand folders to see all endpoints
   - Click on any endpoint
   - Modify the request body if needed
   - Click **"Send"**

---

## Collection Structure

```
SenseAI Backend API
├── Health Check
├── Clinicians
│   ├── Register Clinician
│   ├── Login
│   └── Get Current Clinician
├── Children
│   ├── Create Child
│   ├── Get All Children
│   ├── Get Child by ID
│   ├── Update Child
│   └── Delete Child
├── Sessions
│   ├── Create Session
│   ├── Get All Sessions
│   ├── Get Session by ID
│   ├── Get Sessions by Child
│   ├── Update Session
│   └── Delete Session
└── Trials
    ├── Create Trial
    ├── Create Trials (Batch)
    ├── Get Trials by Session
    ├── Get Trial by ID
    └── Delete Trial
```

---

## Tips

### Save IDs for Testing

1. **After creating a child**, copy the `id` from the response
2. **Update the variable** in "Get Child by ID" request:
   - Click on the request
   - Go to **"Params"** tab
   - Update the `:id` variable value

### Use Environment Variables

Create a Postman Environment for different setups:

1. Click **"Environments"** in left sidebar
2. Click **"+"** to create new environment
3. Add variables:
   - `base_url`: `http://localhost:3000`
   - `child_id`: (paste after creating a child)
   - `session_id`: (paste after creating a session)
4. Select the environment from dropdown (top right)

### Run Collection

1. Right-click on collection name
2. Select **"Run collection"**
3. Configure test order and iterations
4. Click **"Run SenseAI Backend API"**

---

## Troubleshooting

### Collection Not Importing
- Make sure the JSON file is valid
- Check Postman version (should be recent)
- Try importing via "Raw text" method

### Requests Not Working
- Verify backend server is running
- Check `base_url` variable is set correctly
- Verify the port (default: 3000)

### Variables Not Working
- Make sure you're using `{{base_url}}` syntax
- Check variable is set in collection or environment
- Environment must be selected (top right dropdown)

---

## Quick Start Workflow

1. **Import collection** (this guide)
2. **Start backend**: `npm start` in `senseai_backend`
3. **Test Health Check** - Should return OK
4. **Register Clinician** - Create your account
5. **Login** - Authenticate
6. **Create Child** - Add a test child
7. **Create Session** - Start an assessment
8. **Create Trials** - Add trial data (use batch endpoint)

---

## File Location

The collection file is located at:
```
senseai_backend/SenseAI_Backend.postman_collection.json
```

You can share this file with your team or version control it.

