@echo off
title NEXUS CONFORMITE - N8N Local
color 0B
echo.
echo  =============================================
echo   NEXUS CONFORMITE - Demarrage N8N Local
echo  =============================================
echo.

REM Verifier si Node.js est installe
node --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Node.js n'est pas installe !
    echo Telecharger sur : https://nodejs.org
    pause
    exit /b 1
)

echo [OK] Node.js detecte :
node --version

REM Verifier si N8N est installe
n8n --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo [INFO] N8N non trouve. Installation en cours...
    echo Cela peut prendre 3-5 minutes...
    npm install -g n8n
    IF %ERRORLEVEL% NEQ 0 (
        echo [ERREUR] Echec installation N8N
        echo Essayer : npm install -g n8n --ignore-scripts
        pause
        exit /b 1
    )
    echo [OK] N8N installe avec succes !
)

echo.
echo [OK] N8N detecte :
n8n --version

REM ---- Charger .env OBLIGATOIRE ----
IF NOT EXIST "%~dp0.env" (
    echo.
    echo [ERREUR] Fichier .env introuvable !
    echo Copier .env.example en .env et remplir les valeurs.
    pause
    exit /b 1
)
echo [INFO] Chargement .env...
for /f "usebackq tokens=1,* delims==" %%a in ("%~dp0.env") do (
    if not "%%a"=="" if not "%%a:~0,1%"=="#" set "%%a=%%b"
)

REM Definir les variables d'environnement (non-sensibles)
SET N8N_BASIC_AUTH_ACTIVE=true
SET N8N_PORT=5678
SET N8N_PROTOCOL=http
SET N8N_HOST=localhost
SET EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
SET EXECUTIONS_DATA_SAVE_ON_ERROR=all
SET N8N_LOG_LEVEL=info
SET N8N_USER_FOLDER=%USERPROFILE%\.n8n-nexus

echo.
echo [CONFIG] Dossier de donnees : %N8N_USER_FOLDER%
echo [CONFIG] Interface : http://localhost:5678
echo [CONFIG] Login : voir fichier .env
echo.
echo  =============================================
echo   NEXUS N8N demarre - Ouvrir Chrome :
echo   http://localhost:5678
echo  =============================================
echo.
echo Appuyer sur CTRL+C pour arreter N8N
echo.

REM Demarrer N8N
n8n start

pause
