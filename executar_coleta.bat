@echo off
REM Executa o coletor de clima usando Python se disponível, senão PowerShell
cd /d "%~dp0"
where python >nul 2>nul
if %ERRORLEVEL% equ 0 (
    python "%~dp0coletor_clima.py" >> "%~dp0log_coleta.log" 2>&1
) else (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0coletor_clima.ps1" >> "%~dp0log_coleta.log" 2>&1
)
