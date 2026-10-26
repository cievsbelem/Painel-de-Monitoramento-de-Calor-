<#
.SYNOPSIS
    Registra uma Tarefa Agendada no Windows (equivalente a um CRONJOB) para executar o coletor automaticamente.
.DESCRIPTION
    Configura para rodar a cada 2 horas ou diariamente nos horários 06:00, 12:00 e 18:00.
#>

$NomeTarefa = "CIEVS_Belem_Coleta_EHF"
$ScriptBat = Join-Path $PSScriptRoot "executar_coleta.bat"

if (-not (Test-Path $ScriptBat)) {
    Write-Error "Arquivo executar_coleta.bat não encontrado em $ScriptBat"
    exit 1
}

Write-Host "Configurando Tarefa Agendada no Windows: $NomeTarefa" -ForegroundColor Cyan

# Ação: Executar o bat
$Acao = New-ScheduledTaskAction -Execute $ScriptBat

# Gatilho: Diariamente a partir das 06:00, repetindo a cada 2 horas por 24 horas
$Gatilho = New-ScheduledTaskTrigger -Daily -At "06:00AM"
$Gatilho.Repetition = (New-ScheduledTaskTrigger -Once -At "06:00AM" -RepetitionInterval (New-TimeSpan -Hours 2) -RepetitionDuration (New-TimeSpan -Days 1)).Repetition

# Configurações adicionais: Executar mesmo sem bateria, reiniciar em caso de falha
$Configuracoes = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

try {
    # Remove se já existir
    Unregister-ScheduledTask -TaskName $NomeTarefa -Confirm:$false -ErrorAction SilentlyContinue
    
    # Registra a nova tarefa para o usuário atual
    Register-ScheduledTask -TaskName $NomeTarefa -Action $Acao -Trigger $Gatilho -Settings $Configuracoes -Description "Coleta automática de dados bioclimáticos (EHF) do Ministério da Saúde para o Painel CIEVS Belém."
    
    Write-Host "`n[SUCESSO] Tarefa Agendada '$NomeTarefa' registrada com êxito!" -ForegroundColor Green
    Write-Host "A coleta será executada automaticamente a cada 2 horas (iniciando às 06:00)."
    Write-Host "Os registros e logs serão gravados em log_coleta.log e dados_clima_atual.json."
} catch {
    Write-Error "Falha ao registrar a tarefa agendada: $_"
    Write-Host "Dica: Execute o PowerShell como Administrador para registrar tarefas no sistema." -ForegroundColor Yellow
}
