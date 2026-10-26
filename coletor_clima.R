# ==============================================================================
# COLETOR AUTOMATIZADO DE DADOS CLIMÁTICOS (CRONJOB) - BELÉM / PA
# Fonte Oficial: Ministério da Saúde (https://clima.saude.gov.br)
# Uso: Rscript coletor_clima.R
# ==============================================================================

suppressPackageStartupMessages({
  library(httr)
  library(jsonlite)
})

meses_pt <- c("jan.", "fev.", "mar.", "abr.", "mai.", "jun.", 
              "jul.", "ago.", "set.", "out.", "nov.", "dez.")

formatar_dia_br <- function(dt) {
  tryCatch({
    p <- as.POSIXlt(dt)
    paste0(p$mday, " de ", meses_pt[p$mon + 1])
  }, error = function(e) format(as.Date(dt), "%d/%m"))
}

mapear_classe <- function(cls) {
  if (is.null(cls) || is.na(cls)) return("Sem excesso")
  c_lower <- tolower(trimws(cls))
  if (grepl("normal|sem|nenhum", c_lower)) return("Sem excesso")
  if (grepl("baixo|moderado|atencao|atenção", c_lower)) return("Baixo")
  if (grepl("severo|alerta|laranja", c_lower)) return("Severo")
  if (grepl("extremo|emergencia|emergência|vermelho", c_lower)) return("Extremo")
  return("Sem excesso")
}

