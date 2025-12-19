# Export Your Firebase Data to CSV - Quick Steps

## 🚀 Easiest Method: Using Browser

### Step 1: Start Your Backend

Open PowerShell/Command Prompt and run:

```powershell
cd senseai_backend
npm start
```

Wait until you see:
```
SenseAI Backend + Firebase running
→ Listening on http://0.0.0.0:3000
```

### Step 2: Open in Browser

Open your web browser and go to one of these URLs:

**Export ALL your data:**
```
http://localhost:3000/api/export/csv?format=ml
```

**Export only ASD group:**
```
http://localhost:3000/api/export/csv?format=ml&group=asd
```

**Export only Control group:**
```
http://localhost:3000/api/export/csv?format=ml&group=typically_developing
```

**Export specific session type (e.g., color_shape):**
```
http://localhost:3000/api/export/csv?format=ml&sessionType=color_shape
```

The CSV file will **download automatically**! 📥

---

## 📊 What You Get

The CSV includes:
- Child information (age, gender, group)
- Session details (type, age group)
- ML features (accuracy, scores, risk levels)
- Behavioral markers (attention, engagement, etc.)
- All ready for ML training!

---

## ✅ That's It!

Your CSV file is ready to use for:
- ML model training
- Data analysis
- Creating datasets

---

## 🔍 Verify Your Data

After downloading, open the CSV file in Excel or any spreadsheet software to check your data.

---

## 📝 Alternative: Command Line

If you prefer command line:

```powershell
# Export all data
Invoke-WebRequest -Uri "http://localhost:3000/api/export/csv?format=ml" -OutFile "my_data.csv"
```

---

*Quick reference for exporting your Firebase data*


