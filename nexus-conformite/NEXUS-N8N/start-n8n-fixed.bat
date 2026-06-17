@echo off
title NEXUS CONFORMITE - N8N Fixed Install
color 0B
echo.
echo  =============================================
echo   NEXUS CONFORMITE - Demarrage N8N (Fixed)
echo   Contournement CDN SheetJS bloque
echo  =============================================
echo.

REM ---- Verifier Node.js ----
node --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Node.js non installe !
    echo Telecharger : https://nodejs.org/dist/v22.22.0/node-v22.22.0-x64.msi
    pause
    exit /b 1
)
echo [OK] Node.js detecte :
node --version

REM ---- Dossier d'installation local (evite l'install globale bloquee) ----
SET N8N_INSTALL_DIR=%~dp0n8n-local
SET N8N_DATA_DIR=%USERPROFILE%\.n8n-nexus
SET N8N_BIN=%N8N_INSTALL_DIR%\node_modules\.bin\n8n.cmd

REM ---- Creer le dossier si absent ----
IF NOT EXIST "%N8N_INSTALL_DIR%" mkdir "%N8N_INSTALL_DIR%"

REM ---- Creer package.json avec override xlsx (contourne SheetJS CDN) ----
IF NOT EXIST "%N8N_INSTALL_DIR%\package.json" (
    echo [INFO] Creation package.json avec override xlsx...
    (
        echo {
        echo   "name": "nexus-n8n",
        echo   "version": "1.0.0",
        echo   "overrides": {
        echo     "xlsx": "npm:xlsx@^0.18.5"
        echo   }
        echo }
    ) > "%N8N_INSTALL_DIR%\package.json"
)

REM ---- Installer N8N localement si absent ----
IF NOT EXIST "%N8N_BIN%" (
    echo.
    echo [INFO] Installation de N8N en cours...
    echo [INFO] Cela peut prendre 3-5 minutes, ne pas fermer cette fenetre.
    echo.
    cd /d "%N8N_INSTALL_DIR%"
    npm install n8n --ignore-scripts
    IF %ERRORLEVEL% NEQ 0 (
        echo.
        echo [ERREUR] Echec installation N8N
        echo Verifier la connexion internet et relancer.
        pause
        exit /b 1
    )
    echo [OK] N8N installe avec succes !
)

REM ---- Verifier que N8N est bien installe ----
IF NOT EXIST "%N8N_BIN%" (
    echo [ERREUR] N8N introuvable apres installation.
    pause
    exit /b 1
)

echo [OK] N8N trouve :
cd /d "%N8N_INSTALL_DIR%"
call "%N8N_BIN%" --version

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

REM ---- Variables d'environnement N8N (lues depuis .env) ----
SET N8N_BASIC_AUTH_ACTIVE=true
SET N8N_PORT=5678
SET N8N_PROTOCOL=http
SET N8N_HOST=localhost
SET N8N_USER_FOLDER=%N8N_DATA_DIR%
SET EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
SET EXECUTIONS_DATA_SAVE_ON_ERROR=all
SET N8N_LOG_LEVEL=warn

REM ---- Creer le dossier de donnees ----
IF NOT EXIST "%N8N_DATA_DIR%" mkdir "%N8N_DATA_DIR%"

echo.
echo  =============================================
echo   N8N demarre sur : http://localhost:5678
echo   Login : voir fichier .env
echo  =============================================
echo.
echo  Ouvrir Chrome et aller sur : http://localhost:5678
echo  Appuyer sur CTRL+C pour arreter N8N
echo.

REM ---- Lancer N8N ----
cd /d "%N8N_INSTALL_DIR%"
call "%N8N_BIN%" start

pause
