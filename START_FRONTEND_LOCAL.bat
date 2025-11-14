@echo off
REM ============================================================================
REM ECONEURA Frontend - Start Local
REM ============================================================================

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║        ECONEURA Frontend - Starting Local Development          ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

cd frontend

echo Setting environment variables...
set VITE_API_URL=http://localhost:3001/api
set VITE_NEURA_GW_URL=http://localhost:3001
set VITE_NEURA_GW_KEY=mock

echo.
echo ► Starting frontend on http://localhost:5173
echo ► Press Ctrl+C to stop
echo.

npm run dev


