# =============================================================================
# PAINEL DE ALERTA DE CALOR – BELÉM/PA
# CISC / CIEVS
# Versão corrigida – atualização automática a cada 1 hora
#
# COMO EXECUTAR:
# 1. Salve este arquivo como app.R
# 2. Abra no RStudio
# 3. Execute o arquivo inteiro (Ctrl + Shift + Enter)
#    ou clique em "Run App"
#
# OBSERVAÇÃO:
# - O script instala automaticamente apenas os pacotes necessários.
# - No Windows, tenta instalar versões BINÁRIAS dos pacotes.
# - Rtools normalmente NÃO é necessário para instalar pacotes binários.
# - O painel continua funcionando mesmo se a consulta ao Painel EHF falhar.
# =============================================================================

# =============================================================================
# 1. INSTALAÇÃO E CARREGAMENTO DOS PACOTES
# =============================================================================

PACOTES <- c(
  "shiny",
  "jsonlite",
  "httr"
)

instalar_pacotes <- function(pacotes) {
  
  faltantes <- pacotes[
    !vapply(
      pacotes,
      requireNamespace,
      FUN.VALUE = logical(1),
      quietly = TRUE
    )
  ]
  
  if (length(faltantes) == 0) {
    message("✓ Todos os pacotes necessários já estão instalados.")
    return(invisible(TRUE))
  }
  
  message("Instalando pacotes necessários: ",
          paste(faltantes, collapse = ", "))
  
  # Repositório CRAN
  repos_cran <- "https://cloud.r-project.org"
  
  # No Windows, solicitar preferencialmente pacotes binários.
  if (.Platform$OS.type == "windows") {
    
    antigo <- getOption("pkgType")
    
    options(pkgType = "binary")
    
    tryCatch(
      {
        install.packages(
          faltantes,
          repos = repos_cran,
          dependencies = TRUE,
          type = "binary"
        )
      },
      error = function(e) {
        
        message("Não foi possível instalar usando type = binary.")
        message("Tentando instalação padrão do CRAN...")
        
        install.packages(
          faltantes,
          repos = repos_cran,
          dependencies = TRUE
        )
      },
      finally = {
        options(pkgType = antigo)
      }
    )
    
  } else {
    
    install.packages(
      faltantes,
      repos = repos_cran,
      dependencies = TRUE
    )
  }
  
  # Verificação final
  ainda_faltando <- pacotes[
    !vapply(
      pacotes,
      requireNamespace,
      FUN.VALUE = logical(1),
      quietly = TRUE
    )
  ]
  
  if (length(ainda_faltando) > 0) {
    
    stop(
      paste0(
        "\nNão foi possível instalar os seguintes pacotes:\n",
        paste(ainda_faltando, collapse = ", "),
        "\n\nVerifique sua conexão com a internet e a versão do R."
      )
    )
  }
  
  message("✓ Pacotes instalados com sucesso.")
  
  invisible(TRUE)
}

instalar_pacotes(PACOTES)

suppressPackageStartupMessages({
  
  library(shiny)
  library(jsonlite)
  library(httr)
  
})

# =============================================================================
# 2. CONFIGURAÇÕES
# =============================================================================

URL_EHF <- "https://clima.saude.gov.br/pa/belem?modo=ehf"

LAT_BELEM <- -1.4558
LON_BELEM <- -48.5039

FUSO_HORARIO <- "America/Belem"

# Atualização automática:
# 60 minutos x 60 segundos x 1000 milissegundos
INTERVALO_MS <- 60 * 60 * 1000

# -----------------------------------------------------------------------------
# CORES DO PROTOCOLO
# -----------------------------------------------------------------------------

CORES <- list(
  
  verde = "#2E7D32",
  amarelo = "#F9A825",
  laranja = "#EF8A17",
  vermelho = "#C62828",
  
  azul = "#0D47A1",
  azul_claro = "#1565C0",
  
  fundo = "#F3F6FA",
  branco = "#FFFFFF",
  texto = "#1F2937",
  
  cinza = "#6B7280",
  cinza_claro = "#E5E7EB"
  
)

# Ordem dos níveis

ORDEM_NIVEL <- c(
  
  "Normalidade" = 0,
  "Atenção" = 1,
  "Alerta" = 2,
  "Emergência" = 3
  
)

# =============================================================================
# 3. FUNÇÕES AUXILIARES
# =============================================================================

numero_seguro <- function(x) {
  
  if (is.null(x) || length(x) == 0) {
    return(NA_real_)
  }
  
  x <- as.character(x[1])
  
  if (is.na(x) || !nzchar(x)) {
    return(NA_real_)
  }
  
  x <- gsub(",", ".", x, fixed = TRUE)
  
  suppressWarnings(as.numeric(x))
  
}


formatar_numero <- function(x, casas = 1, sufixo = "") {
  
  if (is.null(x) || length(x) == 0 || is.na(x)) {
    return("Indisponível")
  }
  
  paste0(
    format(
      round(as.numeric(x), casas),
      nsmall = casas,
      decimal.mark = ",",
      big.mark = "."
    ),
    sufixo
  )
  
}


escape_html_seguro <- function(x) {
  
  htmltools::htmlEscape(
    as.character(x)
  )
  
}


agora_belem <- function() {
  
  format(
    Sys.time(),
    tz = FUSO_HORARIO,
    format = "%d/%m/%Y %H:%M:%S"
  )
  
}


