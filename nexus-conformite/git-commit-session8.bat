@echo off
echo ============================================
echo  NEXUS CONFORMITE - Git Commit Session 8
echo ============================================
cd /d "%~dp0"

REM Remove stale lock file if it exists
if exist ".git\index.lock" (
    echo Removing stale git index.lock...
    del /f ".git\index.lock"
)

REM Stage all changed files
git add NEXUS-N8N\workflows\WF-06-leads-annuaire.json
git add NEXUS-N8N\workflows\WF-07-livraison-gumroad.json
git add nexusconformite-landing.html
git add NEXUS-N8N\start-n8n-fixed.bat
git add NEXUS-N8N\start-n8n.bat
git add NEXUS-N8N\start-n8n-linux.sh
git add NEXUS-N8N\import-workflows.js
git add NEXUS-N8N\setup-n8n-credentials.js
git add NEXUS-N8N\SETUP-CREDENTIALS.md
git add NEXUS-N8N\workflows\WF-04-alertes-revenus.json
git add NEXUS-N8N\.env.example
git add SEO-PLAN-10-ARTICLES.md 2>nul

echo.
echo Files staged. Committing...

git commit -m "fix(workflows): correct email params WF-06/07, fix WF-04 JSON, modern landing 2026

- WF-06: fix emailFormat/html params (was emailType/message), populate HTML bodies
- WF-07: same email param fix for Livraison + Suivi J+7 nodes
- WF-04: repair truncated JSON (meta field was unclosed, 4 nodes intact)
- N8N scripts: credential setup + import workflow improvements
- .env.example: add ADMIN_EMAIL var (used by WF-06 admin notifications)
- Landing page: full 2026 UX/UI rewrite (glassmorphism, gradient mesh, count-up stats,
  scroll reveal, toast notifications, mobile hamburger, FAQ accordion)
- SEO plan: 10 articles roadmap added"

echo.
echo Pushing to GitHub...
git push origin main

echo.
echo ============================================
echo  Done! Check GitHub for the new commit.
echo ============================================
pause
