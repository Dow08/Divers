@echo off
title NEXUS CONFORMITE - Session 9 Quick Start
color 0B
cls

echo.
echo  =====================================================
echo   NEXUS CONFORMITE - Session 9 Quick Start Check
echo   30/03/2026 - Preparation pour deploiement prod
echo  =====================================================
echo.
echo  Ce script verifie l'etat local avant de passer
echo  en production sur OVH.
echo.

cd /d "%~dp0"

echo ============================================
echo  ETAPE 1 - Status Git
echo ============================================
git -C ".." status --short
echo.
echo Derniers commits :
git -C ".." log --oneline -5
echo.
pause

echo ============================================
echo  ETAPE 2 - Verification N8N
echo ============================================
echo Test connexion N8N local (127.0.0.1:5678)...
curl -s -o nul -w "Status: %%{http_code}" http://127.0.0.1:5678/rest/settings 2>nul
echo.
echo.
echo Si N8N n'est pas lance, demarrer avec :
echo   start-n8n-fixed.bat
echo.
pause

echo ============================================
echo  ETAPE 3 - Import workflows (WF-07 fix)
echo ============================================
echo Lancer import-workflows.js pour appliquer le fix WF-07 ?
echo (Necessite N8N actif + .env configure)
echo.
set /p CONFIRM="Appuyer O pour importer, N pour passer : "
if /i "%CONFIRM%"=="O" (
    node import-workflows.js
    echo.
    echo Import termine !
) else (
    echo Import ignore.
)
echo.
pause

echo ============================================
echo  ETAPE 4 - Test WF-07 Gumroad (local)
echo ============================================
echo Test webhook WF-07 en local...
curl -s -X POST http://127.0.0.1:5678/webhook/gumroad-webhook ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"seallia81@gmail.com\",\"product_name\":\"Kit RGPD NEXUS\",\"price\":9700,\"sale_id\":\"TEST-S9-LOCAL\"}"
echo.
echo Verifier la reception de l'email de livraison.
echo.
pause

echo ============================================
echo  ETAPE 5 - Rappel OVH (domaine)
echo ============================================
echo.
echo   Aller sur : https://www.ovhcloud.com/fr/domains/
echo   Rechercher : nexusconformite.fr
echo   Prix : ~4.99 euros/an
echo.
echo   Ensuite hebergement :
echo   VPS Starter : https://www.ovhcloud.com/fr/vps/starter/
echo   Prix : ~5.99 euros/mois
echo.
echo   Guide complet : GUIDES\OVH-SETUP-GUIDE.md
echo.
start "" "https://www.ovhcloud.com/fr/domains/"
pause

echo ============================================
echo  PRET POUR SESSION 9 !
echo ============================================
echo.
echo  Checklist :
echo  [ ] nexusconformite.fr achete sur OVH
echo  [ ] VPS commande + IP recuperee
echo  [ ] deploy-n8n-vps.sh uploade et execute
echo  [ ] /etc/n8n/.env rempli avec vraies cles
echo  [ ] Workflows importes en production
echo  [ ] Webhook Gumroad configure
echo  [ ] Webhook Stripe configure
echo.
echo  Bon courage pour la mise en production !
echo.
pause
