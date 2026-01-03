# Backend Restart Instructions

## Important: Restart Required

After updating the login route to support admin123, you **MUST restart the backend server** for changes to take effect.

## Steps to Restart

1. **Stop the current backend server:**
   - Find the terminal/command prompt where the backend is running
   - Press `Ctrl + C` to stop it

2. **Start the backend again:**
   ```bash
   cd senseai_backend
   npm start
   ```

3. **Verify it's running:**
   - You should see: `SenseAI Backend + Firebase running`
   - Listening on `http://0.0.0.0:3000`

4. **Test admin login:**
   - Go to `http://localhost:5173/login`
   - Enter PIN: `admin123`
   - Click Login

## Admin Login Details

- **PIN:** `admin123`
- **Role:** Administrator
- **Access:** Full system access

## Troubleshooting

If login still doesn't work after restart:
1. Check backend terminal for errors
2. Check browser console (F12) for API errors
3. Verify backend is running on port 3000
4. Try clearing browser cache







