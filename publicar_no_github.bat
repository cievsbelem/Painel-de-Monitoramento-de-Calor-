@echo off
chcp 65001 >nul
title Publicação do Painel no GitHub - CIEVS Belém
color 0A
cls
echo ======================================================================
echo    PUBLICANDO PAINEL DE CALOR NO GITHUB (CIEVS BELÉM)
echo ======================================================================
echo.
echo Conectando ao repositório:
echo https://github.com/cievsbelem/Painel-de-Monitoramento-de-Calor-
echo.
echo Se uma janela do navegador abrir solicitando autorização do GitHub,
echo clique em "Sign in with your browser" / "Authorize git-credential-manager".
echo.
git push -u origin main --force
echo.
if %ERRORLEVEL% EQU 0 (
    echo ======================================================================
    echo   [SUCESSO] Arquivos enviados com sucesso para o GitHub!
    echo   Seu painel estará disponível 24h por dia em:
    echo   https://cievsbelem.github.io/Painel-de-Monitoramento-de-Calor-/
    echo ======================================================================
) else (
    echo.
    echo [AVISO] Se o login falhou ou não abriu, você pode enviar diretamente
    echo pelo navegador no link:
    echo https://github.com/cievsbelem/Painel-de-Monitoramento-de-Calor-/upload/main
)
echo.
pause
