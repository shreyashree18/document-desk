@echo off
setlocal EnableDelayedExpansion
title Document Desk Launcher
color 0B

echo ===============================================================================
echo   Document Desk launcher
echo ===============================================================================
echo.

REM ----------------------------------------------------------------
REM 1. Check Python is installed
REM ----------------------------------------------------------------
echo [1/7] Checking for Python...
where python >nul 2>nul
if errorlevel 1 (
    echo.
    echo [ERROR] Python was not found on your PATH.
    echo Please install Python 3.12+ from https://www.python.org/downloads/
    echo IMPORTANT: During installation, check "Add python.exe to PATH".
    echo.
    pause
    exit /b 1
)
for /f "tokens=2" %%v in ('python --version 2^>^&1') do set PYVER=%%v
echo       Found Python %PYVER%
echo.

REM ----------------------------------------------------------------
REM 2. Create virtual environment if missing
REM ----------------------------------------------------------------
echo [2/7] Checking for virtual environment...
if not exist "venv\Scripts\activate.bat" (
    echo       No virtual environment found. Creating one now...
    python -m venv venv
    if errorlevel 1 (
        echo [ERROR] Failed to create the virtual environment.
        pause
        exit /b 1
    )
    echo       Virtual environment created at .\venv
) else (
    echo       Virtual environment already exists.
)
echo.

REM ----------------------------------------------------------------
REM 3. Activate virtual environment
REM ----------------------------------------------------------------
echo [3/7] Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo [ERROR] Failed to activate the virtual environment.
    pause
    exit /b 1
)
echo       Activated.
echo.

REM ----------------------------------------------------------------
REM 4. Install dependencies if missing
REM ----------------------------------------------------------------
echo [4/7] Checking dependencies...
python -c "import fastapi" >nul 2>nul
if errorlevel 1 (
    echo       Installing dependencies from requirements.txt ...
    echo       This may take a few minutes on first run.
    pip install --upgrade pip >nul
    pip install -r requirements.txt
    if errorlevel 1 (
        echo [ERROR] Dependency installation failed. See the messages above.
        pause
        exit /b 1
    )
) else (
    echo       Dependencies already installed.
)
echo.

REM ----------------------------------------------------------------
REM 5. Verify .env file exists
REM ----------------------------------------------------------------
echo [5/7] Checking for .env configuration file...
if not exist ".env" (
    echo       No .env file found. Creating one from .env.example ...
    copy .env.example .env >nul
    echo.
    echo   ****************************************************************
    echo   *  IMPORTANT: Open the new .env file and set your             *
    echo   *  OPENAI_API_KEY before using chat features.                 *
    echo   *  Get a key at https://platform.openai.com/api-keys          *
    echo   ****************************************************************
    echo.
) else (
    findstr /C:"OPENAI_API_KEY=sk-your-openai-api-key-here" .env >nul
    if not errorlevel 1 (
        echo.
        echo   [WARNING] OPENAI_API_KEY in .env still looks like the placeholder value.
        echo   Chat and document indexing will fail until you set a real key.
        echo.
    ) else (
        echo       .env file found.
    )
)
echo.

REM ----------------------------------------------------------------
REM 6. Ensure required folders exist
REM ----------------------------------------------------------------
echo [6/7] Ensuring required folders exist...
if not exist "data\uploads" mkdir "data\uploads"
if not exist "data\vector_store" mkdir "data\vector_store"
if not exist "logs" mkdir "logs"
echo       Folders ready: data\uploads, data\vector_store, logs
echo.

REM ----------------------------------------------------------------
REM 7. Launch the application
REM ----------------------------------------------------------------
echo [7/7] Starting Document Desk ...
echo       Once running, open http://localhost:8000 in your browser.
echo       Press CTRL+C in this window to stop the server.
echo ============================================================
echo.

python -m uvicorn document_desk.main:app --host 0.0.0.0 --port 8000 --reload
set EXITCODE=%errorlevel%

echo.
if not "%EXITCODE%"=="0" (
    echo [ERROR] The application exited with an error ^(code %EXITCODE%^).
    echo Scroll up to review the messages above.
) else (
    echo Document Desk has stopped.
)
echo.
pause
endlocal
