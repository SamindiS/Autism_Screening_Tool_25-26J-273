# Port 8001 Conflict Solution

## Problem
Port 8001 is being held by PID 20696, preventing the ML engine from starting.

## Solutions

### Option 1: Use a Different Port (Quick Fix)
If you need to start the ML engine immediately, use a different port:

```powershell
cd senseai_backend/ml_engine
python -m uvicorn app.main:app --host 0.0.0.0 --port 8002
```

Then update your backend to call `http://localhost:8002` instead of `8001`.

### Option 2: Find and Kill the Process (Recommended)
1. **Find what's using the port:**
   ```powershell
   Get-NetTCPConnection -LocalPort 8001 | Select-Object OwningProcess
   Get-Process -Id <PID> | Select-Object ProcessName, Path
   ```

2. **Kill the process:**
   ```powershell
   Stop-Process -Id <PID> -Force
   ```

3. **Or kill all Python processes (if safe):**
   ```powershell
   Get-Process python* | Stop-Process -Force
   ```

### Option 3: Wait for Port to Free
Sometimes ports are in TIME_WAIT state after a process closes. Wait 30-60 seconds and try again.

### Option 4: Change ML Engine Port Permanently
Edit `senseai_backend/ml_engine/app/core/config.py`:
```python
DEFAULT_PORT = 8002  # Changed from 8001
```

Then update your backend API calls to use port 8002.

## Current Status
- ✅ Unicode encoding fixed
- ✅ Age-specific models detected (2/3 ready)
- ⚠️ Port 8001 conflict needs resolution

## Recommended Action
Try Option 1 first (use port 8002) to get the ML engine running immediately, then investigate Option 2 to free port 8001 for future use.
