# Fix Backend Connection Issue

## ✅ Your Project is Correct!

This **IS** a proper Flutter project created the same way as:
- View → Command Palette → Flutter: New Project → Application

The issue is **NOT** the project structure - it's the **backend connection**.

## 🔧 Quick Fix Steps

### Step 1: Open the Backend Configuration Dialog

**Option A: Automatic (Recommended)**
1. Try to **log in or register** with any PIN
2. The dialog will appear automatically when connection fails

**Option B: Manual**
1. Look for the **⚙️ Settings icon** in the top-right corner of the login screen
2. Tap it to open the backend configuration dialog

### Step 2: Update the Backend URL

In the dialog:
1. **Find the text field** showing: `http://10.0.2.2:3000`
2. **Tap the text field** to select it
3. **Delete the text** and type: `http://192.168.194.180:3000`
   - This is your computer's IP address (we found it earlier)
4. **Tap "Test Connection"** to verify it works
   - If successful: You'll see "✓ Connection successful!"
   - If failed: Check the error message
5. **Tap "Save & Retry"** to save the URL

### Step 3: Try Again

After saving:
1. Try to **log in or register** again
2. It should work now!

## 🖥️ Your Computer's IP Address

Your computer's IP address is: **`192.168.194.180`**

So your backend URL should be: **`http://192.168.194.180:3000`**

## ⚠️ Important Requirements

1. **Backend server must be running** on port 3000
   - ✅ We confirmed it's running: `TCP 0.0.0.0:3000 LISTENING`

2. **Tablet and computer on same Wi-Fi network**
   - Both devices must be connected to the same Wi-Fi

3. **Windows Firewall** may need to allow port 3000
   - Run `.\allow_port_3000.ps1` as Administrator if needed

## 🆕 Creating a New Flutter Project (For Reference)

If you want to create a new Flutter project:

1. **In VS Code:**
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type: `Flutter: New Project`
   - Select: `Application`
   - Choose a name and location

2. **Or via Terminal:**
   ```bash
   flutter create my_new_app
   cd my_new_app
   flutter run
   ```

**But remember:** Creating a new project won't fix the backend connection issue. You still need to configure the backend URL!

## 🐛 Still Not Working?

If the connection still fails:

1. **Check backend server is running:**
   ```powershell
   netstat -an | findstr :3000
   ```
   Should show: `TCP 0.0.0.0:3000 LISTENING`

2. **Check Windows Firewall:**
   - Run the `allow_port_3000.ps1` script as Administrator

3. **Verify same Wi-Fi network:**
   - Tablet and computer must be on the same network

4. **Try the IP address again:**
   - Your IP might have changed
   - Run: `ipconfig | findstr IPv4` to get current IP

## 📱 Testing on Tablet

After configuring:
1. The app should connect to your backend
2. You can register a new clinician
3. You can log in with your PIN

---

**The key is:** Change `http://10.0.2.2:3000` to `http://192.168.194.180:3000` in the dialog!