# =============================================================================
# 4. CONSULTA AO OPEN-METEO
# =============================================================================
#
# Fonte complementar:
# https://open-meteo.com/
#
# Dados utilizados:
# - Temperatura atual
# - Umidade atual
# - Sensação térmica atual
# - Temperatura máxima diária
#
# A temperatura máxima diária é utilizada pelo protocolo.
# A sensação térmica atual é utilizada como gatilho complementar.
# =============================================================================

consultar_meteorologia <- function() {
  
  resultado <- list(
    
    temperatura_atual = NA_real_,
    umidade = NA_real_,
    sensacao = NA_real_,
    temperatura_maxima = NA_real_,
    
    horario_dado = NA_character_,
    
    status = "ERRO",
    mensagem = NULL
    
  )
  
  url <- paste0(
    
    "https://api.open-meteo.com/v1/forecast?",
    
    "latitude=", LAT_BELEM,
    "&longitude=", LON_BELEM,
    
    "&current=",
    "temperature_2m,",
    "relative_humidity_2m,",
    "apparent_temperature",
    
    "&daily=temperature_2m_max",
    
    "&forecast_days=1",
    
    "&timezone=America%2FBelem"
    
  )
  
  tryCatch({
    
    resposta <- httr::GET(
      
      url,
      
      httr::timeout(30),
      
      httr::user_agent(
        "CISC-Belem-Painel-Calor/2.0"
      )
      
    )
    
    if (httr::status_code(resposta) != 200) {
      
      stop(
        paste(
          "Open-Meteo retornou HTTP",
          httr::status_code(resposta)
        )
      )
      
    }
    
    texto_json <- httr::content(
      resposta,
      as = "text",
      encoding = "UTF-8"
    )
    
    dados <- jsonlite::fromJSON(
      texto_json,
      simplifyVector = TRUE
    )
    
    if (!is.null(dados$current)) {
      
      resultado$temperatura_atual <-
        numero_seguro(
          dados$current$temperature_2m
        )
      
      resultado$umidade <-
        numero_seguro(
          dados$current$relative_humidity_2m
        )
      
      resultado$sensacao <-
        numero_seguro(
          dados$current$apparent_temperature
        )
      
      resultado$horario_dado <-
        as.character(
          dados$current$time
        )
      
    }
    
    if (!is.null(dados$daily)) {
      
      resultado$temperatura_maxima <-
        numero_seguro(
          dados$daily$temperature_2m_max
        )
      
    }
    
    resultado$status <- "OK"
    
    resultado
    
  }, error = function(e) {
    
    resultado$mensagem <- conditionMessage(e)
    
    resultado
    
  })
  
}


# =============================================================================
# 5. CONSULTA AO PAINEL EHF
# =============================================================================
#
# O Painel de Excesso de Calor é usado como indicador contextual.
#
# IMPORTANTE:
# Algumas páginas modernas carregam informações por JavaScript.
# Por isso, o painel NÃO depende exclusivamente da leitura do HTML.
#
# Se a leitura do EHF falhar:
# - o aplicativo continua funcionando;
# - a classificação operacional continua sendo feita com dados meteorológicos.
# =============================================================================

consultar_ehf <- function() {
  
  resultado <- list(
    
    ehf = NA_character_,
    risco = NA_character_,
    texto = NA_character_,
    
    status = "ERRO",
    mensagem = NULL
    
  )
  
  tryCatch({
    
    resposta <- httr::GET(
      
      URL_EHF,
      
      httr::timeout(30),
      
      httr::user_agent(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
      )
      
    )
    
    codigo <- httr::status_code(resposta)
    
    if (codigo != 200) {
      
      stop(
        paste(
          "Painel EHF retornou HTTP",
          codigo
        )
      )
      
    }
    
    html <- httr::content(
      resposta,
      as = "text",
      encoding = "UTF-8"
    )
    
    # Remove tags HTML.
    texto <- gsub(
      "<[^>]*>",
      " ",
      html
    )
    
    # Remove múltiplos espaços.
    texto <- gsub(
      "[[:space:]]+",
      " ",
      texto
    )
    
    texto <- trimws(texto)
    
    resultado$texto <- texto
    
    # -------------------------------------------------------------------------
    # TENTATIVA DE EXTRAÇÃO DO EHF
    # -------------------------------------------------------------------------
    
    padrao_ehf <- regexec(
      
      "EHF[[:space:]:-]+([^<]{1,100})",
      
      texto,
      
      ignore.case = TRUE
      
    )
    
    encontrado_ehf <- regmatches(
      texto,
      padrao_ehf
    )
    
    if (
      length(encontrado_ehf) > 0 &&
      length(encontrado_ehf[[1]]) >= 2
    ) {
      
      valor <- trimws(
        encontrado_ehf[[1]][2]
      )
      
      valor <- sub(
        "Risco.*$",
        "",
        valor,
        ignore.case = TRUE
      )
      
      valor <- trimws(valor)
      
      if (nzchar(valor)) {
        resultado$ehf <- valor
      }
      
    }
    
    # -------------------------------------------------------------------------
    # TENTATIVA DE EXTRAÇÃO DO RISCO
    # -------------------------------------------------------------------------
    
    padrao_risco <- regexec(
      
      "Risco[[:space:]:-]+([^<]{1,100})",
      
      texto,
      
      ignore.case = TRUE
      
    )
    
    encontrado_risco <- regmatches(
      texto,
      padrao_risco
    )
    
    if (
      length(encontrado_risco) > 0 &&
      length(encontrado_risco[[1]]) >= 2
    ) {
      
      valor <- trimws(
        encontrado_risco[[1]][2]
      )
      
      valor <- sub(
        "Comparar.*$",
        "",
        valor,
        ignore.case = TRUE
      )
      
      valor <- trimws(valor)
      
      if (nzchar(valor)) {
        resultado$risco <- valor
      }
      
    }
    
    resultado$status <- "OK"
    
    resultado
    
  }, error = function(e) {
    
    resultado$mensagem <- conditionMessage(e)
    
    resultado
    
  })
  
}


