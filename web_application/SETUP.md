# Setup Guide for SenseAI Admin Portal

## Quick Start

### 1. Install Dependencies

```bash
cd web_application
npm install
```

### 2. Start Backend Server

Make sure your backend is running:

```bash
# In a separate terminal, from the main project folder
cd senseai_backend
npm start
```

The backend should run on `http://localhost:3000`

### 3. Start Web Application

```bash
# In web_application folder
npm run dev
```

The web app will run on `http://localhost:5173`

### 4. Login

- Open `http://localhost:5173` in your browser
- Use the same PIN you use in the mobile app
- Default PIN is usually `1234` (if you haven't changed it)

## Project Structure

```
Autism_Screening_Tool_25-26J-273/
├── web_application/          # ← Admin Portal (NEW)
│   ├── src/
│   ├── package.json
│   └── ...
├── senseai_backend/          # ← Backend API (EXISTING)
│   ├── server.js
│   └── ...
└── (mobile app files)        # ← Flutter Mobile App (EXISTING)
```

## Features Available

1. **Dashboard** - Statistics and charts
2. **Children** - View and manage all children
3. **Sessions** - View all assessments
4. **Export** - Export data to CSV
5. **Settings** - Change language

## Troubleshooting

### Port Already in Use

If port 5173 is already in use, Vite will automatically use the next available port (5174, 5175, etc.)

### Backend Connection Error

Make sure:
1. Backend server is running on port 3000
2. No firewall blocking the connection
3. Check `VITE_API_URL` in `.env` file (if you created one)

### Login Issues

- Make sure you've registered a clinician in the backend first
- Use the same PIN from the mobile app
- Check backend logs for errors

## Development Tips

- The web app and mobile app can run simultaneously
- They both connect to the same backend
- Changes to backend will affect both apps
- Web app runs on different port (5173) than backend (3000)





