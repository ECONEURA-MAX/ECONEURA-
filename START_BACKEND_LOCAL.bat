@echo off
REM ============================================================================
REM ECONEURA Backend - Start Local
REM ============================================================================

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║         ECONEURA Backend - Starting Local Development          ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

cd backend

echo Setting environment variables...
set NODE_ENV=development
set PORT=3001
set DATABASE_URL=postgresql://postgres:postgres@localhost:5432/econeura_dev
set REDIS_URL=redis://localhost:6379
set JWT_ACCESS_SECRET=dev_access_secret_local_only
set JWT_REFRESH_SECRET=dev_refresh_secret_local_only
set SESSION_SECRET=dev_session_secret_local_only
set LOG_LEVEL=debug

echo.
echo ► Starting backend on http://localhost:3001
echo ► Health check: http://localhost:3001/api/health
echo ► Press Ctrl+C to stop
echo.

node server.js


