# Quick Start Guide - Running the Web Application

## Prerequisites

Before running the web application, make sure you have:

1. **Node.js** (version 18 or higher)
   - Check if installed: `node --version`
   - Download from: https://nodejs.org/

2. **Backend Server Running**
   - The backend must be running on port 3000
   - Navigate to `senseai_backend` folder and run: `npm start` or `node server.js`

## Step-by-Step Instructions

### Step 1: Navigate to Web Application Folder

```bash
cd web_application
```

### Step 2: Install Dependencies (First Time Only)

If you haven't installed dependencies yet:

```bash
npm install
```

This will install all required packages (React, Material-UI, etc.)

### Step 3: Start the Development Server

```bash
npm run dev
```

You should see output like:
```
  VITE v5.0.11  ready in 500 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
```

### Step 4: Open in Browser

Open your web browser and navigate to:
```
http://localhost:5173
```

### Step 5: Login

- **Admin Login**: Use PIN `admin123`
- **Clinician Login**: Use the 4-digit PIN you registered with in the mobile app

## Troubleshooting

### Port Already in Use

If port 5173 is already in use, Vite will automatically use the next available port (5174, 5175, etc.). Check the terminal output for the actual port.

### Backend Connection Issues

If you see errors about API connection:

1. **Check Backend is Running**:
   ```bash
   # In a separate terminal, navigate to senseai_backend
   cd senseai_backend
   npm start
   ```

2. **Check Backend URL**:
   - Default: `http://localhost:3000`
   - If your backend runs on a different port, you may need to update the API URL in `src/services/api.ts`

### Dependencies Not Installing

If `npm install` fails:

1. Clear npm cache:
   ```bash
   npm cache clean --force
   ```

2. Delete `node_modules` and `package-lock.json`:
   ```bash
   rm -rf node_modules package-lock.json
   ```

3. Reinstall:
   ```bash
   npm install
   ```

### Build Errors

If you encounter TypeScript or build errors:

1. Check Node.js version (should be 18+):
   ```bash
   node --version
   ```

2. Update dependencies:
   ```bash
   npm update
   ```

## Available Commands

### Development Mode
```bash
npm run dev
```
- Starts development server with hot reload
- Automatically refreshes when you make changes
- Runs on http://localhost:5173

### Build for Production
```bash
npm run build
```
- Creates optimized production build
- Output goes to `dist` folder
- Use this before deploying to a server

### Preview Production Build
```bash
npm run preview
```
- Preview the production build locally
- Useful for testing before deployment

### Lint Code
```bash
npm run lint
```
- Checks code for errors and style issues

## Configuration

### API URL Configuration

The default API URL is `http://localhost:3000`. If your backend runs on a different URL:

1. Check `src/services/api.ts` for the API base URL
2. Update if necessary (or create a `.env` file with `VITE_API_URL`)

### Environment Variables (Optional)

Create a `.env` file in the `web_application` folder:

```env
VITE_API_URL=http://localhost:3000
```

## Running Both Backend and Frontend

### Option 1: Two Terminal Windows

**Terminal 1 - Backend:**
```bash
cd senseai_backend
npm start
```

**Terminal 2 - Frontend:**
```bash
cd web_application
npm run dev
```

### Option 2: Single Terminal (Background Process)

**Windows PowerShell:**
```powershell
# Start backend in background
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd senseai_backend; npm start"

# Start frontend
cd web_application
npm run dev
```

**Linux/Mac:**
```bash
# Start backend in background
cd senseai_backend && npm start &

# Start frontend
cd web_application && npm run dev
```

## What to Expect

Once running, you should see:

1. **Login Page**: Enter your PIN
2. **Dashboard**: 
   - Statistics cards with gradients
   - Interactive charts
   - Recent activity
   - Assessment components
3. **Navigation**: Sidebar with all menu items
4. **Responsive Design**: Works on desktop, tablet, and mobile

## Features Available

- ✅ Professional Dashboard with analytics
- ✅ Children Management with advanced filtering
- ✅ Sessions/Assessments View
- ✅ Cognitive Dashboard
- ✅ Clinicians List (Admin only)
- ✅ Data Export
- ✅ Multi-language Support (English, Sinhala, Tamil)
- ✅ Settings

## Next Steps

1. **Login** with admin PIN: `admin123`
2. **Explore** the dashboard and features
3. **View** children and sessions data
4. **Export** data if needed
5. **Customize** settings and language

## Support

If you encounter any issues:
1. Check that the backend is running
2. Check browser console for errors (F12)
3. Verify Node.js version is 18+
4. Ensure all dependencies are installed

---

**Happy Coding! 🚀**



