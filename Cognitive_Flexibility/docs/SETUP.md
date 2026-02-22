# Quick Setup Guide

## Prerequisites

- Node.js v14.17.0 or higher (includes `crypto.randomUUID()`)
- npm (comes with Node.js)

## Installation Steps

1. **Navigate to the backend directory:**
   ```bash
   cd senseai_backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start the server:**
   ```bash
   npm start
   ```

   The server will start on `http://localhost:3000`

4. **Verify it's working:**
   ```bash
   curl http://localhost:3000/health
   ```

   You should see:
   ```json
   {
     "status": "OK",
     "timestamp": "2024-01-01T00:00:00.000Z",
     "database": "connected"
   }
   ```

## First Time Setup

1. **Register a clinician:**
   ```bash
   curl -X POST http://localhost:3000/api/clinicians/register \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Dr. Test",
       "hospital": "Test Hospital",
       "pin": "1234"
     }'
   ```

2. **Test login:**
   ```bash
   curl -X POST http://localhost:3000/api/clinicians/login \
     -H "Content-Type: application/json" \
     -d '{
       "pin": "1234"
     }'
   ```

## Troubleshooting

### Port Already in Use
If port 3000 is already in use, set a different port:
```bash
PORT=3001 npm start
```

### Database Errors
If you see database errors, delete `senseai.db` and restart the server. The database will be recreated automatically.

### Node Version Issues
Check your Node.js version:
```bash
node --version
```

Should be v14.17.0 or higher. If not, update Node.js.

## Development Mode

For auto-reload during development:
```bash
npm run dev
```

(Requires `nodemon` to be installed globally or as dev dependency)