# =============================================================================
# 6. CLASSIFICAÇÃO DO PROTOCOLO DE CALOR
# =============================================================================
#
# VERDE
# Temperatura máxima < 32°C
#
# AMARELO
# Temperatura máxima >= 32°C
# OU sensação térmica >= 32°C
#
# LARANJA
# Temperatura máxima >= 36°C
# OU sensação térmica >= 40°C
#
# VERMELHO
# Temperatura máxima >= 38°C
# OU sensação térmica >= 43°C
#
# REGRA:
# Sempre prevalece o nível MAIS GRAVE.
# =============================================================================

classificar_protocolo <- function(
    
  temperatura_maxima,
  sensacao
  
) {
  
  temperatura_maxima <-
    numero_seguro(
      temperatura_maxima
    )
  
  sensacao <-
    numero_seguro(
      sensacao
    )
  
  # ---------------------------------------------------------------------------
  # EMERGÊNCIA
  # ---------------------------------------------------------------------------
  
  if (
    
    (!is.na(temperatura_maxima) &&
     temperatura_maxima >= 38)
    
    ||
    
    (!is.na(sensacao) &&
     sensacao >= 43)
    
  ) {
    
    return(
      
      list(
        
        nivel = "Emergência",
        
        codigo = 3,
        
        cor = CORES$vermelho,
        
        mensagem =
          "RISCO ELEVADO À SAÚDE – ACIONAR MEDIDAS DE EMERGÊNCIA"
        
      )
      
    )
    
  }
  
  
  # ---------------------------------------------------------------------------
  # ALERTA
  # ---------------------------------------------------------------------------
  
  if (
    
    (!is.na(temperatura_maxima) &&
     temperatura_maxima >= 36)
    
    ||
    
    (!is.na(sensacao) &&
     sensacao >= 40)
    
  ) {
    
    return(
      
      list(
        
        nivel = "Alerta",
        
        codigo = 2,
        
        cor = CORES$laranja,
        
        mensagem =
          "CALOR INTENSO – INTENSIFICAR A RESPOSTA EM SAÚDE"
        
      )
      
    )
    
  }
  
  
  # ---------------------------------------------------------------------------
  # ATENÇÃO
  # ---------------------------------------------------------------------------
  
  if (
    
    (!is.na(temperatura_maxima) &&
     temperatura_maxima >= 32)
    
    ||
    
    (!is.na(sensacao) &&
     sensacao >= 32)
    
  ) {
    
    return(
      
      list(
        
        nivel = "Atenção",
        
        codigo = 1,
        
        cor = CORES$amarelo,
        
        mensagem =
          "CALOR ACIMA DO PADRÃO – INTENSIFICAR O MONITORAMENTO"
        
      )
      
    )
    
  }
  
  
  # ---------------------------------------------------------------------------
  # NORMALIDADE
  # ---------------------------------------------------------------------------
  
  return(
    
    list(
      
      nivel = "Normalidade",
      
      codigo = 0,
      
      cor = CORES$verde,
      
      mensagem =
        "CONDIÇÕES DENTRO DO NÍVEL DE NORMALIDADE"
      
    )
    
  )
  
}


# =============================================================================
# 7. AÇÕES DO PROTOCOLO
# =============================================================================

acoes_por_nivel <- function(nivel) {
  
  if (nivel == "Normalidade") {
    
    return(
      
      c(
        
        "Manter monitoramento climático e epidemiológico.",
        "Realizar Vigilância Baseada em Eventos.",
        "Acompanhar temperatura, umidade e indicadores de calor.",
        "Manter linhas de base epidemiológicas atualizadas.",
        "Preparar a rede assistencial e grupos vulneráveis."
        
      )
      
    )
    
  }
  
  
  if (nivel == "Atenção") {
    
    return(
      
      c(
        
        "Intensificar o monitoramento climático e epidemiológico.",
        "Monitorar sinais de aumento de atendimentos relacionados ao calor.",
        "Acompanhar grupos vulneráveis.",
        "Intensificar comunicação preventiva e orientações de hidratação.",
        "Produzir avaliação técnica do cenário."
        
      )
      
    )
    
  }
  
  
  if (nivel == "Alerta") {
    
    return(
      
      c(
        
        "Ativar monitoramento ampliado do cenário climático e epidemiológico.",
        "Intensificar comunicação de risco.",
        "Monitorar excesso de atendimentos, internações e óbitos.",
        "Avaliar necessidade de ativação da Sala de Situação.",
        "Priorizar grupos vulneráveis.",
        "Reforçar preparação da rede assistencial."
        
      )
      
    )
    
  }
  
  
  if (nivel == "Emergência") {
    
    return(
      
      c(
        
        "Avaliar ativação do COE conforme o cenário.",
        "Monitorar ocupação de leitos e sobrecarga dos serviços.",
        "Produzir informes situacionais e boletins frequentes.",
        "Ampliar capacidade operacional quando necessário.",
        "Priorizar atendimento e proteção de grupos vulneráveis.",
        "Avaliar restrição de atividades externas não essenciais."
        
      )
      
    )
    
  }
  
  
  character(0)
  
}


