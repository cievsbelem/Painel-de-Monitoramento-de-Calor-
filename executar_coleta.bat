@echo off
REM ==============================================================================
REM COLETOR E SINCRONIZADOR AUTOMÁTICO - CIEVS BELÉM / SESMA
REM Executa a coleta bioclimática (EHF) e publica no GitHub Pages
REM ==============================================================================
cd /d "%~dp0"

REM 1. Sincroniza com o GitHub antes da coleta enquanto a árvore de trabalho está limpa
git checkout -- dados_clima_atual.json painel_calor_belem.html 2>nul
git pull origin main --rebase >> "%~dp0log_coleta.log" 2>&1

REM 2. Executa o coletor de clima usando Python se disponível, senão PowerShell
where python >nul 2>nul
if %ERRORLEVEL% equ 0 (
    python "%~dp0coletor_clima.py" >> "%~dp0log_coleta.log" 2>&1
) else (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0coletor_clima.ps1" >> "%~dp0log_coleta.log" 2>&1
)

REM 3. Comita e envia os dados atualizados para o GitHub Pages
git add dados_clima_atual.json historico_ehf.csv painel_calor_belem.html >> "%~dp0log_coleta.log" 2>&1
git diff-index --quiet HEAD || (
    git commit -m "Auto-update dados climaticos Belem [skip ci]" >> "%~dp0log_coleta.log" 2>&1
    git push origin main >> "%~dp0log_coleta.log" 2>&1 || (
        git pull origin main --rebase -X theirs >> "%~dp0log_coleta.log" 2>&1
        git push origin main >> "%~dp0log_coleta.log" 2>&1
    )
)
