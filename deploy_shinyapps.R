# ==============================================================================
# SCRIPT DE IMPLANTAÇÃO AUTOMATIZADA NO SHINYAPPS.IO
# Painel Oficial de Vigilância de Excesso de Calor - CIEVS Belém / SESMA
# ==============================================================================

# 1. Instalar rsconnect se necessário
if (!requireNamespace("rsconnect", quietly = TRUE)) {
  install.packages("rsconnect", repos = "https://cloud.r-project.org")
}
library(rsconnect)

# 2. Configurar credenciais do Shinyapps.io
# Obtenha estas informações em: https://www.shinyapps.io/admin/#/tokens
# Substitua os valores abaixo com as credenciais da sua conta:

# rsconnect::setAccountInfo(
#   name   = "<SEU_NOME_DE_CONTA>",
#   token  = "<SEU_TOKEN>",
#   secret = "<SEU_SECRET>"
# )

# 3. Publicar aplicação
message("Iniciando publicação no shinyapps.io...")

rsconnect::deployApp(
  appDir = getwd(),
  appName = "painel-calor-cievs-belem",
  appTitle = "Painel de Calor - CIEVS Belém",
  appFiles = c(
    "app.R",
    "dados_clima_atual.json",
    "destinatarios.json",
    "historico_ehf.csv"
  ),
  forceUpdate = TRUE
)

message("Publicação concluída! Verifique o link gerado pelo rsconnect.")
