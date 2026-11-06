@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Byte Rush - GitHub and Vercel Auto Deploy
cd /d "%~dp0"

set "REPO_URL=https://github.com/yienemir-ctrl/testarchosrobloxpack.git"
set "DEPLOY_ERROR=0"

echo.
echo  ====================================================
echo         BYTE RUSH - ONE CLICK DEPLOY

echo  ====================================================
echo.
echo  Files: %CD%
echo  GitHub: %REPO_URL%
echo  Vercel: NEW Byte Rush project (never replace ArchOS)
echo.

if not exist "index.html" (
    echo [ERROR] index.html was not found. Extract the WHOLE ZIP first.
    goto failed
)
if not exist "main.arch" (
    echo [ERROR] main.arch was not found. Extract the WHOLE ZIP first.
    goto failed
)

where git >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Git is missing: https://git-scm.com/downloads/win
    goto failed
)

echo [1/5] Checking the local repository...
if not exist ".git\" (
    git init
    if errorlevel 1 goto failed
)
git branch -M main
if errorlevel 1 goto failed

git remote get-url origin >nul 2>nul
if errorlevel 1 (
    git remote add origin "%REPO_URL%"
    if errorlevel 1 goto failed
)
set "CURRENT_ORIGIN="
for /f "delims=" %%U in ('git remote get-url origin 2^>nul') do set "CURRENT_ORIGIN=%%U"
if /I not "%CURRENT_ORIGIN%"=="%REPO_URL%" (
    echo [ERROR] The origin remote points to a different repository:
    echo %CURRENT_ORIGIN%
    echo Correct it manually: git remote set-url origin %REPO_URL%
    goto failed
)

set "COMMIT_NAME="
set "COMMIT_EMAIL="
for /f "delims=" %%N in ('git config user.name 2^>nul') do set "COMMIT_NAME=%%N"
for /f "delims=" %%E in ('git config user.email 2^>nul') do set "COMMIT_EMAIL=%%E"
if not defined COMMIT_NAME (
    set /p "COMMIT_NAME=Git commit author name: "
    if not defined COMMIT_NAME goto failed
    git config user.name "%COMMIT_NAME%"
)
if not defined COMMIT_EMAIL (
    set /p "COMMIT_EMAIL=Git commit author email: "
    if not defined COMMIT_EMAIL goto failed
    git config user.email "%COMMIT_EMAIL%"
)

echo [2/5] Checking the remote main branch...
set "REMOTE_MAIN=0"
git ls-remote --exit-code --heads origin main >nul 2>nul
if not errorlevel 1 set "REMOTE_MAIN=1"

git rev-parse --verify HEAD >nul 2>nul
if errorlevel 1 (
    if "%REMOTE_MAIN%"=="1" (
        echo Connecting the extracted files to the existing GitHub history...
        git fetch origin main
        if errorlevel 1 goto failed
        git reset --mixed origin/main
        if errorlevel 1 goto failed
    )
)

echo [3/5] Committing changed files...
git add -A
if errorlevel 1 goto failed
git diff --cached --quiet
if errorlevel 1 (
    git commit -m "Update Byte Rush ArchOS app and web preview"
    if errorlevel 1 goto failed
) else (
    echo No local changes to commit.
)

echo [4/5] Pushing the GitHub repository...
if "%REMOTE_MAIN%"=="1" (
    git pull --rebase origin main
    if errorlevel 1 (
        echo [ERROR] A rebase conflict occurred. Resolve it before trying again.
        goto failed
    )
)
git push -u origin main
if errorlevel 1 (
    echo [ERROR] GitHub push failed. Sign in with Git Credential Manager and retry.
    goto failed
)
echo [OK] GitHub: https://github.com/yienemir-ctrl/testarchosrobloxpack

echo.
echo [5/5] Publishing the web version on Vercel...
where vercel >nul 2>nul
if not errorlevel 1 (
    call vercel deploy --prod --yes
    if errorlevel 1 goto vercel_failed
    goto success
)
where npx >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Node.js / npx missing. Install Node.js LTS from https://nodejs.org/
    goto vercel_failed
)
call npx --yes vercel deploy --prod --yes
if errorlevel 1 goto vercel_failed

:success
echo.
echo [OK] GitHub updated and the web deployment command succeeded.
echo IMPORTANT: The Roblox ArchOS .archapp still must be built with ArchOS Code.
echo See README.md for native installation steps.
echo.
pause
exit /b 0

:vercel_failed
echo.
echo [PARTIAL SUCCESS] GitHub push succeeded, but Vercel deploy failed.
echo Sign into Vercel when prompted, then run DEPLOY.bat again.
echo Make sure you choose a NEW Byte Rush project, not the existing ArchOS website.
pause
exit /b 2

:failed
echo.
echo [FAILED] The deployment stopped. Read the error above and retry.
pause
exit /b 1
