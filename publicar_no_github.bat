@echo off
chcp 65001 >nul
title Publicação do Painel no GitHub - CIEVS Belém
color 0A
cd /d "%~dp0"
set "PATH=C:\Program Files\Git\mingw64\bin;C:\Program Files\Git\cmd;%PATH%"

cls
echo ======================================================================
echo    PUBLICANDO PAINEL DE CALOR NO GITHUB (CIEVS BELÉM)
echo ======================================================================
echo.
echo Repositório: https://github.com/cievsbelem/Painel-de-Monitoramento-de-Calor-
echo.
echo [1] Tentando envio direto para o GitHub...
git push -u origin main --force

if %ERRORLEVEL% EQU 0 (
    cls
    echo ======================================================================
    echo   [SUCESSO] ARQUIVOS ENVIADOS COM SUCESSO PARA O GITHUB!
    echo ======================================================================
    echo.
    echo   Seu painel estará disponível 24h por dia em:
    echo   👉 https://cievsbelem.github.io/Painel-de-Monitoramento-de-Calor-/
    echo.
    echo   A automação contínua está ativada.
    echo ======================================================================
    echo.
    pause
    exit /b 0
)

echo.
echo ======================================================================
echo   O GitHub solicitou autenticação para liberar o envio.
echo ======================================================================
echo.
echo Escolha a melhor opção para você:
echo.
echo  [1] Conectar com Token de Acesso (Recomendado - Rápido e 100%% garantido)
echo  [2] Abrir o navegador para autorizar o Git
echo  [3] Sair
echo.
set /p OPCAO="Digite o número da opção (1, 2 ou 3) e aperte ENTER: "

if "%OPCAO%"=="1" (
    echo.
    echo Abrindo a página do GitHub para gerar seu Token...
    start https://github.com/settings/tokens/new?scopes=repo^&description=PainelCalorBelem
    echo.
    echo ------------------------------------------------------------------
    echo 1. Na página que abriu no navegador, role até o final e clique no
    echo    botão verde "Generate token".
    echo 2. Copie o token gerado (começa com ghp_...).
    echo ------------------------------------------------------------------
    echo.
    set /p TOKEN="Cole o Token aqui (clique com botão direito para colar) e aperte ENTER: "
    if not "%TOKEN%"=="" (
        git remote set-url origin https://%TOKEN%@github.com/cievsbelem/Painel-de-Monitoramento-de-Calor-.git
        echo.
        echo Enviando arquivos com o token configurado...
        git push -u origin main --force
        if %ERRORLEVEL% EQU 0 (
            cls
            echo ======================================================================
            echo   [SUCESSO] CONECTADO E PUBLICADO COM SUCESSO!
            echo ======================================================================
            echo.
            echo O token foi salvo no seu repositório local.
            echo O robô do Windows agora enviará as atualizações automaticamente!
            echo.
            echo Acesse seu painel em:
            echo 👉 https://cievsbelem.github.io/Painel-de-Monitoramento-de-Calor-/
            echo ======================================================================
        ) else (
            echo [ERRO] O token informado não teve permissão de envio. Verifique e tente novamente.
        )
    )
)

if "%OPCAO%"=="2" (
    echo.
    echo Abrindo navegador para login...
    "C:\Program Files\Git\mingw64\bin\git-credential-manager.exe" github login --browser
    git push -u origin main --force
)

echo.
pause