# =============================================================================
# 8. CONSULTA INTEGRADA
# =============================================================================

consultar_cenario <- function() {
  
  # Consulta meteorológica
  meteo <- consultar_meteorologia()
  
  # Consulta EHF
  ehf <- consultar_ehf()
  
  # ---------------------------------------------------------------------------
  # CLASSIFICAÇÃO
  # ---------------------------------------------------------------------------
  #
  # A temperatura máxima diária do Open-Meteo é o principal valor utilizado
  # pelo protocolo operacional.
  #
  # Caso não esteja disponível, usa a temperatura atual.
  # ---------------------------------------------------------------------------
  
  temperatura_protocolo <-
    meteo$temperatura_maxima
  
  if (
    
    is.na(temperatura_protocolo) &&
    !is.na(meteo$temperatura_atual)
    
  ) {
    
    temperatura_protocolo <-
      meteo$temperatura_atual
    
  }
  
  
  classificacao <-
    classificar_protocolo(
      
      temperatura_maxima =
        temperatura_protocolo,
      
      sensacao =
        meteo$sensacao
      
    )
  
  
  list(
    
    meteo = meteo,
    
    ehf = ehf,
    
    temperatura_protocolo =
      temperatura_protocolo,
    
    classificacao =
      classificacao,
    
    consulta =
      agora_belem()
    
  )
  
}


# =============================================================================
# 9. INTERFACE
# =============================================================================

