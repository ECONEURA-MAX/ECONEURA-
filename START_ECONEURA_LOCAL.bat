@echo off
REM ============================================================================
REM ECONEURA - Start Complete Stack Locally
REM ============================================================================

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║              ECONEURA - Starting Full Stack                     ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

echo.
echo 🚀 Starting ECONEURA locally...
echo.
echo ► Backend:  http://localhost:3001
echo ► Frontend: http://localhost:5173
echo.
echo Opening 2 terminal windows...
echo.

REM Start backend in new window
start "ECONEURA Backend (Port 3001)" cmd /k "cd /d %~dp0backend && set NODE_ENV=development && set PORT=3001 && set JWT_ACCESS_SECRET=dev_secret && set JWT_REFRESH_SECRET=dev_secret && set SESSION_SECRET=dev_secret && set LOG_LEVEL=info && node server.js"

REM Wait 3 seconds
timeout /t 3 /nobreak > nul

REM Start frontend in new window
start "ECONEURA Frontend (Port 5173)" cmd /k "cd /d %~dp0frontend && set VITE_API_URL=http://localhost:3001/api && npm run dev"

REM Wait 8 seconds for servers to start
echo Waiting for servers to start...
timeout /t 8 /nobreak > nul

REM Open browser
echo.
echo ✓ Opening browser at http://localhost:5173
echo.
start http://localhost:5173

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                    ✓ ECONEURA RUNNING                           ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Backend:  http://localhost:3001/api/health
echo Frontend: http://localhost:5173
echo.
echo Press any key to close this window (servers will continue running)...
pause > nul


