# Backend + Firebase Test Guide (Step 7)

## Prerequisites
- Backend dependencies installed: `pip install -r requirements.txt`
- `firebase-service-account.json` in `backend/` (or `FIREBASE_CREDENTIALS_PATH` set)
- Firestore enabled in Firebase Console (test or production mode)

---

## 1. Start the backend

Open a terminal in the **project root** (or in `backend/`):

```bash
cd backend
python app.py
```

You should see something like:
- `* Running on http://127.0.0.1:5000` (or similar)

Leave this terminal open.

---

## 2. Trigger a video analysis

### Option A: From the Flutter app (recommended)

1. Run the Flutter app (emulator or device on same WiFi as the machine running the backend).
2. In the app, go to **Auditory Response Analysis** (video analysis page).
3. **Upload** a video or **Record** one, then tap **Analyze Video**.
4. Wait until the analysis finishes (results and charts appear).

The app sends a POST to `http://<your-base-url>:5000/api/analyze-video` with the video file and form fields. The backend will then call `save_analysis_result()` and write to Firestore.

**Note:** In `packages/shared_config/lib/backend_config.dart`, `baseUrl` is set to `http://172.20.10.3:5000`. Use:
- **Physical device:** Your computer’s IP (e.g. `172.20.10.3`) on the same WiFi.
- **Emulator:** Change to `http://10.0.2.2:5000` for Android emulator.

### Option B: With curl (no app)

From a **second terminal**, run (replace `PATH_TO_VIDEO.mp4` with a real video file):

```bash
curl -X POST http://127.0.0.1:5000/api/analyze-video ^
  -F "video=@PATH_TO_VIDEO.mp4" ^
  -F "child_name=TestChild" ^
  -F "child_age=4"
```

**Windows PowerShell** (use backticks for line continuation):

```powershell
curl.exe -X POST http://127.0.0.1:5000/api/analyze-video `
  -F "video=@C:\path\to\your\video.mp4" `
  -F "child_name=TestChild" `
  -F "child_age=4"
```

If the backend is on another machine, replace `127.0.0.1` with that machine’s IP.

You should get a long JSON response with `RTN_Status`, `Reaction_Time`, `Confidence_Score`, etc. Any Firebase error will only be printed in the backend terminal (the API still returns 200).

---

## 3. Check Firestore

1. Open [Firebase Console](https://console.firebase.google.com/) and select your project.
2. Go to **Build** → **Firestore Database** → **Data**.
3. You should see a collection named **`video_analysis_results`**.
4. Open it: there should be one document per analysis, with fields like:
   - `childName`, `childAge`, `reactionTime`, `confidenceLevel`, `rtnStatus`, `detectedBehaviors`, `mlPrediction`, `autismProbability`, `typicalProbability`, `mlConfidence`, `createdAt`, etc.

---

## 4. If no document appears

- **Backend terminal:** Look for `Firebase save failed: ...`. That usually means:
  - Wrong path to `firebase-service-account.json` → set `FIREBASE_CREDENTIALS_PATH` or put the file in `backend/`.
  - Firestore not enabled or wrong project → enable Firestore and use the same project as the service account key.
- **Firestore rules:** If you use “production” mode, ensure your rules allow writes (e.g. allow for testing, or use authenticated users later).
- Run one analysis and check the backend terminal for errors right after the request.

---

## Quick checklist

- [ ] Backend running (`python app.py` in `backend/`)
- [ ] One analysis triggered (app or curl)
- [ ] Firestore → Data → `video_analysis_results` → new document with `createdAt` and analysis fields