ui <- fluidPage(
  
  tags$head(
    
    tags$title(
      "Painel de Alerta de Calor – Belém"
    ),
    
    tags$meta(
      name = "viewport",
      content =
        "width=device-width, initial-scale=1"
    ),
    
    tags$style(
      
      HTML(paste0(
        
        "
        body {
          background: ", CORES$fundo, ";
          color: ", CORES$texto, ";
          font-family:
            Arial,
            Helvetica,
            sans-serif;
        }

        .container-fluid {
          max-width: 1600px;
        }

        .topo {
          background:
            linear-gradient(
              135deg,
              ", CORES$azul, " 0%,
              ", CORES$azul_claro, " 100%
            );

          color: white;

          border-radius: 18px;

          padding: 25px;

          margin-top: 15px;
          margin-bottom: 20px;

          box-shadow:
            0 8px 25px
            rgba(13,71,161,0.20);
        }

        .topo h1 {
          margin: 0;
          font-size: 30px;
          font-weight: 800;
        }

        .topo p {
          margin-top: 8px;
          margin-bottom: 0;
          opacity: 0.90;
        }

        .alerta-principal {

          color: white;

          border-radius: 20px;

          padding: 28px;

          margin-bottom: 20px;

          box-shadow:
            0 8px 25px
            rgba(0,0,0,0.15);
        }

        .titulo-alerta {

          font-size: 13px;

          font-weight: 700;

          letter-spacing: 1px;
        }

        .nivel-alerta {

          font-size: 42px;

          font-weight: 900;

          margin-top: 6px;
        }

        .mensagem-alerta {

          font-size: 16px;

          font-weight: 600;

          margin-top: 10px;
        }

        .card-indicador {

          background: white;

          border-radius: 16px;

          padding: 20px;

          min-height: 150px;

          margin-bottom: 20px;

          border:
            1px solid ", CORES$cinza_claro, ";

          box-shadow:
            0 4px 15px
            rgba(0,0,0,0.06);
        }

        .titulo-indicador {

          font-size: 12px;

          text-transform: uppercase;

          color: ", CORES$cinza, ";

          font-weight: 700;

          letter-spacing: 0.6px;
        }

        .valor-indicador {

          font-size: 31px;

          font-weight: 800;

          margin-top: 10px;

          color: ", CORES$texto, ";
        }

        .descricao-indicador {

          font-size: 12px;

          color: ", CORES$cinza, ";

          margin-top: 10px;
        }

        .secao {

          background: white;

          border-radius: 16px;

          padding: 22px;

          margin-bottom: 20px;

          border:
            1px solid ", CORES$cinza_claro, ";

          box-shadow:
            0 4px 15px
            rgba(0,0,0,0.05);
        }

        .secao h3 {

          margin-top: 0;

          color: ", CORES$azul, ";

          font-weight: 800;

          font-size: 20px;
        }

        .acao-item {

          padding: 12px 0;

          border-bottom:
            1px solid #EEF2F7;

          font-size: 15px;
        }

        .acao-item:last-child {

          border-bottom: none;
        }

        .faixa-niveis {

          display: flex;

          flex-wrap: wrap;

          gap: 10px;
        }

        .nivel-box {

          flex: 1;

          min-width: 190px;

          color: white;

          border-radius: 12px;

          padding: 16px;

          font-weight: 700;

          white-space: pre-line;
        }

        .fonte {

          color: ", CORES$cinza, ";

          font-size: 12px;
        }

        .status-ok {
          color: #2E7D32;
          font-weight: 700;
        }

        .status-erro {
          color: #C62828;
          font-weight: 700;
        }

        .btn-atualizar {

          font-weight: 700;

          border-radius: 10px;

          border: none;

          padding:
            8px 16px;
        }

        "
      ))
      
    )
    
  ),
  
  
  # ---------------------------------------------------------------------------
  # CABEÇALHO
  # ---------------------------------------------------------------------------
  
  div(
    
    class = "topo",
    
    fluidRow(
      
      column(
        
        width = 8,
        
        tags$h1(
          "PAINEL DE ALERTA DE CALOR – BELÉM/PA"
        ),
        
        tags$p(
          "CISC / CIEVS • Monitoramento climático e operacional"
        )
        
      ),
      
      column(
        
        width = 4,
        
        style = "text-align:right;",
        
        tags$div(
          style =
            "font-size:13px; margin-top:8px;",
          "Atualização automática a cada 60 minutos"
        ),
        
        actionButton(
          
          inputId = "atualizar",
          
          label = "↻ Atualizar agora",
          
          class =
            "btn-light btn-sm btn-atualizar"
          
        )
        
      )
      
    )
    
  ),
  
  
  # ---------------------------------------------------------------------------
  # ALERTA PRINCIPAL
  # ---------------------------------------------------------------------------
  
  uiOutput(
    "alerta_principal"
  ),
  
  
  # ---------------------------------------------------------------------------
  # INDICADORES
  # ---------------------------------------------------------------------------
  
  fluidRow(
    
    column(
      width = 3,
      uiOutput("card_temp_max")
    ),
    
    column(
      width = 3,
      uiOutput("card_temp_atual")
    ),
    
    column(
      width = 3,
      uiOutput("card_sensacao")
    ),
    
    column(
      width = 3,
      uiOutput("card_umidade")
    )
    
  ),
  
  
  fluidRow(
    
    column(
      width = 6,
      uiOutput("card_ehf")
    ),
    
    column(
      width = 6,
      uiOutput("card_risco")
    )
    
  ),
  
  
  # ---------------------------------------------------------------------------
  # NÍVEIS
  # ---------------------------------------------------------------------------
  
  div(
    
    class = "secao",
    
    tags$h3(
      "Níveis do Protocolo de Calor"
    ),
    
    div(
      
      class = "faixa-niveis",
      
      div(
        
        class = "nivel-box",
        
        style =
          paste0(
            "background:",
            CORES$verde,
            ";"
          ),
        
        "VERDE\nNORMALIDADE\nTemperatura < 32°C"
        
      ),
      
      div(
        
        class = "nivel-box",
        
        style =
          paste0(
            "background:",
            CORES$amarelo,
            "; color:#3D2B00;"
          ),
        
        "AMARELO\nATENÇÃO\nTemperatura ≥ 32°C\nou sensação ≥ 32°C"
        
      ),
      
      div(
        
        class = "nivel-box",
        
        style =
          paste0(
            "background:",
            CORES$laranja,
            ";"
          ),
        
        "LARANJA\nALERTA\nTemperatura ≥ 36°C\nou sensação ≥ 40°C"
        
      ),
      
      div(
        
        class = "nivel-box",
        
        style =
          paste0(
            "background:",
            CORES$vermelho,
            ";"
          ),
        
        "VERMELHO\nEMERGÊNCIA\nTemperatura ≥ 38°C\nou sensação ≥ 43°C"
        
      )
      
    )
    
  ),
  
  
  # ---------------------------------------------------------------------------
  # AÇÕES E MUDANÇA DE NÍVEL
  # ---------------------------------------------------------------------------
  
  fluidRow(
    
    column(
      
      width = 7,
      
      div(
        
        class = "secao",
        
        tags$h3(
          "Ações prioritárias do protocolo"
        ),
        
        uiOutput("acoes")
        
      )
      
    ),
    
    
    column(
      
      width = 5,
      
      div(
        
        class = "secao",
        
        tags$h3(
          "Gatilho de mudança de nível"
        ),
        
        uiOutput("mudanca_nivel")
        
      )
      
    )
    
  ),
  
  
  # ---------------------------------------------------------------------------
  # STATUS DAS FONTES
  # ---------------------------------------------------------------------------
  
  div(
    
    class = "secao",
    
    tags$h3(
      "Status das consultas"
    ),
    
    uiOutput(
      "status_fontes"
    )
    
  ),
  
  
  tags$div(
    
    class = "fonte",
    
    tags$hr(),
    
    HTML(
      paste0(
        
        "<b>Fonte contextual:</b> ",
        
        "Painel de Excesso de Calor do Ministério da Saúde. ",
        
        "<br>",
        
        "<b>Fonte meteorológica:</b> ",
        
        "Open-Meteo. ",
        
        "<br>",
        
        "A classificação operacional é calculada automaticamente ",
        
        "conforme os gatilhos definidos no protocolo."
        
      )
      
    )
    
  )
  
)


# =============================================================================
# 10. SERVIDOR
# =============================================================================

