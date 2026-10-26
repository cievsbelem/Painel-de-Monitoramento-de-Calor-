# Guia de Publicação no Shinyapps.io e Automação de Coleta (CRONJOB)
### Sistema Oficial de Vigilância de Excesso de Calor — CIEVS Belém / SESMA

---

## 1. Visão Geral da Adaptação

O painel de monitoramento foi adaptado e otimizado para produção na nuvem (**shinyapps.io**) e para coleta programática contínua dos dados oficiais do Ministério da Saúde:
- **URL Monitorada:** `https://clima.saude.gov.br/pa/belem?modo=ehf`
- **Código IBGE de Belém:** `1501402`
- **Métrica Oficial:** Excess Heat Factor (EHF - Nairn & Fawcett)

---

## 2. Estrutura de Arquivos

```
Painel calor/
├── app.R                          # Aplicação principal formatada para Shinyapps.io
├── PAINEL DE MONITORAMENTO DO CLIMA.R  # Cópia sincronizada da aplicação
├── coletor_clima.R                # Script R para execução via CRON / GitHub Actions
├── coletor_clima.ps1              # Script PowerShell para CRON no Windows
├── configurar_tarefa_agendada.ps1 # Instalador de Tarefa Agendada no Windows (1 clique)
├── executar_coleta.bat            # Executável auxiliar do Agendador do Windows
├── deploy_shinyapps.R             # Script com comandos prontos do rsconnect
├── dados_clima_atual.json         # Cache local com temperaturas e EHF coletados
├── destinatarios.json             # Lista persistente de pontos focais para e-mail
├── historico_ehf.csv              # Série temporal diária de calor
└── .github/
    └── workflows/
        └── cron_coleta_clima.yml  # CRONJOB em nuvem 100% gratuito (GitHub Actions)
```

---

## 3. Como Funciona a Extração Programática dos Dados

O portal `clima.saude.gov.br` renderiza dinamicamente os dados meteorológicos e do modelo ECMWF em registros diários:
```javascript
{cd_mun:"1501402",nm_mun:"Belém",sigla_uf:"PA",data:"2026-09-28",tmean:28.8,tmin:23.7,tmax:33.9,ehf:0,classification:"Normal",fonte:"ecmwf-forecast"}
```

### O que o novo mecanismo faz:
1. Calcula automaticamente a data atual (`Sys.Date()`) e a janela operacional de 5 dias (`Hoje + 4 dias`).
2. Conecta-se à URL oficial e extrai os registros do município de Belém (`1501402`).
3. Mapeia a classificação oficial do Ministério da Saúde para o **Plano de Contingência de Belém**:
   - `Normal` $\rightarrow$ **Sem excesso** (Nível 0 - Normalidade)
   - `Baixo` $\rightarrow$ **Baixo** (Nível 1 - Atenção)
   - `Severo` $\rightarrow$ **Severo** (Nível 2 - Alerta)
   - `Extremo` $\rightarrow$ **Extremo** (Nível 3 - Situação de Emergência)
4. Alimenta em tempo real:
   - O **Banner Principal Pulsante** com a cor, status e ícone correspondente.
   - Os cartões de previsão **D+0 até D+4** com temperaturas máximas e valores de EHF.
   - As **Ações dos 6 Setores de Belém** para o nível bioclimático ativo.

---

## 4. Como Executar a Automação por CRONJOB

No **shinyapps.io**, os servidores entram em modo de suspensão (*idle timeout*) quando não há visitantes conectados. Por esse motivo, criamos **três camadas de atualização**:

### Opção A: GitHub Actions (Nuvem 24/7 Gratuita — Recomendado)
O repositório já conta com o arquivo `.github/workflows/cron_coleta_clima.yml`.
1. Suba este projeto para um repositório no seu GitHub (público ou privado).
2. O GitHub executará automaticamente o coletor todos os dias às **06:00, 12:00 e 18:00** (horário de Belém).
3. Os dados de `dados_clima_atual.json` e `historico_ehf.csv` são atualizados automaticamente no repositório.

### Opção B: Agendador de Tarefas do Windows (Servidor Local CIEVS / SESMA)
Se você tiver um computador ou servidor Windows ligado na sala de situação do CIEVS:
1. Abra o PowerShell como **Administrador**.
2. Execute o comando:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\configurar_tarefa_agendada.ps1
   ```
3. Pronto! O Windows criará a tarefa `CIEVS_Belem_Coleta_EHF` que rodará a cada 2 horas silenciosamente em segundo plano, salvando os logs em `log_coleta.log`.

### Opção C: Atualização Reativa Nativa do Shiny (Em Tempo Real)
Mesmo sem CRON externo, enquanto qualquer usuário estiver com a página aberta:
- O Shiny reexecuta a checagem a cada **10 minutos** automaticamente via `invalidateLater(600000)`.
- Se a temperatura ou nível de alerta mudar no Ministério da Saúde, o painel atualiza a tela na hora e dispara os alertas.

---

## 5. Publicação no Shinyapps.io (Passo a Passo)

### 1º Passo: Obter o Token do Shinyapps.io
1. Acesse [shinyapps.io](https://www.shinyapps.io) e faça login.
2. No menu lateral, vá em **Account** $\rightarrow$ **Tokens**.
3. Clique em **Show** e copie o comando `rsconnect::setAccountInfo(...)`.

### 2º Passo: Publicar via R / RStudio
Abra o RStudio ou console do R na pasta do projeto e execute:

```R
# 1. Instalar rsconnect se ainda não tiver
install.packages("rsconnect")
library(rsconnect)

# 2. Configurar a sua conta (cole o comando obtido no shinyapps.io)
rsconnect::setAccountInfo(
  name   = "<SEU_NOME_DE_CONTA>",
  token  = "<SEU_TOKEN>",
  secret = "<SEU_SECRET>"
)

# 3. Publicar
rsconnect::deployApp(
  appDir = getwd(),
  appName = "painel-calor-cievs-belem",
  appTitle = "Painel de Excesso de Calor - CIEVS Belém",
  forceUpdate = TRUE
)
```

O `rsconnect` fará o upload dos arquivos e construirá o ambiente com todos os pacotes automaticamente. Ao finalizar, o link web público do seu painel será exibido no console.
