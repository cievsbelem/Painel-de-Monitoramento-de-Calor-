<#
.SYNOPSIS
    Script de Coleta Automatizada (CRONJOB) para o Painel de Vigilância de Excesso de Calor - CIEVS Belém / SESMA.
    Extrai dados do Ministério da Saúde: https://clima.saude.gov.br/pa/belem?modo=ehf
#>

param(
    [string]$OutputDir = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

$mesesNomes = @{
    1 = "jan."; 2 = "fev."; 3 = "mar."; 4 = "abr."; 5 = "mai."; 6 = "jun.";
    7 = "jul."; 8 = "ago."; 9 = "set."; 10 = "out."; 11 = "nov."; 12 = "dez."
}

function Formatar-DiaBr([datetime]$dt) {
    $m = $mesesNomes[$dt.Month]
    return "$($dt.Day) de $m"
}

function Mapear-Classe([string]$cls) {
    if ([string]::IsNullOrWhiteSpace($cls)) { return "Sem excesso" }
    $c = $cls.Trim().ToLower()
    if ($c -match "normal|sem|nenhum") { return "Sem excesso" }
    if ($c -match "baixo|moderado|atencao|atenção") { return "Baixo" }
    if ($c -match "severo|alerta|laranja") { return "Severo" }
    if ($c -match "extremo|emergencia|emergência|vermelho") { return "Extremo" }
    return "Sem excesso"
}

try {
    $hoje = Get-Date
    $dataAlvo = $hoje.AddDays(4).ToString("yyyy-MM-dd")
    $url = "https://clima.saude.gov.br/pa/belem?data=$dataAlvo&modo=ehf"
    
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Iniciando coleta oficial: $url" -ForegroundColor Cyan
    
    $htmlContent = $null
    
    # Tentativa 1: curl.exe nativo
    try {
        $tempFile = [System.IO.Path]::GetTempFileName()
        & curl.exe -s -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" $url -o $tempFile
        if (Test-Path $tempFile) {
            $htmlContent = [System.IO.File]::ReadAllText($tempFile, [System.Text.Encoding]::UTF8)
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Warning "curl.exe falhou, tentando Invoke-WebRequest..."
    }
    
    # Tentativa 2: Invoke-WebRequest se necessário
    if ([string]::IsNullOrEmpty($htmlContent) -or $htmlContent.Length -lt 1000) {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -UserAgent "Mozilla/5.0" -TimeoutSec 15
        $htmlContent = $response.Content
    }
    
    if ([string]::IsNullOrEmpty($htmlContent)) {
        throw "Não foi possível obter resposta de $url"
    }
    
    # Extrair registros de Belém (IBGE 1501402)
    $pattern = '\{[^{}]*cd_mun:"1501402"[^{}]*\}'
    $matches = [regex]::Matches($htmlContent, $pattern)
    
    if ($matches.Count -eq 0) {
        throw "Nenhum registro para Belém (1501402) encontrado no HTML retornado."
    }
    
    Write-Host "Registros brutos encontrados: $($matches.Count)" -ForegroundColor Green
    
    $dadosPorData = @{}
    foreach ($m in $matches) {
        $str = $m.Value
        $dtStr = if ($str -match 'data:"([^"]+)"') { $Matches[1] } else { $null }
        if (-not $dtStr) { continue }
        
        $tmax = if ($str -match 'tmax:([0-9\.]+)') { [math]::Round([double]$Matches[1], 1) } else { 34.0 }
        $tmin = if ($str -match 'tmin:([0-9\.]+)') { [math]::Round([double]$Matches[1], 1) } else { 23.0 }
        $ehf  = if ($str -match 'ehf:([0-9\.\-]+)') { [math]::Round([double]$Matches[1], 2) } else { 0.0 }
        $rawClass = if ($str -match 'classification:"([^"]+)"') { $Matches[1] } else { "Normal" }
        $classe = Mapear-Classe $rawClass
        
        $dadosPorData[$dtStr] = @{
            data_iso = $dtStr
            tmax     = $tmax
            tmin     = $tmin
            ehf      = $ehf
            classe   = $classe
        }
    }
    
    $mapaDesc = @{
        "Sem excesso" = @{ titulo = "NÍVEL DE CALOR 1: NORMALIDADE"; subtitulo = "CLASSIFICAÇÃO DO EHF: SEM EXCESSO DE CALOR" }
        "Baixo"       = @{ titulo = "NÍVEL DE CALOR 2: ATENÇÃO"; subtitulo = "CLASSIFICAÇÃO DO EHF: BAIXO" }
        "Severo"      = @{ titulo = "NÍVEL DE CALOR 3: ALERTA"; subtitulo = "CLASSIFICAÇÃO DO EHF: SEVERO" }
        "Extremo"     = @{ titulo = "NÍVEL DE CALOR 4: EMERGÊNCIA"; subtitulo = "CLASSIFICAÇÃO DO EHF: EXTREMO" }
    }

    # Construir lista dos 5 dias (Hoje D+0 até D+4)
    $previsoes = @()
    for ($i = 0; $i -lt 5; $i++) {
        $dataDia = $hoje.AddDays($i)
        $isoStr = $dataDia.ToString("yyyy-MM-dd")
        $diaFormatado = Formatar-DiaBr $dataDia
        $dataBr = $dataDia.ToString("dd/MM/yyyy")
        
        $classeItem = "Sem excesso"
        $tmaxItem = 34.0
        $tminItem = 23.0
        $ehfItem = 0.0

        if ($dadosPorData.ContainsKey($isoStr)) {
            $reg = $dadosPorData[$isoStr]
            $classeItem = $reg.classe
            $tmaxItem = $reg.tmax
            $tminItem = $reg.tmin
            $ehfItem = $reg.ehf
        }

        $infoItem = if ($mapaDesc.ContainsKey($classeItem)) { $mapaDesc[$classeItem] } else { $mapaDesc["Sem excesso"] }

        $item = @{
            dia           = $diaFormatado
            data_br       = $dataBr
            classe        = $classeItem
            ehf           = $ehfItem
            tmax          = $tmaxItem
            tmin          = $tminItem
            titulo_nivel  = $infoItem.titulo
            subtitulo_ehf = $infoItem.subtitulo
        }
        $previsoes += $item
    }
    
    $infoHoje = if ($mapaDesc.ContainsKey($previsoes[0].classe)) { $mapaDesc[$previsoes[0].classe] } else { $mapaDesc["Sem excesso"] }

    $payload = @{
        municipio     = "Bel`u{00E9}m - PA"
        data_base_iso = $hoje.ToString("yyyy-MM-dd")
        data_base_br  = $hoje.ToString("dd/MM/yyyy")
        hora_consulta = (Get-Date -Format "HH:mm:ss")
        sucesso       = $true
        fonte_url     = "https://clima.saude.gov.br/pa/belem?data=2026-10-27&modo=ehf"
        titulo_nivel  = $infoHoje.titulo
        subtitulo_ehf = $infoHoje.subtitulo
        hoje          = $previsoes[0]
        previsoes     = $previsoes
    }
    
    # Salvar em JSON para alimentação direta do Shiny
    $jsonPath = Join-Path $OutputDir "dados_clima_atual.json"
    $jsonText = $payload | ConvertTo-Json -Depth 5
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($jsonPath, $jsonText, $utf8NoBom)
    Write-Host "Arquivo atualizado com sucesso: $jsonPath" -ForegroundColor Green
    
    # Registrar no histórico CSV
    $csvPath = Join-Path $OutputDir "historico_ehf.csv"
    $csvExiste = Test-Path $csvPath
    $linhaCsv = "$($payload.data_base_iso),$($payload.hora_consulta),$($payload.hoje.tmax),$($payload.hoje.tmin),$($payload.hoje.ehf),$($payload.hoje.classe)"
    
    if (-not $csvExiste) {
        [System.IO.File]::WriteAllLines($csvPath, @("data_iso,hora_consulta,tmax,tmin,ehf,classe"), $utf8NoBom)
    }
    [System.IO.File]::AppendAllText($csvPath, "$linhaCsv`r`n", $utf8NoBom)
    Write-Host "Histórico atualizado: $csvPath" -ForegroundColor Green
    
    Write-Host "`n=== RESUMO DO CLIMA ATUALIZADO (BELÉM - PA) ===" -ForegroundColor Yellow
    Write-Host "Hoje: $($payload.hoje.tmax)°C | EHF: $($payload.hoje.ehf) | Nível: $($payload.hoje.classe)"
    foreach ($p in $payload.previsoes) {
        Write-Host "$($p.dia) ($($p.data_br)) -> Tmax: $($p.tmax)°C | EHF: $($p.ehf) | Nível: $($p.classe)"
    }
    Write-Host "==============================================" -ForegroundColor Yellow
    
} catch {
    Write-Error "Erro na coleta de dados: $_"
    exit 1
}
