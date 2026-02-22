# Install Android SDK Command-line Tools

## 🎯 Quick Fix: Install via Android Studio (Easiest)

### Step 1: Open Android Studio
1. Launch Android Studio

### Step 2: Open SDK Manager
1. Click **Tools** → **SDK Manager**
   - Or: **File** → **Settings** → **Appearance & Behavior** → **System Settings** → **Android SDK**

### Step 3: Install Command-line Tools
1. Click the **SDK Tools** tab
2. Check the box: **"Android SDK Command-line Tools (latest)"**
3. Click **Apply**
4. Click **OK** in the confirmation dialog
5. Wait for installation to complete

### Step 4: Verify
```bash
flutter doctor --android-licenses
```

Should work now!

---

## 🔧 Alternative: Manual Installation

If you don't have Android Studio:

### Step 1: Download Command-line Tools
1. Go to: https://developer.android.com/studio#command-line-tools-only
2. Download: **"Command line tools only"** for Windows
3. File will be named: `commandlinetools-win-XXXXXX_latest.zip`

### Step 2: Extract to Correct Location
1. Create folder: `C:\Users\DELL\AppData\Local\Android\Sdk\cmdline-tools\latest`
2. Extract the ZIP file contents to this folder
3. Structure should be:
   ```
   C:\Users\DELL\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\
   C:\Users\DELL\AppData\Local\Android\Sdk\cmdline-tools\latest\lib\
   ```

### Step 3: Add to PATH (Optional but Recommended)
1. Win + R → `sysdm.cpl` → Enter
2. Advanced → Environment Variables
3. System variables → Path → Edit
4. Add: `C:\Users\DELL\AppData\Local\Android\Sdk\cmdline-tools\latest\bin`
5. OK all windows
6. Restart terminal

### Step 4: Verify
```bash
flutter doctor --android-licenses
```

---

## ✅ After Installation

Once cmdline-tools are installed:

1. **Accept licenses**:
   ```bash
   flutter doctor --android-licenses
   ```
   Type `y` for each license

2. **Verify setup**:
   ```bash
   flutter doctor -v
   ```

3. **Build your app**:
   ```bash
   flutter run
   ```

---

## 🎯 Recommended: Use Android Studio Method

**Easiest and most reliable way:**
1. Open Android Studio
2. Tools → SDK Manager
3. SDK Tools tab
4. Check "Android SDK Command-line Tools (latest)"
5. Apply

That's it!