executar_coleta <- function() {
  hoje <- Sys.Date()
  tryCatch({
    hoje <- as.Date(format(Sys.time(), tz = "America/Belem"))
  }, error = function(e) {})
  
  data_alvo <- format(hoje + 4, "%Y-%m-%d")
  url_oficial <- paste0("https://clima.saude.gov.br/pa/belem?data=", data_alvo, "&modo=ehf")
  
  cat(sprintf("[%s] Iniciando coleta de: %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), url_oficial))
  
  resp <- httr::GET(
    url_oficial,
    httr::timeout(15),
    httr::user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
  )
  
  if (httr::status_code(resp) != 200) {
    stop(sprintf("Erro HTTP %d ao consultar o Ministério da Saúde.", httr::status_code(resp)))
  }
  
  html_txt <- httr::content(resp, as = "text", encoding = "UTF-8")
  padrao <- '\\{[^{}]*cd_mun:"1501402"[^{}]*\\}'
  matches <- regmatches(html_txt, gregexpr(padrao, html_txt))[[1]]
  
  if (length(matches) == 0) {
    stop("Nenhum registro para Belém (1501402) localizado na página retornada.")
  }
  
  cat(sprintf("Registros brutos encontrados: %d\n", length(matches)))
  
  dados_por_data <- list()
  for (m in matches) {
    d_m <- regmatches(m, regexec('data:"([^"]+)"', m))[[1]]
    if (length(d_m) > 1) {
      dt_str <- d_m[2]
      tmax_m <- regmatches(m, regexec('tmax:([0-9.]+)', m))[[1]]
      tmin_m <- regmatches(m, regexec('tmin:([0-9.]+)', m))[[1]]
      ehf_m  <- regmatches(m, regexec('ehf:([0-9.-]+)', m))[[1]]
      cls_m  <- regmatches(m, regexec('classification:"([^"]+)"', m))[[1]]
      
      tmax_val <- if (length(tmax_m) > 1) round(as.numeric(tmax_m[2]), 1) else 34.0
      tmin_val <- if (length(tmin_m) > 1) round(as.numeric(tmin_m[2]), 1) else 23.0
      ehf_val  <- if (length(ehf_m) > 1) round(as.numeric(ehf_m[2]), 2) else 0.0
      cls_val  <- if (length(cls_m) > 1) mapear_classe(cls_m[2]) else "Sem excesso"
      
      dados_por_data[[dt_str]] <- list(
        data_iso = dt_str,
        tmax     = tmax_val,
        tmin     = tmin_val,
        ehf      = ehf_val,
        classe   = cls_val
      )
    }
  }
  
  dias_desejados <- as.character(hoje + 0:4)
  previsoes <- list()
  
  mapa_desc <- list(
    "Sem excesso" = list(titulo = "NÍVEL DE CALOR 1: NORMALIDADE", subtitulo = "CLASSIFICAÇÃO DO EHF: SEM EXCESSO DE CALOR"),
    "Baixo"       = list(titulo = "NÍVEL DE CALOR 2: ATENÇÃO", subtitulo = "CLASSIFICAÇÃO DO EHF: BAIXO"),
    "Severo"      = list(titulo = "NÍVEL DE CALOR 3: ALERTA", subtitulo = "CLASSIFICAÇÃO DO EHF: SEVERO"),
    "Extremo"     = list(titulo = "NÍVEL DE CALOR 4: EMERGÊNCIA", subtitulo = "CLASSIFICAÇÃO DO EHF: EXTREMO")
  )
  
  for (d_iso in dias_desejados) {
    item <- dados_por_data[[d_iso]]
    dt_obj <- as.Date(d_iso)
    cls <- if (!is.null(item)) item$classe else "Sem excesso"
    info_d <- if (!is.null(mapa_desc[[cls]])) mapa_desc[[cls]] else mapa_desc[["Sem excesso"]]

    if (!is.null(item)) {
      prev_item <- list(
        dia           = formatar_dia_br(dt_obj),
        data_br       = format(dt_obj, "%d/%m/%Y"),
        classe        = item$classe,
        ehf           = item$ehf,
        tmin          = item$tmin,
        tmax          = item$tmax,
        titulo_nivel  = info_d$titulo,
        subtitulo_ehf = info_d$subtitulo
      )
    } else {
      prev_item <- list(
        dia           = formatar_dia_br(dt_obj),
        data_br       = format(dt_obj, "%d/%m/%Y"),
        classe        = "Sem excesso",
        ehf           = 0.0,
        tmin          = 23.0,
        tmax          = 34.0,
        titulo_nivel  = info_d$titulo,
        subtitulo_ehf = info_d$subtitulo
      )
    }
    previsoes[[length(previsoes) + 1]] <- prev_item
  }
  
  info_hoje <- if (!is.null(mapa_desc[[previsoes[[1]]$classe]])) mapa_desc[[previsoes[[1]]$classe]] else mapa_desc[["Sem excesso"]]

  payload <- list(
    municipio     = "Belém - PA",
    sucesso       = TRUE,
    hora_consulta = format(Sys.time(), "%H:%M:%S"),
    titulo_nivel  = info_hoje$titulo,
    subtitulo_ehf = info_hoje$subtitulo,
    previsoes     = previsoes,
    hoje          = previsoes[[1]],
    data_base_iso = format(hoje, "%Y-%m-%d"),
    fonte_url     = url_oficial,
    data_base_br  = format(hoje, "%d/%m/%Y")
  )
  
  jsonlite::write_json(payload, "dados_clima_atual.json", auto_unbox = TRUE, pretty = TRUE)
  cat("Arquivo salvo com sucesso: dados_clima_atual.json\n")
  
  # Atualizar historico CSV
  csv_file <- "historico_ehf.csv"
  linha <- sprintf("%s,%s,%.1f,%.1f,%.2f,%s\n",
                   payload$data_base_iso,
                   payload$hora_consulta,
                   payload$hoje$tmax,
                   payload$hoje$tmin,
                   payload$hoje$ehf,
                   payload$hoje$classe)
  
  if (!file.exists(csv_file)) {
    cat("data_iso,hora_consulta,tmax,tmin,ehf,classe\n", file = csv_file)
  }
  cat(linha, file = csv_file, append = TRUE)
  cat("Histórico salvo em: historico_ehf.csv\n")
  
  cat(sprintf("\n=== STATUS COLETADO: %s ===\n", toupper(payload$hoje$classe)))
  cat(sprintf("Hoje (%s): Tmax %.1f°C | EHF: %.2f | Nível: %s\n", 
              payload$data_base_br, payload$hoje$tmax, payload$hoje$ehf, payload$hoje$classe))
  
  return(invisible(payload))
}

# Executa se chamado como script principal
if (!interactive()) {
  tryCatch({
    executar_coleta()
  }, error = function(e) {
    message("Falha na execução do coletor: ", e$message)
    quit(status = 1)
  })
}
