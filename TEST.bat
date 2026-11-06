@echo off
setlocal
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js is required for this test. Install https://nodejs.org/
  pause
  exit /b 1
)
node tests\preview.test.js
if errorlevel 1 (
  echo TEST FAILED.
  pause
  exit /b 1
)
echo All tests passed.
pause