server <- function(
    
  input,
  output,
  session
  
) {
  
  
  # ---------------------------------------------------------------------------
  # OBJETOS REATIVOS
  # ---------------------------------------------------------------------------
  
  valores <- reactiveValues(
    
    cenario = NULL,
    
    nivel_anterior = NULL,
    
    ultima_mudanca = NULL,
    
    historico = data.frame(
      
      data_hora = character(),
      
      nivel = character(),
      
      temperatura_maxima = numeric(),
      
      temperatura_atual = numeric(),
      
      sensacao = numeric(),
      
      stringsAsFactors = FALSE
      
    )
    
  )
  
  
  # ---------------------------------------------------------------------------
  # FUNÇÃO DE ATUALIZAÇÃO
  # ---------------------------------------------------------------------------
  
  atualizar_dados <- function(
    
    origem = "automática"
    
  ) {
    
    novo_cenario <- consultar_cenario()
    
    novo_nivel <-
      novo_cenario$classificacao$nivel
    
    nivel_anterior <-
      valores$nivel_anterior
    
    
    # -------------------------------------------------------------------------
    # DETECÇÃO DE MUDANÇA DE NÍVEL
    # -------------------------------------------------------------------------
    
    if (
      
      !is.null(nivel_anterior) &&
      
      !identical(
        nivel_anterior,
        novo_nivel
      )
      
    ) {
      
      codigo_anterior <-
        ORDEM_NIVEL[
          [nivel_anterior]
        ]
      
      codigo_novo <-
        ORDEM_NIVEL[
          [novo_nivel]
        ]
      
      
      if (
        
        !is.na(codigo_novo) &&
        
        !is.na(codigo_anterior) &&
        
        codigo_novo > codigo_anterior
        
      ) {
        
        direcao <- "ELEVAÇÃO"
        
        tipo_notificacao <- "warning"
        
      } else {
        
        direcao <- "REDUÇÃO"
        
        tipo_notificacao <- "message"
        
      }
      
      
      mensagem_mudanca <-
        
        paste0(
          
          "MUDANÇA DE NÍVEL: ",
          
          nivel_anterior,
          
          " → ",
          
          novo_nivel,
          
          " (",
          
          direcao,
          
          ")"
          
        )
      
      
      valores$ultima_mudanca <-
        
        list(
          
          anterior =
            nivel_anterior,
          
          atual =
            novo_nivel,
          
          direcao =
            direcao,
          
          data_hora =
            agora_belem()
          
        )
      
      
      showNotification(
        
        mensagem_mudanca,
        
        type =
          tipo_notificacao,
        
        duration =
          15
        
      )
      
    }
    
    
    # -------------------------------------------------------------------------
    # REGISTRO NO HISTÓRICO
    # -------------------------------------------------------------------------
    
    novo_registro <-
      
      data.frame(
        
        data_hora =
          novo_cenario$consulta,
        
        nivel =
          novo_nivel,
        
        temperatura_maxima =
          novo_cenario$temperatura_protocolo,
        
        temperatura_atual =
          novo_cenario$meteo$temperatura_atual,
        
        sensacao =
          novo_cenario$meteo$sensacao,
        
        stringsAsFactors =
          FALSE
        
      )
    
    
    valores$historico <-
      
      rbind(
        
        valores$historico,
        
        novo_registro
        
      )
    
    
    # Mantém no máximo 500 registros
    
    if (
      
      nrow(valores$historico) > 500
      
    ) {
      
      valores$historico <-
        
        tail(
          
          valores$historico,
          
          500
          
        )
      
    }
    
    
    # -------------------------------------------------------------------------
    # ATUALIZA ESTADO
    # -------------------------------------------------------------------------
    
    valores$cenario <-
      novo_cenario
    
    valores$nivel_anterior <-
      novo_nivel
    
  }
  
  
  # ---------------------------------------------------------------------------
  # ATUALIZAÇÃO AUTOMÁTICA
  # ---------------------------------------------------------------------------
  #
  # invalidateLater executa:
  #
  # 1. imediatamente quando o aplicativo abre;
  # 2. novamente após 60 minutos;
  # 3. continuamente enquanto a sessão estiver aberta.
  # ---------------------------------------------------------------------------
  
  observe({
    
    invalidateLater(
      
      millis = INTERVALO_MS,
      
      session = session
      
    )
    
    atualizar_dados(
      "automática"
    )
    
  })
  
  
  # ---------------------------------------------------------------------------
  # ATUALIZAÇÃO MANUAL
  # ---------------------------------------------------------------------------
  
  observeEvent(
    
    input$atualizar,
    
    {
      
      atualizar_dados(
        "manual"
      )
      
    }
    
  )
  
  
  # ===========================================================================
  # 11. ELEMENTOS DA INTERFACE
  # ===========================================================================
  
  
  # ---------------------------------------------------------------------------
  # ALERTA PRINCIPAL
  # ---------------------------------------------------------------------------
  
  output$alerta_principal <-
    
    renderUI({
      
      req(
        valores$cenario
      )
      
      
      x <-
        valores$cenario
      
      
      cl <-
        x$classificacao
      
      
      div(
        
        class =
          "alerta-principal",
        
        style =
          paste0(
            
            "background:",
            cl$cor,
            ";"
            
          ),
        
        
        fluidRow(
          
          column(
            
            width = 8,
            
            
            div(
              
              class =
                "titulo-alerta",
              
              "NÍVEL ATUAL DO PROTOCOLO"
              
            ),
            
            
            div(
              
              class =
                "nivel-alerta",
              
              cl$nivel
              
            ),
            
            
            div(
              
              class =
                "mensagem-alerta",
              
              cl$mensagem
              
            )
            
          ),
          
          
          column(
            
            width = 4,
            
            style =
              "text-align:right;",
            
            
            tags$div(
              
              style =
                "font-size:12px;",
              
              "Última consulta"
              
            ),
            
            
            tags$div(
              
              style =
                "font-size:16px; font-weight:700;",
              
              x$consulta
              
            )
            
          )
          
        ),
        
        
        tags$hr(
          
          
          style =
            "border-color:rgba(255,255,255,0.35);"
          
          
        ),
        
        
        tags$div(
          
          paste0(
            
            "Temperatura máxima utilizada: ",
            
            formatar_numero(
              
              x$temperatura_protocolo,
              
              1,
              
              "°C"
              
            ),
            
            " | Sensação térmica atual: ",
            
            formatar_numero(
              
              x$meteo$sensacao,
              
              1,
              
              "°C"
              
            )
            
          )
          
        )
        
      )
      
    })
  
  
  # ---------------------------------------------------------------------------
  # CARD: TEMPERATURA MÁXIMA
  # ---------------------------------------------------------------------------
  
  output$card_temp_max <-
    
    renderUI({
      
      req(
        valores$cenario
      )
      
      
      x <-
        valores$cenario
      
      
      div(
        
        class =
          "card-indicador",
        
        div(
          
          class =
            "titulo-indicador",
          
          "Temperatura máxima"
          
        ),
        
        div(
          
          class =
            "valor-indicador",
          
          formatar_numero(
            
            x$temperatura_protocolo,
            
            1,
            
            "°C"
            
          )
          
        ),
        
        div(
          
          class =
            "descricao-indicador",
          
          "Valor utilizado pelo protocolo"
          
        )
        
      )
      
    })
  
  
  # ---------------------------------------------------------------------------
  # CARD: TEMPERATURA ATUAL
  # ---------------------------------------------------------------------------
  
  output$card_temp_atual <-
    
    renderUI({
      
      req(
        valores$cenario
      )
      
      
      x <-
        valores$cenario
      
      
      div(
        
        class =
          "card-indicador",
        
        div(
          
          class =
            "titulo-indicador",
          
          "Temperatura atual"
          
        ),
        
        div(
          
          class =
            "valor-indicador",
          
          formatar_numero(
            
            x$meteo$temperatura_atual,
            
            1,
            
            "°C"
            
          )
          
        ),
        
        div(
          
          class =
            "descricao-indicador",
          
          "Condição atual"
          
        )
        
      )
      
    })
  
  
  # ---------------------------------------------------------------------------
  # CARD: SENSAÇÃO TÉRMICA
  # ---------------------------------------------------------------------------
  
  output$card_sensacao <-
    
    renderUI({
      
      req(
        valores$cenario
      )
      
      
      x <-
        valores$cenario
      
      
      div(
        
        class =
          "card-indicador",
        
        div(
          
          class =
            "titulo-indicador",
          
          "Sensação térmica"
          
        ),
        
        div(
          
          class =
            "valor-indicador",
          
          formatar_numero(
            
            x$meteo$sensacao,
            
            1,
            
            "°C"
            
          )
          
        ),
        
        div(
          
          class =
            "descricao-indicador",
          
          "Temperatura aparente atual"
          
        )
        
      )
      
    })
  
  
  # ---------------------------------------------------------------------------
  # CARD: UMIDADE
  # ---------------------------------------------------------------------------
  
  output$card_umidade <-
    
    renderUI({
      
      req(
        valores$cenario
      )
      
      
      x <-
        valores$cenario
      
      
      div(
        
        class =
          "card-indicador",
        
        div(
          
          class =
            "titulo-indicador",
          
          "Umidade relativa"
          
        ),
        
        div(
          
          class =
            "valor-indicador",
          
          formatar_numero(
            
            x$meteo$umidade,
            
            0,
            
            "%"
            
          )
          
        ),
        
        div(
          
          class =
            "descricao-indicador",
          
          "Condição atual"
          
        )
        
      )
      
    })
  
  
  # ---------------------------------------------------------------------------
  # CARD: EHF
  # ---------------------------------------------------------------------------
  
  output$card_ehf <-
    
    renderUI({
      
      req(
        valores$cenario
      )
      
      
      x <-
        valores$cenario
      
      
      valor <-
        x$ehf$ehf
      
      
      if (
        
        is.null(valor) ||
        
        is.na(valor) ||
        
        !nzchar(valor)
        
      ) {
        
        valor <-
          "Indisponível na leitura automática"
        
      }
      
      
      div(
        
        class =
          "card-indicador",
        
        div(
          
          class =
            "titulo-indicador",
          
          "Excesso de Calor – EHF"
          
        ),
        
        div(
          
          class =
            "valor-indicador",
          
          escape_html_seguro(
            valor
          )
          
        ),
        
        div(
          
          class =
            "descricao-indicador",
          
          "Indicador contextual do Painel do Ministério da Saúde"
          
        )
        
      )
      
    })
  
  
  # ---------------------------------------------------------------------------
  # CARD: RISCO EHF
  # ---------------------------------------------------------------------------
  
  output$card_risco <-
    
    renderUI({
      
      req(
        valores$cenario
      )
      
      
      x <-
        valores$cenario
      
      
      valor <-
        x$ehf$risco
      
      
      if (
        
        is.null(valor) ||
        
        is.na(valor) ||
        
        !nzchar(valor)
        
      ) {
        
        valor <-
          "Indisponível na leitura automática"
        
      }
      
      
      div(
        
        class =
          "card-indicador",
        
        div(
          
          class =
            "titulo-indicador",
          
          "Risco – Painel EHF"
          
        ),
        
        div(
          
          class =
            "valor-indicador",
          
          escape_html_seguro(
            valor
          )
          
        ),
        
        div(
          
          class =
            "descricao-indicador",
          
          "Classificação apresentada pela fonte oficial"
          
        )
        
      )
      
    })
  
  
  # ---------------------------------------------------------------------------
  # AÇÕES
  # ---------------------------------------------------------------------------
  
  output$acoes <-
    
    renderUI({
      
      req(
        valores$cenario
      )
      
      
      nivel <-
        
        valores$cenario$classificacao$nivel
      
      
      lista_acoes <-
        
        acoes_por_nivel(
          nivel
        )
      
      
      tagList(
        
        tags$p(
          
          tags$b(
            paste(
              "Nível atual:",
              nivel
            )
          )
          
        ),
        
        
        lapply(
          
          lista_acoes,
          
          function(acao) {
            
            div(
              
              class =
                "acao-item",
              
              HTML(
                
                paste0(
                  
                  "✓ ",
                  
                  escape_html_seguro(
                    acao
                  )
                  
                )
                
              )
              
            )
            
          }
          
        )
        
      )
      
    })
  
  
  # ---------------------------------------------------------------------------
  # MUDANÇA DE NÍVEL
  # ---------------------------------------------------------------------------
  
  output$mudanca_nivel <-
    
    renderUI({
      
      req(
        valores$cenario
      )
      
      
      mudanca <-
        
        valores$ultima_mudanca
      
      
      if (
        
        is.null(mudanca)
        
      ) {
        
        return(
          
          tags$div(
            
            tags$p(
              
              tags$b(
                "Monitoramento ativo"
              )
              
            ),
            
            tags$p(
              
              "O sistema compara automaticamente cada nova consulta ",
              
              "com o nível anterior."
              
            ),
            
            tags$p(
              
              "Quando houver mudança de nível, será exibido um alerta."
              
            )
            
          )
          
        )
        
      }
      
      
      cor_direcao <-
        
        if (
          
          mudanca$direcao == "ELEVAÇÃO"
          
        ) {
          
          CORES$vermelho
          
        } else {
          
          CORES$verde
          
        }
      
      
      div(
        
        style =
          
          paste0(
            
            "border-left:6px solid ",
            
            cor_direcao,
            
            "; padding-left:15px;"
            
          ),
        
        
        tags$p(
          
          tags$b(
            
            "Última mudança detectada"
            
          )
          
        ),
        
        
        tags$p(
          
          paste0(
            
            mudanca$anterior,
            
            " → ",
            
            mudanca$atual
            
          )
          
        ),
        
        
        tags$p(
          
          paste0(
            
            "Direção: ",
            
            mudanca$direcao
            
          )
          
        ),
        
        
        tags$p(
          
          paste0(
            
            "Data/hora: ",
            
            mudanca$data_hora
            
          )
          
        )
        
      )
      
    })
  
  
  # ---------------------------------------------------------------------------
  # STATUS DAS FONTES
  # ---------------------------------------------------------------------------
  
  output$status_fontes <-
    
    renderUI({
      
      req(
        valores$cenario
      )
      
      
      x <-
        valores$cenario
      
      
      status_meteo <-
        
        if (
          
          identical(
            x$meteo$status,
            "OK"
          )
          
        ) {
          
          tags$span(
            
            class =
              "status-ok",
            
            "✓ Consulta realizada com sucesso"
            
          )
          
        } else {
          
          tags$span(
            
            class =
              "status-erro",
            
            "⚠ Falha na consulta: ",
            
            x$meteo$mensagem
            
          )
          
        }
      
      
      status_ehf <-
        
        if (
          
          identical(
            x$ehf$status,
            "OK"
          )
          
        ) {
          
          tags$span(
            
            class =
              "status-ok",
            
            "✓ Consulta realizada"
            
          )
          
        } else {
          
          tags$span(
            
            class =
              "status-erro",
            
            "⚠ Falha na consulta: ",
            
            x$ehf$mensagem
            
          )
          
        }
      
      
      tagList(
        
        tags$p(
          
          tags$b(
            
            "Meteorologia (Open-Meteo): "
            
          ),
          
          status_meteo
          
        ),
        
        
        tags$p(
          
          tags$b(
            
            "Painel EHF – Ministério da Saúde: "
            
          ),
          
          status_ehf
          
        ),
        
        
        tags$p(
          
          tags$a(
            
            href =
              URL_EHF,
            
            target =
              "_blank",
            
            "Abrir o Painel de Excesso de Calor – Belém"
            
          )
          
        ),
        
        
        if (
          
          !is.na(
            x$meteo$horario_dado
          )
          
        ) {
          
          tags$p(
            
            class =
              "fonte",
            
            paste(
              
              "Horário do dado meteorológico:",
              
              x$meteo$horario_dado
              
            )
            
          )
          
        }
        
      )
      
    })
  
  
  # ---------------------------------------------------------------------------
  # ENCERRAMENTO DA SESSÃO
  # ---------------------------------------------------------------------------
  
  session$onSessionEnded(
    
    function() {
      
      message(
        
        "Sessão do Painel de Alerta de Calor encerrada."
        
      )
      
    }
    
  )
  
}


# =============================================================================
# 12. INICIALIZAÇÃO DO APLICATIVO
# =============================================================================

shinyApp(
  
  ui = ui,
  
  server = server
  
)
