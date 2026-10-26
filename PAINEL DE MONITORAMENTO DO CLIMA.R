# ==============================================================================
# PAINEL OFICIAL DE VIGILÂNCIA DE EXCESSO DE CALOR - CIEVS BELÉM / SESMA
# Versão Otimizada para Publicação no Shinyapps.io com Coleta Automática (CRON/API)
# Ministério da Saúde · Plano de Contingência Local de Belém (2026)
# Fonte Oficial de Dados: https://clima.saude.gov.br/pa/belem?modo=ehf
# ==============================================================================

# 1. CARREGAMENTO DE PACOTES
# Nota: No shinyapps.io os pacotes são provisionados pelo rsconnect antes do deploy.
suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(bsicons)
  library(httr)
  library(rvest)
  library(jsonlite)
  library(blastula)
  library(glue)
  library(lubridate)
  library(DT)
})

# Compatibilidade de caminhos estáticos para Shinyapps.io e execução local
if (!dir.exists("www")) {
  dir.create("www", showWarnings = FALSE)
}
addResourcePath("imagens_locais", getwd())

# ==============================================================================
# 2. DEFINIÇÕES: AÇÕES REORGANIZADAS EM 6 QUADROS SIMÉTRICOS
# ==============================================================================
matriz_niveis <- list(
  "Sem excesso" = list(
    classe = "Sem excesso",
    titulo_nivel = "NÍVEL DE CALOR 1: NORMALIDADE",
    subtitulo_ehf = "CLASSIFICAÇÃO DO EHF: SEM EXCESSO DE CALOR",
    rotulo_curto = "NÍVEL 1: NORMALIDADE",
    cor_alerta = "#1b5e20",
    cor_texto = "#ffffff",
    icone = "check-circle-fill",
    status_ms = "CLASSIFICAÇÃO DO EHF: SEM EXCESSO DE CALOR",
    nivel_contingencia = "NÍVEL DE CALOR 1: NORMALIDADE",
    populacao = "Rotina, sem cuidado extra.",
    servico_saude = "Vigilância de rotina, com a rede em prontidão.",
    acoes_setores = list(
      cievs_ve = list(
        "CIEVS: Manter Vigilância Baseada em Eventos (VBE) para identificação precoce de rumores relacionados ao calor extremo.",
        "CIEVS: Avaliar sinais de aumento incomum de atendimentos.",
        "CIEVS: Desenvolver formulário de notificação ou variável que indique adoecimento pelo aumento de temperatura.",
        "Vigilância Epidemiológica: Capacitar profissionais de saúde, especialmente os que trabalham nos territórios sobre alerta e enfrentamento ao El Niño.",
        "Vigilância Epidemiológica: Elaborar e divulgar materiais instrutivos para população sobre medidas de prevenção para minimizar adoecimentos relacionados a ondas de calor.",
        "Vigilância Epidemiológica: Elaboração e divulgação de materiais instrutivos aos profissionais dos serviços de saúde quanto aos registros de informações necessárias a facilitação da identificação dos atendimentos relacionados ao calor.",
        "Vigilância Epidemiológica: Elaboração do plano de contingência em conjunto com CIEVS para eventos climáticos extremos de maneira colaborativa com outros setores.",
        "Vigilância Epidemiológica: Reuniões intersetoriais sempre que necessário para planejamento, monitoramento, avaliação e resposta aos eventos climáticos.",
        "Vigilância Epidemiológica: Monitorar doenças sensíveis aos eventos climáticos.",
        "Vigilância Epidemiológica: Qualificar notificações e acompanhar indicadores epidemiológicos.",
        "NHE: Realizar busca ativa em prontuários eletrônicos e presencial de atendimentos relacionados à exposição de calor extremo.",
        "NHE: Divulgar a notificação de exposição ao calor extremo e capacitar as equipes no preenchimento e fluxos de comunicação.",
        "NHE: Apoiar na elaboração de protocolos de atendimento, fluxos internos e possíveis contingenciamentos diante de excesso de demanda de atendimentos."
      ),
      controle_endemias = list(
        "Visita Domiciliar: Inspeção de imóveis para identificação de criadouros do Aedes aegypti. Orientação aos moradores sobre prevenção e eliminação de focos.",
        "Instalação e Manutenção de Estações Disseminadoras de Larvicidas (EDLs).",
        "Monitoramento Entomológico: Bloqueio de Transmissão.",
        "Controle Químico.",
        "Inspeção de Pontos Estratégicos (PE).",
        "Inspeção de Imóveis Especiais (IE).",
        "Educação em Saúde.",
        "Registro e Monitoramento das Atividades."
      ),
      vig_sanitaria_ambiental = list(
        "Vigilância Sanitária: Elaborar e manter atualizado o Plano Operacional de atuação da Vigilância Sanitária para eventos de calor extremo.",
        "Vigilância Sanitária: Mapear e manter cadastro atualizado dos estabelecimentos prioritários para fiscalização, incluindo serviços de saúde, instituições de longa permanência para idosos, serviços de alimentação, estabelecimentos de ensino, eventos de massa e demais locais de interesse sanitário.",
        "Vigilância Sanitária: Capacitar as equipes para atuação em situações de calor extremo e atualizar os protocolos de inspeção sanitária.",
        "Vigilância Sanitária: Desenvolver ações educativas e orientações técnicas aos estabelecimentos sujeitos à Vigilância Sanitária quanto às medidas de prevenção dos riscos relacionados ao calor.",
        "Vigilância Sanitária: Integrar-se ao CIEVS e demais áreas da Vigilância em Saúde para monitoramento do cenário epidemiológico e climático.",
        "Vigilância Ambiental: Classificar o monitoramento da qualidade da água, qualidade do ar, queimadas e vetores.",
        "Vigilância Ambiental: Monitorar áreas com risco de desabastecimento de água.",
        "Vigilância Ambiental: Apoiar ações de prevenção e controle ambiental."
      ),
      trabalhador = list(
        "Realizar ações de educação em saúde com os grupos de trabalhadores vulneráveis voltadas à prevenção do impacto do calor nos trabalhadores.",
        "Articular com empregadores/serviços privados e públicos a distribuição de EPIs para os grupos de trabalhadores vulneráveis (trabalhadores ao ar livre e trabalhadores expostos a fontes de calor).",
        "Capacitar empregadores/serviços públicos e privados e estabelecimentos de saúde a preencher as fichas de notificação do SINAN relacionadas ao trabalho de trabalhadores que tenham sofrido impactos na saúde devido ao calor.",
        "Capacitar os grupos de trabalhadores vulneráveis sobre os sinais e sintomas da exposição ao calor excessivo.",
        "Articular com empregadores/serviços públicos e privados o ajuste da carga horária de grupos de trabalhadores vulneráveis nos Níveis de alerta 1, 2 e 3.",
        "Articular um fluxograma de envio de fichas de notificação do SINAN.",
        "Criar canal de denúncia para trabalhadores que observarem serviços públicos e privados que não cumpram as recomendações de prevenção ao calor dos níveis 1, 2 e 3."
      ),
      atencao_saude_unificada = list(
        "DAS: Avaliar a capacidade operacional da rede de atenção em saúde.",
        "DAS: Monitorar a disponibilidade de profissionais, medicamentos, insumos e equipamentos.",
        "DAS: Reforçar a comunicação entre os pontos da rede assistencial.",
        "APS: Realizar ações educativas nas unidades de saúde e no território.",
        "APS: Realizar busca ativa e acompanhamento dos grupos vulneráveis.",
        "APS: Orientar usuários quanto a hidratação, alimentação, proteção contra o calor e reconhecimento precoce dos sinais de gravidade.",
        "DAES: Mapear a capacidade de climatização das salas de acolhimento e retaguarda de usuários crônicos e especializados.",
        "SAMU: Revisar protocolos assistenciais e verificar equipamentos e insumos."
      ),
      regulacao_comunicacao = list(
        "Central de Leitos: Monitorar diariamente a disponibilidade de leitos e serviços especializados.",
        "Central de Leitos: Revisar fluxos de encaminhamento conforme necessidade.",
        "Central de Leitos: Mapear a capacidade de climatização das enfermarias e UTIs da rede contratualizada para identificar pontos críticos de suporte térmico.",
        "Central de Leitos: Manter Censo hospitalar diário atualizado; Relatório de conformidade de climatização hospitalar.",
        "ASCOM: Combater informações falsas por meio da comunicação de risco.",
        "ASCOM: Orientar a população sobre medidas de prevenção em canais de atendimento."
      )
    )
  ),
  
  "Baixo" = list(
    classe = "Baixo",
    titulo_nivel = "NÍVEL DE CALOR 2: ATENÇÃO",
    subtitulo_ehf = "CLASSIFICAÇÃO DO EHF: BAIXO",
    rotulo_curto = "NÍVEL 2: ATENÇÃO",
    cor_alerta = "#ca8a04",
    cor_texto = "#ffffff",
    icone = "exclamation-circle-fill",
    status_ms = "CLASSIFICAÇÃO DO EHF: BAIXO",
    nivel_contingencia = "NÍVEL DE CALOR 2: ATENÇÃO",
    populacao = "Beba água ao longo do dia, mesmo sem sede.",
    servico_saude = "Comunicar os sinais de mal-estar pelo calor e reforçar a hidratação, com atenção aos grupos de risco.",
    acoes_setores = list(
      cievs_ve = list(
        "CIEVS: Monitorar DNC relacionados à variação do clima.",
        "CIEVS: Ativar monitoramento diário dos eventos de notificações relacionados à exposição ao calor extremo.",
        "CIEVS: Produzir informes epidemiológicos periodicamente.",
        "CIEVS: Compartilhar informações com setores estratégicos.",
        "CIEVS: Realizar a avaliação de risco semanalmente ou sempre que necessário.",
        "CIEVS: Monitorar eventos de massa e ou de grande porte na cidade.",
        "Vigilância Epidemiológica: Emissão de Boletins epidemiológicos em conjunto com CIEVS para nortear ações da assistência à saúde relacionadas ao calor no intuito de melhorar estratégias de prevenção e resposta.",
        "Vigilância Epidemiológica: Monitoramento epidemiológico através da avaliação dos impactos das ondas de calor na saúde da população através da detecção do aumento do número de casos de atendimentos, notificações, internações e óbitos associados a alta temperatura, especialmente em grupos vulneráveis (ação conjunta com outros departamentos).",
        "Vigilância Epidemiológica: Reuniões intersetoriais sempre que necessário para planejamento, monitoramento, avaliação e resposta aos eventos climáticos.",
        "NHE: Intensificação de busca ativa em prontuários eletrônicos e presencial de atendimentos relacionados à exposição de calor extremo.",
        "NHE: Fortalecimento da notificação e comunicação imediata dos casos."
      ),
      controle_endemias = list(
        "Período da Manhã (07:30 às 10:30): Visitas domiciliares, inspeção de imóveis, tratamento focal, instalação e manutenção de EDLs, instalação e leitura de ovitrampas, levantamento entomológicos, controle mecânico de criadouros.",
        "Período da Tarde: Priorizar as atividades em Imóveis Especiais (IE).",
        "Medidas de Proteção dos profissionais ACE: Pausas de 10 minutos a cada hora, hidratação, resfriamento, e reaplicação de protetor solar."
      ),
      vig_sanitaria_ambiental = list(
        "Vigilância Sanitária: Intensificar inspeções em estabelecimentos prioritários (hospitais, UPAs, ILPIs, escolas, creches, supermercados, serviços de alimentação, hotéis, shopping centers, clubes recreativos e eventos de massa).",
        "Vigilância Sanitária: Verificar as condições de abastecimento de água, climatização, conservação de alimentos, funcionamento da cadeia de frio e armazenamento de medicamentos termolábeis.",
        "Vigilância Sanitária: Orientar os responsáveis pelos estabelecimentos quanto às medidas preventivas para redução dos riscos decorrentes do calor extremo.",
        "Vigilância Sanitária: Intensificar a fiscalização das condições higiênico-sanitárias dos serviços sujeitos à Vigilância Sanitária.",
        "Vigilância Sanitária: Compartilhar informações relevantes com o CIEVS para subsidiar a avaliação de risco.",
        "Vigilância Ambiental: Intensificar o monitoramento do desabastecimento de água.",
        "Vigilância Ambiental: Reforçar as ações de fiscalização em ambientes de assistência à saúde e serviços essenciais."
      ),
      trabalhador = list(
        "Monitorar a distribuição de EPIs para os grupos de trabalhadores vulneráveis (trabalhadores ao ar livre e expostos a fontes de calor).",
        "Monitorar a realização de medidas protetivas dos empregadores/serviços públicos e privados que contenham grupos de trabalhadores vulneráveis.",
        "Monitorar a saúde dos grupos de trabalhadores vulneráveis através das fichas de notificação relacionadas ao trabalho do SINAN.",
        "Contatar os serviços de medicina do trabalho dos serviços públicos ou privados com grupos de trabalhadores vulneráveis para acompanhamento de situação de saúde dos trabalhadores.",
        "Ativar o canal de denúncias de inconformidades nas recomendações de prevenção."
      ),
      atencao_saude_unificada = list(
        "DAS: Manter disponíveis e atualizados os protocolos assistenciais das doenças e agravos ligados ao calor.",
        "DAS: Promover e manter o aprimoramento dos profissionais para manejar os agravos relacionados ao calor e orientar as medidas de prevenção.",
        "APS: Monitorar o aumento da demanda por agravos relacionados ao calor extremo.",
        "APS: Aumentar as visitas domiciliares a idosos, pessoas acamadas, gestantes, crianças e pacientes com doenças crônicas.",
        "DAES: Revisar os fluxos internos de contingência para eventos climáticos.",
        "DAES: Identificar e monitorar usuários em maior vulnerabilidade clínica e psicossocial, priorizando aqueles com maior risco de descompensação ou dificuldade de acesso ao serviço.",
        "DAES: Orientar usuários e familiares sobre medidas de prevenção relacionadas aos eventos climáticos, com ênfase em hidratação, proteção contra exposição ao calor e identificação de sinais de agravamento.",
        "DAES: Atualizar os contatos dos usuários prioritários e intensificar monitoramento dos territórios de atuação.",
        "DAES: Verificar as condições de climatização e conforto térmico da unidade.",
        "SAMU: Monitorar o aumento da demanda e reforçar a preparação das equipes."
      ),
      regulacao_comunicacao = list(
        "Central de Leitos: Emitir alerta interno para os núcleos internos de regulação (NIR) dos hospitais ao atingir sensação térmica de até 39°C.",
        "Central de Leitos: Monitorar o aumento de pedidos de transferência de pacientes nas UPAs e HPSMs com foco em CIDs de eixos distúrbios hidroeletrolíticos, cardiorrespiratório, gastrointestinal e Arboviroses.",
        "ASCOM: Intensificar campanhas educativas, divulgar boletins e orientações oficiais."
      )
    )
  ),
  
  "Severo" = list(
    classe = "Severo",
    titulo_nivel = "NÍVEL DE CALOR 3: ALERTA",
    subtitulo_ehf = "CLASSIFICAÇÃO DO EHF: SEVERO",
    rotulo_curto = "NÍVEL 3: ALERTA",
    cor_alerta = "#ea580c",
    cor_texto = "#ffffff",
    icone = "thermometer-half",
    status_ms = "CLASSIFICAÇÃO DO EHF: SEVERO",
    nivel_contingencia = "NÍVEL DE CALOR 3: ALERTA",
    populacao = "Evite o sol das 10h às 16h, procure sombra e beba bastante água.",
    servico_saude = "Intensificar a comunicação de risco, orientar pontos de hidratação e priorizar o cuidado a idosos, crianças, gestantes e pessoas com doenças crônicas.",
    acoes_setores = list(
      cievs_ve = list(
        "CIEVS: Ativar monitoramento 24 horas.",
        "CIEVS: Intensificar alertas epidemiológicos.",
        "CIEVS: Avaliar necessidade de ativação da sala de situação.",
        "CIEVS: Emitir comunicação de risco para CIEVS Estadual e Nacional.",
        "CIEVS: Monitorar a ocorrência de aumento de óbitos, doenças e agravos relacionados à variação do clima.",
        "Vigilância Epidemiológica: Manter as ações descritas no nível Atenção.",
        "Vigilância Epidemiológica: Acionamento de equipes de respostas rápidas da Vigilância Epidemiológica.",
        "Vigilância Epidemiológica: Intensificar o monitoramento dos agravos relacionados aos eventos climáticos extremos.",
        "NHE: Monitorar excesso de atendimentos e óbitos relacionados ao calor extremo.",
        "NHE: Garantir a comunicação oportuna por meio da notificação."
      ),
      controle_endemias = list(
        "Período da Manhã (07:00 às 10:30): Priorizar exclusivamente tratamento de imóveis positivos, controle de focos em áreas prioritárias, instalação e manutenção de EDL, leitura de ovitrampas, atendimentos decorrentes de denúncias classificadas como prioritárias, inspeção em pontos estratégicos.",
        "Após as 10:30: Suspender visitas domiciliares de rotina.",
        "Executar Atividades Internas: Atividades em imóveis especiais, digitação de produção, consolidação de dados, planejamento das equipes, capacitações, educação em saúde em ambientes climatizados e reuniões técnicas.",
        "Medidas de Proteção: Pausa de 15 minutos por hora, reforço da hidratação, monitoramento contínuo das equipes, encerramento imediato das atividades em caso de mal-estar."
      ),
      vig_sanitaria_ambiental = list(
        "Vigilância Sanitária: Priorizar inspeções em serviços de saúde, instituições de longa permanência para idosos, serviços de alimentação e eventos de grande porte.",
        "Vigilância Sanitária: Intensificar a fiscalização da qualidade da água destinada ao consumo humano, fabricação e comercialização de gelo e alimentos perecíveis.",
        "Vigilância Sanitária: Verificar o funcionamento de sistemas de climatização, abastecimento de água, armazenamento de medicamentos e produtos sujeitos ao controle sanitário.",
        "Vigilância Sanitária: Emitir orientações e determinar medidas corretivas imediatas para eliminação de riscos sanitários.",
        "Vigilância Sanitária: Apoiar o CIEVS e o COE com informações provenientes das ações de fiscalização sanitária.",
        "Vigilância Ambiental: Intensificar inspeções em áreas críticas."
      ),
      trabalhador = list(
        "Monitorar a adaptação de carga horária dos grupos de trabalhadores vulneráveis (trabalhadores ao ar livre e expostos ao calor).",
        "Orientar os grupos de trabalhadores vulneráveis a procurar os serviços de saúde na presença de sinais e sintomas da exposição ao calor excessivo.",
        "Monitorar diariamente as fichas de notificação relacionadas ao trabalho do SINAN.",
        "Ativar o canal de denúncias de inconformidades nas recomendações de prevenção."
      ),
      atencao_saude_unificada = list(
        "DAS: Reorganizar a rede assistencial e ampliar a capacidade de atendimento, caso necessário.",
        "APS: Priorizar atendimento a grupos vulneráveis e ampliar o horário de ações estratégicas, evitando ações externas no calor extremo.",
        "APS: Intensificar vigilância territorial e notificações imediatas.",
        "DAES: Intensificar o monitoramento e acompanhamento dos usuários em maior vulnerabilidade clínica e psicossocial com risco de descompensação (incluindo busca ativa).",
        "DAES: Reorganizar as atividades assistenciais e coletivas para ambientes climatizados com conforto térmico, adequando horários.",
        "DAES: Fortalecer a articulação com a APS, Urgência e Emergência e demais pontos da Rede de Atenção Psicossocial (RAPS).",
        "DAES: Disponibilizar água potável durante ações externas e ofertar ambiente para hidratação e recuperação térmica.",
        "DAES: Garantir disponibilização de EPIs aos servidores em atividades externas.",
        "SAMU: Reforçar equipes e ambulâncias."
      ),
      regulacao_comunicacao = list(
        "Central de Leitos: Mapear e reservar 'Leitos de Retaguarda Climática' em parceria com a DAS/DAES para demandas urgentes de desidratação e síncope térmica.",
        "Central de Leitos: Realizar reuniões extraordinárias de gerenciamento de capacidade com os hospitais para agilizar altas seguras.",
        "Central de Leitos: Monitorar taxa de ocupação de leitos de retaguarda e giro de leito nas clínicas médica e pediátrica.",
        "ASCOM: Divulgar alertas oficiais e intensificar a divulgação de medidas de autoproteção à exposição solar.",
        "ASCOM: Combater a desinformação com transparência."
      )
    )
  ),
  
  "Extremo" = list(
    classe = "Extremo",
    titulo_nivel = "NÍVEL DE CALOR 4: EMERGÊNCIA",
    subtitulo_ehf = "CLASSIFICAÇÃO DO EHF: EXTREMO",
    rotulo_curto = "NÍVEL 4: EMERGÊNCIA",
    cor_alerta = "#dc2626",
    cor_texto = "#ffffff",
    icone = "exclamation-triangle-fill",
    status_ms = "CLASSIFICAÇÃO DO EHF: EXTREMO",
    nivel_contingencia = "NÍVEL DE CALOR 4: EMERGÊNCIA",
    populacao = "Hidrate-se e, se houver mal-estar, procure o posto de saúde ou ligue 192 (SAMU).",
    servico_saude = "Reforçar o atendimento aos grupos vulneráveis e seguir o plano local de enfrentamento ao calor extremo.",
    acoes_setores = list(
      cievs_ve = list(
        "CIEVS: Apoiar a ativação do COE.",
        "CIEVS: Monitorar a ocupação de leitos.",
        "CIEVS: Realizar a avaliação de risco considerando excesso de demanda de atendimentos e colapso da rede.",
        "Vigilância Epidemiológica: Ampliar capacidade operacional e priorizar o aumento das equipes de respostas.",
        "Vigilância Epidemiológica: Intensificar monitoramento da morbidade e mortalidades.",
        "Vigilância Epidemiológica: Elaborar boletins de informes diários.",
        "NHE: Apoiar na execução de protocolos internos de Contingenciamento.",
        "NHE: Monitorar excesso de atendimentos e óbitos relacionados ao calor extremo e garantir a comunicação oportuna por meio da notificação."
      ),
      controle_endemias = list(
        "Atividades Externas: Suspensas temporariamente até redução dos níveis de calor.",
        "Manutenção Apenas das Atividades de ações de Bloqueio em Surtos ou Epidemias, mediante avaliação técnica e de atividades indispensáveis determinadas pela vigilância em saúde.",
        "Atividades Internas: Digitação da Produção, Georreferenciamento, planejamento operacional, revisão de mapas, elaboração de relatórios, capacitações, educação permanente, preparação de materiais educativos.",
        "Medidas de Proteção do trabalhador (ACE): Suspensão das atividades ao ar livre durante o período crítico, permanência em ambientes cobertos e ventilados ou climatizados, hidratação permanente, acompanhamento dos servidores com fatores de risco, avaliação contínua da necessidade de manutenção do nível de emergência."
      ),
      vig_sanitaria_ambiental = list(
        "Vigilância Sanitária: Executar operações extraordinárias de fiscalização nos estabelecimentos considerados críticos e essenciais.",
        "Vigilância Sanitária: Fiscalizar continuamente hospitais, UPAs, ILPIs, pontos de hidratação, serviços de alimentação, eventos de massa e demais locais com grande concentração de pessoas.",
        "Vigilância Sanitária: Adotar medidas administrativas previstas na legislação sanitária, incluindo apreensão de produtos impróprios, inutilização de alimentos, interdição cautelar de equipamentos, setores ou estabelecimentos quando constatado risco iminente à saúde.",
        "Vigilância Sanitária: Monitorar as condições sanitárias do abastecimento de água, alimentos, medicamentos e produtos sujeitos ao controle sanitário durante a emergência.",
        "Vigilância Sanitária: Integrar as ações do Centro de Operações de Emergência (COE), fornecendo informações técnicas e apoiando as decisões para redução dos riscos sanitários.",
        "Vigilância Ambiental: Atuar em áreas de calor extremo.",
        "Vigilância Ambiental: Intensificar ações de saneamento e controle ambiental."
      ),
      trabalhador = list(
        "CEREST: Articular a suspensão total de atividades pesadas e exposição solar direta junto a órgãos de fiscalização do trabalho.",
        "CEREST: Atendimento e acolhimento imediato a trabalhadores acometidos por exaustão ou síncope térmica.",
        "CEREST: Monitoramento ininterrupto de notificações compulsórias no SINAN de agravos decorrentes de calor."
      ),
      atencao_saude_unificada = list(
        "DAS: Garantir funcionamento da rede de atenção à saúde e reorganizar serviços conforme a demanda.",
        "APS: Manter atendimento prioritário aos grupos vulneráveis e monitoramento intensivo aos pacientes de risco.",
        "APS: Apoiar ações comunitárias de hidratação e proteção.",
        "DAES: Garantir a continuidade dos atendimentos essenciais, priorizando usuários em situação de crise, maior vulnerabilidade clínica e psicossocial (com busca ativa).",
        "DAES: Reorganizar os processos de trabalho e as equipes para assegurar a manutenção da assistência na emergência.",
        "DAES: Intensificar a articulação com a APS, Urgência e Emergência, Defesa Civil e RAPS.",
        "DAES: Atuar como ponto de apoio aos usuários ofertando hidratação, ambiente climatizado e higiene pessoal.",
        "SAMU: Ampliar capacidade operacional, responder rapidamente às urgências e apoiar o transporte de pacientes."
      ),
      regulacao_comunicacao = list(
        "Central de Leitos: Ativar o plano de contingência e reserva leitos exclusivos para agravos sensíveis ao clima.",
        "Central de Leitos: Suspensão temporária de cirurgias eletivas que demandem leitos de UTI/enfermaria pós-operatória.",
        "Central de Leitos: Atuar conjuntamente ao CISC, CIEVS e COE para gerenciar o risco de colapso da rede e saturação de leitos.",
        "Central de Leitos: Monitorar percentual de solicitações de leitos de urgência atendidas e taxa de saturação de UTIs.",
        "ASCOM: Emitir boletins diários e orientar a população sobre medidas de proteção.",
        "ASCOM: Manter comunicação transparente com a imprensa e sociedade."
      )
    )
  )
)

# ==============================================================================
# 3. INTERFACE DE USUÁRIO (UI)
# ==============================================================================
ui <- page_fluid(
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#0f766e",
    base_font = font_google("Plus Jakarta Sans"),
    heading_font = font_google("Plus Jakarta Sans")
  ),
  
  tags$head(
    # Bibliotecas Oficiais do Mapa Leaflet
    tags$link(rel = "stylesheet", href = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"),
    tags$script(src = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"),
    tags$style(HTML("
      body {
        background-color: #f8fafc;
        color: #1e293b;
      }
      
      h1, h2, h3, h4, h5, h6, 
      .titulo-padrao-escuro {
        color: #1e3a8a !important;
        font-weight: 700;
        letter-spacing: 0.015em;
        word-spacing: 0.05em;
      }
      
      p, span, label {
        color: #334155;
      }
      
      @keyframes pulso-alerta {
        0% { transform: scale(1); box-shadow: 0 0 0 0 rgba(0, 0, 0, 0.45); }
        50% { transform: scale(1.012); box-shadow: 0 0 25px 8px rgba(0, 0, 0, 0.25); }
        100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(0, 0, 0, 0.45); }
      }
      .alerta-pulsante {
        animation: pulso-alerta 2.2s infinite ease-in-out;
        border-radius: 14px;
        letter-spacing: -0.01em;
      }
      
      .alerta-pulsante, 
      .alerta-pulsante h1, 
      .alerta-pulsante h2, 
      .alerta-pulsante h5, 
      .alerta-pulsante h6, 
      .alerta-pulsante p, 
      .alerta-pulsante span, 
      .alerta-pulsante i {
        color: #ffffff !important;
      }
      .badge-alerta-inner {
        background-color: rgba(255, 255, 255, 0.2) !important;
        color: #ffffff !important;
        border: 1px solid rgba(255, 255, 255, 0.4) !important;
      }
      
      .card-setor {
        border-left: 5px solid #1e3a8a;
        background-color: #ffffff;
        border-radius: 10px;
        transition: transform 0.2s, box-shadow 0.2s;
        height: 100%;
      }
      .card-setor:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 16px rgba(15, 23, 42, 0.08) !important;
      }
      .card-setor h6 {
        color: #1e3a8a !important;
      }
      .badge-dia {
        font-size: 0.92rem;
        padding: 6px 12px;
        font-weight: 600;
        color: #ffffff !important;
      }
      
      .badge-checagem {
        background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%) !important;
        color: #ffffff !important;
        font-weight: 600;
        font-size: 0.88rem;
        padding: 8px 16px;
        border-radius: 24px;
        border: 1px solid rgba(255, 255, 255, 0.35);
        box-shadow: 0 2px 8px rgba(2, 132, 199, 0.35);
        display: inline-flex;
        align-items: center;
        gap: 8px;
        letter-spacing: 0.01em;
      }
      .badge-checagem i {
        font-size: 1.05rem;
      }
      .badge-cronometro {
        background-color: rgba(255, 255, 255, 0.22);
        padding: 2px 8px;
        border-radius: 12px;
        font-family: 'Courier New', monospace;
        font-weight: 700;
        letter-spacing: 0.05em;
        color: #ffffff !important;
      }
      .badge-oficial {
        background-color: #15803d !important;
        color: #ffffff !important;
        font-weight: 600;
        font-size: 0.85rem;
        padding: 8px 15px;
        border-radius: 20px;
        border: 1px solid rgba(255, 255, 255, 0.3);
        box-shadow: 0 2px 8px rgba(21, 128, 61, 0.35);
        display: inline-flex;
        align-items: center;
        gap: 6px;
      }
      .lista-acoes-integra {
        padding-left: 1.25rem;
        margin-bottom: 0;
      }
      .lista-acoes-integra li {
        margin-bottom: 0.55rem;
        color: #334155;
        font-size: 0.91rem;
        line-height: 1.5;
      }
      .header-logo-box {
        display: inline-flex;
        align-items: center;
        height: 58px;
      }
      .header-logo-box img {
        height: 52px;
        width: auto;
        object-fit: contain;
      }
      
      /* BOTÕES INSTITUCIONAIS DO TOPO: AZUL ESCURO E LETRAS EM BRANCO */
      .btn-topo-ms,
      .btn-topo-ms *,
      .btn-topo-boletim,
      .btn-topo-boletim *,
      #btn_abrir_boletim,
      #btn_abrir_boletim * {
        color: #ffffff !important;
      }
      .btn-topo-ms,
      .btn-topo-boletim,
      #btn_abrir_boletim {
        background-color: #1e3a8a !important;
        border-color: #1e3a8a !important;
        font-weight: 700 !important;
        border-radius: 8px !important;
        box-shadow: 0 2px 6px rgba(30, 58, 138, 0.35) !important;
        transition: all 0.2s ease-in-out !important;
      }
      .btn-topo-ms:hover,
      .btn-topo-boletim:hover,
      #btn_abrir_boletim:hover {
        background-color: #172554 !important;
        border-color: #172554 !important;
        color: #ffffff !important;
        transform: translateY(-1px);
        box-shadow: 0 4px 10px rgba(30, 58, 138, 0.45) !important;
      }
    ")),
    
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"),
    tags$script(HTML("
      function baixarBoletimPDF() {
        var elemento = document.getElementById('conteudo_boletim_r');
        if (!elemento) elemento = document.querySelector('.modal-body');
        if (!elemento) return;
        
        var btns = document.querySelectorAll('.btn-baixar-pdf');
        btns.forEach(function(b) {
          b.disabled = true;
          b.innerHTML = '<span class=\"spinner-border spinner-border-sm me-1\"></span> Gerando PDF...';
        });

        var opt = {
          margin: [8, 8, 8, 8],
          filename: 'Boletim_Informe_do_Clima_Belem_' + (new Date().toISOString().slice(0, 10)) + '.pdf',
          image: { type: 'jpeg', quality: 0.98 },
          html2canvas: { scale: 2, useCORS: true, logging: false },
          jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
        };

        if (typeof html2pdf !== 'undefined') {
          html2pdf().set(opt).from(elemento).save().then(function() {
            btns.forEach(function(b) {
              b.disabled = false;
              b.innerHTML = '<i class=\"bi bi-file-earmark-pdf-fill me-1\"></i> Baixar Arquivo em PDF';
            });
          }).catch(function(err) {
            window.print();
            btns.forEach(function(b) {
              b.disabled = false;
              b.innerHTML = '<i class=\"bi bi-file-earmark-pdf-fill me-1\"></i> Baixar Arquivo em PDF';
            });
          });
        } else {
          window.print();
          btns.forEach(function(b) {
            b.disabled = false;
            b.innerHTML = '<i class=\"bi bi-file-earmark-pdf-fill me-1\"></i> Baixar Arquivo em PDF';
          });
        }
      }
    ")),
    
    tags$script(HTML("
      var tempoRestante = 600;
      function formatarTempo(segundos) {
        var min = Math.floor(segundos / 60);
        var seg = segundos % 60;
        if (min < 10) min = '0' + min;
        if (seg < 10) seg = '0' + seg;
        return min + ':' + seg;
      }
      setInterval(function() {
        tempoRestante--;
        if (tempoRestante < 0) {
          tempoRestante = 600;
        }
        var el = document.getElementById('cronometro-regressivo');
        if (el) {
          el.innerText = formatarTempo(tempoRestante);
        }
      }, 1000);
    "))
  ),
  
  # CABEÇALHO INSTITUCIONAL OFICIAL
  div(
    class = "d-flex justify-content-between align-items-center py-3 px-4 mb-3 border-bottom shadow-sm bg-white rounded-3",
    div(
      class = "d-flex align-items-center gap-3",
      div(class = "header-logo-box",
          tags$img(src = "imagens_locais/logo_sesma.png", alt = "SESMA - Secretaria Municipal de Saúde de Belém", style = "height: 54px; width: auto; object-fit: contain;")
      ),
      div(
        class = "ms-1",
        h4(class = "m-0 titulo-padrao-escuro fw-bold", "SISTEMA OFICIAL DE VIGILÂNCIA DE EXCESSO DE CALOR"),
        p(class = "text-muted m-0 small", "SESMA / Prefeitura de Belém · Monitoramento de excesso de Calor em Belém · Plano de Contingência 2026")
      )
    ),
    div(
      class = "text-end d-flex align-items-center gap-2",
      tags$a(
        href = "https://clima.saude.gov.br/pa/belem?data=2026-10-27&modo=ehf",
        target = "_blank",
        rel = "noopener noreferrer",
        onclick = "window.open('https://clima.saude.gov.br/pa/belem?data=2026-10-27&modo=ehf', '_blank'); return false;",
        class = "btn btn-topo-ms btn-sm fw-bold shadow-sm d-inline-flex align-items-center gap-2 px-3 py-2",
        title = "Acessar página oficial do Ministério da Saúde",
        bs_icon("box-arrow-up-right"),
        span("Ministério da Saúde")
      ),
      actionButton(
        "btn_abrir_boletim",
        label = "Boletim: Informe do Clima em Belém",
        icon = bs_icon("file-earmark-text-fill"),
        class = "btn btn-topo-boletim btn-sm fw-bold shadow-sm px-3 py-2",
        title = "Gerar Boletim Oficial do Clima"
      )
    )
  ),
  
  # BANNER DE ALERTA PISCANTE COM FONTE 100% BRANCA
  uiOutput("bloco_alerta_pulsante"),
  
  # CARD: O QUE FAZER HOJE (RECOMENDAÇÕES GERAIS)
  card(
    class = "shadow-sm mb-4 border-0 rounded-3",
    card_header(
      class = "bg-light py-2 px-3 fw-bold titulo-padrao-escuro d-flex justify-content-between align-items-center",
      div(
        div(bs_icon("table"), " O QUE FAZER HOJE"),
        div(class = "small fw-normal text-muted", style = "font-size: 0.82rem; margin-top: 1px;", "(RECOMENDAÇÕES GERAIS)")
      ),
      span(class = "small text-muted text-end", "Base Operacional Oficial: EHF (Intensidade do Calor vs. Climatologia Histórica)")
    ),
    card_body(
      uiOutput("quadro_ms_orientacoes")
    )
  ),
  
  # CARD: PREVISÃO OPERACIONAL DE CALOR
  card(
    class = "shadow-sm mb-4 border-0 rounded-3",
    card_header(
      class = "bg-light py-2 px-3 fw-bold titulo-padrao-escuro",
      div(bs_icon("calendar3"), " PREVISÃO OPERACIONAL DE CALOR"),
      div(class = "small fw-normal text-muted", style = "font-size: 0.82rem; margin-top: 1px;",
          "(D+0 A D+4) — D+0 é a medição/previsão atual; D+1 a D+4 sinalizam a tendência para Belém")
    ),
    card_body(
      uiOutput("grade_previsao")
    )
  ),
  
  # MAPA OFICIAL DE VIGILÂNCIA BIOCLIMÁTICA — BELÉM / PA
  uiOutput("card_mapa_belem"),

  # CARD: AÇÕES DOS SETORES REORGANIZADAS EM 6 QUADROS SIMÉTRICOS
  div(
    class = "mb-3 mt-4 d-flex justify-content-between align-items-center",
    h4(class = "fw-bold titulo-padrao-escuro m-0", bs_icon("diagram-3-fill"), " AÇÕES DE RESPOSTA DOS SETORES DE BELÉM (PARA O NÍVEL VIGENTE)"),
    uiOutput("badge_coe_status")
  ),
  uiOutput("quadro_acoes_setores"),
  
  # RODAPÉ
  div(
    class = "text-center text-muted py-3 border-top small",
    p(
      "Endereço Oficial Monitorado: ", tags$a(href = "https://clima.saude.gov.br/pa/belem?data=2026-10-27&modo=ehf", target = "_blank", "https://clima.saude.gov.br/pa/belem?data=2026-10-27&modo=ehf"), tags$br(),
      "Ministério da Saúde (EHF Nairn & Fawcett) · CIEVS Belém / SESMA (Plano de Enfrentamento ao Calor Extremo 2026)."
    )
  )
)

# ==============================================================================
# 4. LÓGICA DO SERVIDOR (SERVER)
# ==============================================================================
server <- function(input, output, session) {
  
  # Renderização dos Logos Oficiais com fallback em SVG
  output$logo_saude_belem <- renderUI({
    arquivos_possiveis <- c("www/ass. saude 2.png", "ass. saude 2.png", "ass_saude_2.png", "ass saude 2.png")
    encontrado <- arquivos_possiveis[file.exists(arquivos_possiveis)][1]
    
    if (!is.na(encontrado)) {
      div(class = "header-logo-box",
          tags$img(src = paste0("imagens_locais/", basename(encontrado)), alt = "Saúde Belém Prefeitura")
      )
    } else {
      div(class = "header-logo-box",
          HTML('
            <svg height="50" viewBox="0 0 540 130" xmlns="http://www.w3.org/2000/svg">
              <text x="10" y="85" font-family="Plus Jakarta Sans, sans-serif" font-weight="900" font-size="70" fill="#1e3a8a">Saúde</text>
              <g transform="translate(230, 15)">
                <rect x="0" y="0" width="46" height="46" rx="4" fill="#22c55e"/>
                <circle cx="23" cy="23" r="10" fill="#ffffff" opacity="0.9"/>
                <rect x="52" y="0" width="46" height="46" rx="4" fill="#1e3a8a"/>
                <path d="M75,8 L75,38 M60,23 L90,23" stroke="#ffffff" stroke-width="4"/>
                <rect x="0" y="52" width="46" height="46" rx="4" fill="#1e3a8a"/>
                <path d="M12,85 C12,65 34,65 34,85 Z" fill="#ffffff"/>
                <rect x="52" y="52" width="46" height="46" rx="4" fill="#22c55e"/>
                <path d="M52,90 Q75,60 98,75 L98,98 L52,98 Z" fill="#15803d"/>
              </g>
              <text x="345" y="75" font-family="Plus Jakarta Sans, sans-serif" font-weight="900" font-size="62" fill="#1e3a8a" letter-spacing="1">BELÉM</text>
              <text x="348" y="105" font-family="Plus Jakarta Sans, sans-serif" font-weight="800" font-size="20" fill="#1e3a8a" letter-spacing="6">PREFEITURA</text>
              <text x="390" y="125" font-family="Plus Jakarta Sans, sans-serif" font-weight="600" font-size="12" fill="#475569" letter-spacing="2">CAPITAL DA AMAZÔNIA</text>
            </svg>
          ')
      )
    }
  })
  
  output$logo_cievs_belem <- renderUI({
    arquivos_possiveis <- c("www/cievs.jpg", "cievs.jpg", "cievs.png", "cievs.jpeg")
    encontrado <- arquivos_possiveis[file.exists(arquivos_possiveis)][1]
    
    if (!is.na(encontrado)) {
      div(class = "header-logo-box",
          tags$img(src = paste0("imagens_locais/", basename(encontrado)), alt = "CIEVS Belém", style = "border-radius: 6px;")
      )
    } else {
      div(class = "header-logo-box",
          HTML('
            <svg height="50" viewBox="0 0 280 120" xmlns="http://www.w3.org/2000/svg">
              <rect width="280" height="120" rx="8" fill="#000000"/>
              <g transform="translate(15, 10)">
                <circle cx="50" cy="50" r="42" fill="#0f2b5c"/>
                <circle cx="50" cy="50" r="28" fill="none" stroke="#000000" stroke-width="9"/>
                <circle cx="50" cy="10" r="7" fill="#22c55e"/>
                <circle cx="15" cy="35" r="7" fill="#22c55e"/>
                <circle cx="85" cy="35" r="7" fill="#22c55e"/>
                <circle cx="20" cy="70" r="6" fill="#22c55e"/>
                <circle cx="95" cy="65" r="6" fill="#22c55e"/>
                <circle cx="22" cy="98" r="7" fill="#22c55e"/>
                <circle cx="88" cy="98" r="7" fill="#22c55e"/>
                <line x1="50" y1="10" x2="35" y2="28" stroke="#22c55e" stroke-width="3"/>
                <line x1="15" y1="35" x2="35" y2="28" stroke="#22c55e" stroke-width="3"/>
                <line x1="85" y1="35" x2="65" y2="28" stroke="#22c55e" stroke-width="3"/>
                <line x1="20" y1="70" x2="22" y2="98" stroke="#22c55e" stroke-width="3"/>
                <line x1="95" y1="65" x2="88" y2="98" stroke="#22c55e" stroke-width="3"/>
              </g>
              <text x="125" y="62" font-family="Plus Jakarta Sans, sans-serif" font-weight="900" font-size="44" fill="#0f4c9c" letter-spacing="2">CIEVS</text>
              <text x="128" y="102" font-family="Plus Jakarta Sans, sans-serif" font-weight="900" font-size="34" fill="#22c55e" letter-spacing="3">BELÉM</text>
            </svg>
          ')
      )
    }
  })
  
  # Gerenciamento persistente dos destinatários setoriais
  destinatarios_iniciais <- data.frame(
    Nome = c(
      "David Aurélio Vale do Rosário (RT)",
      "Suellen Gomes Soares (RT)",
      "Luan Auad Beltrão Pereira (Coord. eMulti)",
      "Mozer da Costa Farias (Casas Especializadas)",
      "Cláudia Porto (Coordenação CEREST)",
      "Paulo Gomes (Diretor DEVISA)",
      "Jones Ribeiro (Coord. Regulação)",
      "Danielle Dias de Oliveira (Coord. ASCOM)"
    ),
    Email = c(
      "davidaurelio_rosario@hotmail.com",
      "suellensoares8727@gmail.com",
      "coordenacao.emulti.sesma@gmail.com",
      "casasespecializadas@gmail.com",
      "cerest_bel@sesma.pmb.pa.gov.br",
      "devisa.belem@sesma.pmb.pa.gov.br",
      "regulacao.belem@sesma.pmb.pa.gov.br",
      "ascomsesma@gmail.com"
    ),
    Setor = c(
      "CIEVS Belém & Vigilância Epidemiológica",
      "CIEVS Belém & Vigilância Epidemiológica",
      "Atenção à Saúde (APS, Urgência/Emergência, SAMU e Casas Especializadas)",
      "Atenção à Saúde (APS, Urgência/Emergência, SAMU e Casas Especializadas)",
      "CEREST Saúde do Trabalhador",
      "Vigilância Sanitária e Ambiental",
      "Regulação e Comunicação em Saúde",
      "Regulação e Comunicação em Saúde"
    ),
    stringsAsFactors = FALSE
  )
  
  if (file.exists("destinatarios.json")) {
    tryCatch({
      df_carregado <- jsonlite::fromJSON("destinatarios.json")
      if (is.data.frame(df_carregado) && nrow(df_carregado) > 0) {
        destinatarios_iniciais <- df_carregado
      }
    }, error = function(e) {})
  }
  
  destinatarios <- reactiveVal(destinatarios_iniciais)
  nivel_anterior <- reactiveVal(NULL)
  
  # ==============================================================================
  # EXTRAÇÃO PROGRAMÁTICA REAL DOS DADOS DO MINISTÉRIO DA SAÚDE
  # ==============================================================================
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
  
  obter_dados_oficiais <- function() {
    hoje <- Sys.Date()
    tryCatch({
      hoje <- as.Date(format(Sys.time(), tz = "America/Belem"))
    }, error = function(e) {})
    
    data_alvo_str <- format(hoje + 4, "%Y-%m-%d")
    url_oficial <- paste0("https://clima.saude.gov.br/pa/belem?data=", data_alvo_str, "&modo=ehf")
    
    dados_padrao <- list(
      municipio     = "Belém - PA",
      data_base_iso = format(hoje, "%Y-%m-%d"),
      data_base_br  = format(hoje, "%d/%m/%Y"),
      hora_consulta = format(Sys.time(), "%H:%M:%S"),
      sucesso       = FALSE,
      fonte_url     = url_oficial,
      origem        = "Fallback Padrão",
      hoje          = list(dia = formatar_dia_br(hoje), data_br = format(hoje, "%d/%m/%Y"), classe = "Sem excesso", ehf = 0.0, tmax = 34.0, tmin = 23.0),
      previsoes     = list()
    )
    
    # 1. Tentativa de raspagem direta em tempo real
    raspagem_ok <- FALSE
    tryCatch({
      resp <- httr::GET(
        url_oficial,
        httr::timeout(10),
        httr::user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
      )
      
      if (httr::status_code(resp) == 200) {
        html_txt <- httr::content(resp, as = "text", encoding = "UTF-8")
        padrao <- '\\{[^{}]*cd_mun:"1501402"[^{}]*\\}'
        matches <- regmatches(html_txt, gregexpr(padrao, html_txt))[[1]]
        
        if (length(matches) > 0) {
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
          lista_prev <- list()
          for (d_iso in dias_desejados) {
            item <- dados_por_data[[d_iso]]
            dt_obj <- as.Date(d_iso)
            if (!is.null(item)) {
              prev_item <- list(
                dia     = formatar_dia_br(dt_obj),
                data_br = format(dt_obj, "%d/%m/%Y"),
                classe  = item$classe,
                ehf     = item$ehf,
                tmax    = item$tmax,
                tmin    = item$tmin
              )
            } else {
              prev_item <- list(
                dia     = formatar_dia_br(dt_obj),
                data_br = format(dt_obj, "%d/%m/%Y"),
                classe  = "Sem excesso",
                ehf     = 0.0,
                tmax    = 34.0,
                tmin    = 23.0
              )
            }
            lista_prev[[length(lista_prev) + 1]] <- prev_item
          }
          
          dados_padrao$hoje <- lista_prev[[1]]
          dados_padrao$previsoes <- lista_prev
          dados_padrao$sucesso <- TRUE
          dados_padrao$origem <- "Extração Direta (Live MS)"
          raspagem_ok <- TRUE
          
          # Extração dos parâmetros oficiais do Ministério da Saúde para Belém
          p_lat <- regmatches(html_txt, regexec('cd_mun:"1501402"[^}]*lat:([0-9.-]+)', html_txt))[[1]]
          p_lon <- regmatches(html_txt, regexec('cd_mun:"1501402"[^}]*lon:([0-9.-]+)', html_txt))[[1]]
          p_pico <- regmatches(html_txt, regexec('cd_mun:"1501402"[^}]*tmax_pico_p75:([0-9.]+)', html_txt))[[1]]
          
          lat_v <- if (length(p_lat) > 1) as.numeric(p_lat[2]) else -1.240717
          lon_v <- if (length(p_lon) > 1) as.numeric(p_lon[2]) else -48.459911
          pico_v <- if (length(p_pico) > 1) round(as.numeric(p_pico[2]), 1) else 34.1
          tmean_v <- if (!is.null(dados_padrao$hoje$tmean)) dados_padrao$hoje$tmean else 29.5
          
          dados_padrao$indicadores_mapa <- list(
            ehf = dados_padrao$hoje$ehf,
            media = tmean_v,
            hoje = dados_padrao$hoje$tmax,
            pico_habitual = pico_v,
            tmin = dados_padrao$hoje$tmin,
            lat = lat_v,
            lon = lon_v
          )
          
          # Salva em cache local sem dados fictícios
          tryCatch({
            jsonlite::write_json(dados_padrao, "dados_clima_atual.json", auto_unbox = TRUE, pretty = TRUE)
          }, error = function(e) {})
        }
      }
    }, error = function(e) {
      message("Aviso: Falha temporária na requisição ao MS: ", e$message)
    })
    
    # 2. Se a raspagem falhou, recupera do cache gerado pelo coletor/CRONJOB
    if (!raspagem_ok && file.exists("dados_clima_atual.json")) {
      tryCatch({
        cache <- jsonlite::fromJSON("dados_clima_atual.json", simplifyVector = FALSE)
        if (!is.null(cache$hoje) && !is.null(cache$previsoes)) {
          dados_padrao <- cache
          dados_padrao$origem <- paste("Cache Local (CRON /", cache$hora_consulta, ")")
          raspagem_ok <- TRUE
        }
      }, error = function(e) {})
    }
    
    # 3. Fallback se lista ainda estiver vazia
    if (length(dados_padrao$previsoes) == 0) {
      for (i in 0:4) {
        dt_f <- hoje + i
        dados_padrao$previsoes[[i + 1]] <- list(
          dia     = formatar_dia_br(dt_f),
          data_br = format(dt_f, "%d/%m/%Y"),
          classe  = "Sem excesso",
          ehf     = 0.0,
          tmax    = 34.0,
          tmin    = 23.0
        )
      }
      dados_padrao$hoje <- dados_padrao$previsoes[[1]]
    }
    
    return(dados_padrao)
  }
  
  # Consulta periódica oficial a cada 10 minutos (600.000 ms)
  dados_painel <- reactive({
    invalidateLater(600000, session)
    obter_dados_oficiais()
  })
  
  # Envio real de e-mails via blastula
  enviar_emails_reais <- function(assunto, corpo_markdown, lista_destinatarios) {
    if (nrow(lista_destinatarios) == 0) {
      return(list(sucesso = FALSE, msg = "Nenhum e-mail cadastrado na lista."))
    }
    
    if (is.null(input$smtp_pass) || nchar(trimws(input$smtp_pass)) == 0) {
      cat("\n=== [MODO HOMOLOGAÇÃO: CONFIGURE A SENHA SMTP NA ABA DE CONFIGURAÇÃO] ===\n")
      cat(paste("Assunto:", assunto, "\n"))
      cat(corpo_markdown)
      cat("\n=========================================================================\n")
      return(list(
        sucesso = TRUE, 
        homologacao = TRUE,
        msg = "Mensagem formatada com sucesso! Para envio externo aos destinatários, informe a senha na aba 'Configuração do Servidor de Envio (SMTP)'."
      ))
    }
    
    email_obj <- compose_email(
      body = md(corpo_markdown),
      footer = md("Painel de Vigilância de Excesso de Calor · **CIEVS Belém / SESMA** · Prefeitura Municipal de Belém")
    )
    
    erros <- c()
    enviados <- 0
    
    for (i in 1:nrow(lista_destinatarios)) {
      email_dest <- trimws(lista_destinatarios$Email[i])
      tryCatch({
        smtp_send(
          email = email_obj,
          to = email_dest,
          from = input$smtp_user,
          subject = assunto,
          credentials = creds(
            user = input$smtp_user,
            host = input$smtp_host,
            port = input$smtp_port,
            use_ssl = (input$smtp_use_ssl == "ssl")
          )
        )
        enviados <- enviados + 1
      }, error = function(e) {
        erros <<- c(erros, paste(email_dest, ":", e$message))
      })
    }
    
    if (length(erros) > 0) {
      return(list(sucesso = FALSE, homologacao = FALSE, msg = paste(erros, collapse = "; ")))
    } else {
      return(list(sucesso = TRUE, homologacao = FALSE, msg = paste("E-mails transmitidos com sucesso para", enviados, "destinatários.")))
    }
  }
  
  # Observador oficial de mudança de status térmico
  observe({
    dados <- dados_painel()
    classe_atual <- dados$hoje$classe
    
    if (is.null(nivel_anterior())) {
      nivel_anterior(classe_atual)
    } else if (!identical(nivel_anterior(), classe_atual)) {
      info <- matriz_niveis[[classe_atual]]
      assunto_auto <- paste0("[ALERTA OFICIAL CIEVS BELÉM] ", info$titulo_nivel)
      
      corpo_auto <- glue("
        ## ALERTA BIOCLIMÁTICO OFICIAL - CIEVS BELÉM / SESMA
        **Atenção:** Os dados do Ministério da Saúde indicam que Belém mudou para **{info$titulo_nivel}** ({info$subtitulo_ehf}).
        
        * **Data de Referência:** {dados$data_base_br}
        * **Temperatura Prevista:** {dados$hoje$tmax} °C | **EHF:** {dados$hoje$ehf}
        * **Status do Plano Local:** {info$titulo_nivel}
        * **Classificação Oficial MS (EHF):** {info$subtitulo_ehf}
        
        ### Recomendações Gerais:
        * **População:** {info$populacao}
        * **Serviços de Saúde:** {info$servico_saude}
      ")
      
      resultado <- enviar_emails_reais(assunto_auto, corpo_auto, destinatarios())
      
      showNotification(
        paste0("MUDANÇA OFICIAL DE STATUS: Belém passou para ", classe_atual, "! Alerta automático despachado."),
        type = if (classe_atual %in% c("Severo", "Extremo")) "error" else "warning",
        duration = 12
      )
      
      nivel_anterior(classe_atual)
    }
  })
  
  # Modal do Boletim Oficial: Informe do Clima em Belém
  observeEvent(input$btn_abrir_boletim, {
    dados <- dados_painel()
    classe <- dados$hoje$classe
    info <- matriz_niveis[[classe]]
    ac <- info$acoes_setores
    
    linhas_prev <- lapply(dados$previsoes, function(p) {
      cfg <- matriz_niveis[[p$classe]]
      tags$tr(
        tags$td(class = "fw-bold", p$dia),
        tags$td(p$data_br),
        tags$td(class = "fw-bold text-dark fs-6", paste0(p$tmax, " °C")),
        tags$td(class = "text-muted", paste0(if (!is.null(p$tmin)) p$tmin else 23.0, " °C")),
        tags$td(
          span(class = "badge py-2 px-3 fw-bold text-white w-100", style = paste0("background-color:", cfg$cor_alerta, ";"), cfg$rotulo_curto)
        ),
        tags$td(class = "fw-semibold small", cfg$subtitulo_ehf),
        tags$td(tags$code(p$ehf))
      )
    })
    
    showModal(modalDialog(
      title = div(
        class = "d-flex justify-content-between align-items-center w-100",
        div(bs_icon("file-earmark-text-fill"), " Boletim Oficial: Informe do Clima em Belém"),
        tags$div(
          class = "d-flex gap-2",
          tags$button(
            type = "button",
            class = "btn btn-danger btn-sm fw-bold d-flex align-items-center gap-1 shadow-sm btn-baixar-pdf",
            onclick = "baixarBoletimPDF();",
            bs_icon("file-earmark-pdf-fill"), " Baixar Arquivo em PDF"
          ),
          tags$button(
            type = "button",
            class = "btn btn-outline-light btn-sm fw-bold d-flex align-items-center gap-1",
            onclick = "window.print();",
            bs_icon("printer-fill"), " Imprimir"
          )
        )
      ),
      size = "xl",
      easyClose = TRUE,
      footer = modalButton("Fechar"),
      div(
        id = "conteudo_boletim_r",
        class = "boletim-documento bg-white p-3 p-md-4 rounded shadow-sm border",
        # Cabeçalho
        div(
          class = "d-flex justify-content-between align-items-center border-bottom pb-3 mb-3 flex-wrap gap-3",
          div(
            class = "d-flex align-items-center gap-3",
            tags$img(src = "imagens_locais/logo_sesma.png", alt = "SESMA", style = "height: 56px; width: auto; object-fit: contain;"),
            div(
              h5(class = "fw-bold mb-0 text-dark", "PREFEITURA MUNICIPAL DE BELÉM"),
              h6(class = "fw-bold mb-0 text-primary", style = "font-size: 0.95rem;", "SECRETARIA MUNICIPAL DE SAÚDE · SESMA"),
              p(class = "small text-muted mb-0", "Centro de Informações Estratégicas em Vigilância em Saúde · CIEVS Belém")
            )
          ),
          div(
            class = "text-end",
            span(class = "badge bg-primary fs-6 px-3 py-2", bs_icon("file-earmark-medical"), " INFORME DO CLIMA EM BELÉM"),
            p(class = "small text-muted mt-1 mb-0", paste("Data de Emissão:", dados$hoje$data_br, "às", dados$hora_consulta))
          )
        ),
        div(
          class = "text-center mb-4 pb-2 border-bottom",
          h3(class = "fw-black text-dark mb-1", style = "font-weight: 800;", "BOLETIM OFICIAL: INFORME DO CLIMA EM BELÉM"),
          p(class = "text-muted mb-2", "Sistema Oficial de Vigilância de Excesso de Calor e Plano de Contingência Local"),
          div(
            class = "d-flex justify-content-center gap-3 small text-muted flex-wrap",
            span(tags$strong("Município:"), " Belém - PA (1501402)"),
            span("•"),
            span(tags$strong("Fonte Oficial:"), tags$a(href = "https://clima.saude.gov.br/pa/belem?data=2026-10-27&modo=ehf", target = "_blank", "Ministério da Saúde")),
            span("•"),
            span(tags$strong("Metodologia:"), " EHF (Excess Heat Factor)")
          )
        ),
        # 1. Nível de Calor do Dia
        div(
          class = "mb-4",
          h5(class = "fw-bold titulo-padrao-escuro mb-2", bs_icon("bell-fill"), " 1. NÍVEL DE CALOR DO DIA (VIGÊNCIA HOJE)"),
          div(
            class = "p-4 rounded-3 text-white shadow-sm",
            style = paste0("background-color:", info$cor_alerta, "; border: 2px solid rgba(255,255,255,0.7);"),
            div(
              class = "row align-items-center",
              div(class = "col-md-2 text-center mb-3 mb-md-0", tags$i(class = paste0("bi bi-", info$icone), style = "font-size: 4rem; color: #ffffff !important;")),
              div(
                class = "col-md-7 text-start",
                div(class = "mb-2", span(class = "badge bg-white text-dark px-3 py-1 fw-bold text-uppercase", "CIEVS BELÉM · SESMA"), span(class = "badge bg-white text-dark px-2 py-1 ms-2 fw-normal", paste("DATA:", dados$data_base_br))),
                h2(class = "fw-black m-0 text-white", style = "font-weight: 900;", info$titulo_nivel),
                div(class = "mt-2 text-white fw-bold opacity-90", style = "font-size: 1.15rem;", info$subtitulo_ehf)
              ),
              div(
                class = "col-md-3 text-center border-start border-white-50",
                div(class = "small text-uppercase opacity-75 text-white", "Temp. Máxima Prevista"),
                h2(class = "fw-bold mb-0 text-white", paste0(dados$hoje$tmax, " °C")),
                div(class = "small opacity-90 text-white mt-1", paste("Mínima:", if (!is.null(dados$hoje$tmin)) dados$hoje$tmin else 23.0, "°C")),
                span(class = "badge bg-black bg-opacity-25 mt-2", paste("EHF Diário:", dados$hoje$ehf))
              )
            )
          ),
          div(
            class = "row g-3 mt-2",
            div(class = "col-md-6", div(class = "p-3 bg-light rounded border h-100", style = "border-left: 4px solid #1e3a8a !important;", h6(class = "fw-bold text-primary mb-1", bs_icon("people-fill"), " O QUE FAZER HOJE: POPULAÇÃO"), p(class = "mb-0 text-dark small", info$populacao))),
            div(class = "col-md-6", div(class = "p-3 bg-light rounded border h-100", style = "border-left: 4px solid #1e3a8a !important;", h6(class = "fw-bold text-primary mb-1", bs_icon("hospital"), " O QUE FAZER HOJE: SERVIÇOS DE SAÚDE"), p(class = "mb-0 text-dark small", info$servico_saude)))
          )
        ),
        # 2. Previsão Operacional de Calor
        div(
          class = "mb-4",
          h5(class = "fw-bold titulo-padrao-escuro mb-1", bs_icon("calendar3"), " 2. PREVISÃO OPERACIONAL DE CALOR"),
          p(class = "small text-muted mb-2", "(D+0 A D+4) — D+0 é a medição/previsão atual; D+1 a D+4 sinalizam a tendência para Belém."),
          div(
            class = "table-responsive",
            tags$table(
              class = "table table-bordered table-striped align-middle text-center mb-0",
              tags$thead(class = "table-light", tags$tr(tags$th("Referência"), tags$th("Data"), tags$th("Temp. Máx"), tags$th("Temp. Mín"), tags$th("Nível de Calor"), tags$th("Classificação do EHF"), tags$th("Fator EHF"))),
              tags$tbody(linhas_prev)
            )
          )
        ),
        # 3. Ações Setoriais
        div(
          class = "mb-4",
          h5(class = "fw-bold titulo-padrao-escuro mb-1", bs_icon("diagram-3-fill"), " 3. AÇÕES DE RESPOSTA DOS SETORES DE BELÉM (PARA O NÍVEL VIGENTE)"),
          p(class = "small text-muted mb-3", paste("Protocolos e procedimentos setoriais ativos na rede de saúde para o", info$titulo_nivel, ":")),
          div(
            class = "row g-3",
            div(class = "col-md-4", div(class = "card card-setor p-3 shadow-sm h-100", h6(class = "fw-bold", bs_icon("activity"), " CIEVS Belém, VE & NHEs"), tags$ul(class = "lista-acoes-integra", lapply(ac$cievs_ve, tags$li)))),
            div(class = "col-md-4", div(class = "card card-setor p-3 shadow-sm h-100", h6(class = "fw-bold", bs_icon("bug-fill"), " Controle de Endemias"), tags$ul(class = "lista-acoes-integra", lapply(ac$controle_endemias, tags$li)))),
            div(class = "col-md-4", div(class = "card card-setor p-3 shadow-sm h-100", h6(class = "fw-bold", bs_icon("shield-fill-check"), " Vigilância Sanitária e Ambiental"), tags$ul(class = "lista-acoes-integra", lapply(ac$vig_sanitaria_ambiental, tags$li)))),
            div(class = "col-md-4", div(class = "card card-setor p-3 shadow-sm h-100", h6(class = "fw-bold", bs_icon("person-workspace"), " CEREST Saúde do Trabalhador"), tags$ul(class = "lista-acoes-integra", lapply(ac$trabalhador, tags$li)))),
            div(class = "col-md-4", div(class = "card card-setor p-3 shadow-sm h-100", h6(class = "fw-bold", bs_icon("heart-pulse-fill"), " Atenção à Saúde (APS, Urgência, SAMU)"), tags$ul(class = "lista-acoes-integra", lapply(ac$atencao_saude_unificada, tags$li)))),
            div(class = "col-md-4", div(class = "card card-setor p-3 shadow-sm h-100", h6(class = "fw-bold", bs_icon("hospital"), " Regulação e Comunicação em Saúde"), tags$ul(class = "lista-acoes-integra", lapply(ac$regulacao_comunicacao, tags$li))))
          )
        ),
        # Rodapé
        div(
          class = "border-top pt-3 mt-4 text-center text-muted small",
          p(class = "mb-1", tags$strong("Prefeitura Municipal de Belém · Secretaria Municipal de Saúde (SESMA)")),
          p(class = "mb-1", "Centro de Informações Estratégicas em Vigilância em Saúde (CIEVS Belém) · Vigilância de Eventos Climáticos"),
          p(class = "mb-0", "Página oficial do Ministério da Saúde: ", tags$a(href = "https://clima.saude.gov.br/pa/belem?data=2026-10-27&modo=ehf", target = "_blank", "https://clima.saude.gov.br/pa/belem?data=2026-10-27&modo=ehf"))
        )
      )
    ))
  })
  
  # Banner de Alerta Piscante com Texto e Ícone 100% Brancos
  output$bloco_alerta_pulsante <- renderUI({
    dados <- dados_painel()
    classe <- dados$hoje$classe
    info <- matriz_niveis[[classe]]
    
    div(
      class = "alerta-pulsante p-4 mb-4 text-center shadow-lg",
      style = paste0(
        "background-color: ", info$cor_alerta, "; ",
        "border: 3px solid rgba(255,255,255,0.7);"
      ),
      div(
        class = "row align-items-center",
        div(
          class = "col-md-2 text-center",
          tags$i(class = paste0("bi bi-", info$icone), style = "font-size: 4.8rem; color: #ffffff !important;")
        ),
        div(
          class = "col-md-7 text-start",
          div(
            class = "mb-2",
            span(class = "badge badge-alerta-inner px-3 py-1 fw-bold text-uppercase", "CIEVS BELÉM · SESMA"),
            span(class = "badge badge-alerta-inner px-2 py-1 ms-2 fw-normal", paste("DATA:", dados$data_base_br))
          ),
          h1(class = "fw-black m-0 tracking-tight text-white display-6", style = "font-weight: 900; letter-spacing: -0.01em;", info$titulo_nivel),
          div(class = "mt-2 text-white fw-bold opacity-90", style = "font-size: 1.15rem; letter-spacing: 0.03em;", info$subtitulo_ehf)
        ),
        div(
          class = "col-md-3 text-center border-start border-white-50",
          h6(class = "text-uppercase opacity-75 mb-1", "Temperatura Prevista"),
          h2(class = "fw-bold mb-0", paste0(dados$hoje$tmax, " °C")),
          span(class = "badge badge-alerta-inner mt-2", paste("EHF Diário:", dados$hoje$ehf))
        )
      )
    )
  })
  
  # Recomendações Gerais
  output$quadro_ms_orientacoes <- renderUI({
    dados <- dados_painel()
    classe <- dados$hoje$classe
    info <- matriz_niveis[[classe]]
    
    layout_columns(
      col_widths = c(6, 6),
      div(
        class = "p-3 p-md-4 rounded-3 border shadow-sm bg-white",
        style = "border-left: 5px solid #1e3a8a !important;",
        div(class = "d-flex align-items-center mb-3",
            tags$i(class = "bi bi-people-fill fs-3 me-2", style = "color: #1e3a8a;"),
            h5(class = "m-0", style = "color: #1e3a8a !important; font-weight: 800; font-size: 1.15rem; letter-spacing: 0.04em; word-spacing: 0.15em;", "O QUE FAZER HOJE: POPULAÇÃO")
        ),
        p(class = "mb-0", style = "color: #1e293b !important; font-size: 1.15rem; line-height: 1.6; word-spacing: 0.05em; font-weight: 500;", info$populacao)
      ),
      div(
        class = "p-3 p-md-4 rounded-3 border shadow-sm bg-white",
        style = "border-left: 5px solid #1e3a8a !important;",
        div(class = "d-flex align-items-center mb-3",
            tags$i(class = "bi bi-hospital fs-3 me-2", style = "color: #1e3a8a;"),
            h5(class = "m-0", style = "color: #1e3a8a !important; font-weight: 800; font-size: 1.15rem; letter-spacing: 0.04em; word-spacing: 0.15em;", "O QUE FAZER HOJE: SERVIÇO DE SAÚDE")
        ),
        p(class = "mb-0", style = "color: #1e293b !important; font-size: 1.15rem; line-height: 1.6; word-spacing: 0.05em; font-weight: 500;", info$servico_saude)
      )
    )
  })
  
  # Status do COE
  output$badge_coe_status <- renderUI({
    dados <- dados_painel()
    classe <- dados$hoje$classe
    
    if (classe == "Extremo") {
      span(class = "badge bg-danger fs-6 p-2 text-white", bs_icon("radioactive"), " CENTRO DE OPERAÇÕES DE EMERGÊNCIA (COE) ATIVADO")
    } else if (classe == "Severo") {
      span(class = "badge bg-warning text-dark fs-6 p-2", bs_icon("exclamation-circle"), " SALA DE SITUAÇÃO EM ALERTA PRÉVIO")
    } else {
      span(class = "badge bg-success fs-6 p-2 text-white", bs_icon("shield-check"), " OPERAÇÃO ROTINEIRA / NORMALIDADE")
    }
  })
  
  # Previsão D+0 a D+4
  output$grade_previsao <- renderUI({
    dados <- dados_painel()
    
    cartoes <- lapply(dados$previsoes, function(prev) {
      cfg <- matriz_niveis[[prev$classe]]
      
      div(
        class = "col text-center",
        div(
          class = "card h-100 shadow-sm border rounded-3",
          style = paste0("border-top: 6px solid ", cfg$cor_alerta, " !important;"),
          div(
            class = "card-body p-3",
            h6(class = "card-title text-muted fw-bold mb-1", prev$dia),
            p(class = "small text-muted mb-2 fw-semibold", prev$data_br),
            h3(class = "fw-bold my-2 text-dark", paste0(prev$tmax, "°C")),
            span(
              class = "badge badge-dia w-100 py-2 mb-1",
              style = paste0("background-color:", cfg$cor_alerta, "; font-weight: 700;"),
              cfg$rotulo_curto
            ),
            p(class = "mt-1 mb-0 text-muted small fw-semibold", style = "font-size: 0.78rem;", cfg$subtitulo_ehf),
            p(class = "mt-1 mb-0 text-muted small", paste("EHF:", prev$ehf))
          )
        )
      )
    })
    
    div(class = "row row-cols-1 row-cols-md-5 g-2", cartoes)
  })
  
  # QUADRO DE AÇÕES SETORIAIS EM GRADE SIMÉTRICA (2 LINHAS X 3 COLUNAS)
  output$quadro_acoes_setores <- renderUI({
    dados <- dados_painel()
    classe <- dados$hoje$classe
    acoes <- matriz_niveis[[classe]]$acoes_setores
    
    layout_columns(
      col_widths = c(4, 4, 4, 4, 4, 4),
      
      # 1. CIEVS Belém & Vigilância Epidemiológica
      card(
        class = "card-setor p-3 shadow-sm",
        h6(class = "fw-bold", bs_icon("activity"), " CIEVS Belém, Vigilância Epidemiológica & NHEs"),
        p(class = "small text-muted mb-2", "Monitoramento de rumores, avaliação de risco e busca ativa hospitalar"),
        tags$ul(class = "lista-acoes-integra", lapply(acoes$cievs_ve, tags$li))
      ),
      
      # 2. Controle de Endemias
      card(
        class = "card-setor p-3 shadow-sm",
        h6(class = "fw-bold", bs_icon("bug-fill"), " Controle de Endemias"),
        p(class = "small text-muted mb-2", "Horários de campo, rotinas de bloqueio e proteção ocupacional"),
        tags$ul(class = "lista-acoes-integra", lapply(acoes$controle_endemias, tags$li))
      ),
      
      # 3. Vigilância Sanitária e Ambiental
      card(
        class = "card-setor p-3 shadow-sm",
        h6(class = "fw-bold", bs_icon("shield-fill-check"), " Vigilância Sanitária e Ambiental"),
        p(class = "small text-muted mb-2", "Inspeção de ILPIs, cadeia de frio, água, gelo e medidas cautelares"),
        tags$ul(class = "lista-acoes-integra", lapply(acoes$vig_sanitaria_ambiental, tags$li))
      ),
      
      # 4. CEREST Saúde do Trabalhador
      card(
        class = "card-setor p-3 shadow-sm",
        h6(class = "fw-bold", bs_icon("person-workspace"), " CEREST Saúde do Trabalhador"),
        p(class = "small text-muted mb-2", "Proteção a trabalhadores ao ar livre, EPIs e denúncias"),
        tags$ul(class = "lista-acoes-integra", lapply(acoes$trabalhador, tags$li))
      ),
      
      # 5. ATENÇÃO À SAÚDE UNIFICADA (APS + URGÊNCIA/EMERGÊNCIA/SAMU/CASAS ESPECIALIZADAS)
      card(
        class = "card-setor p-3 shadow-sm",
        h6(class = "fw-bold", bs_icon("heart-pulse-fill"), " Atenção à Saúde (APS, Urgência/Emergência, SAMU e Casas Especializadas)"),
        p(class = "small text-muted mb-2", "Visitas domiciliares, climatização, resfriamento corporal e suporte intensivo"),
        tags$ul(class = "lista-acoes-integra", lapply(acoes$atencao_saude_unificada, tags$li))
      ),
      
      # 6. REGULAÇÃO E COMUNICAÇÃO EM SAÚDE UNIFICADAS (CENTRAL DE LEITOS + ASCOM)
      card(
        class = "card-setor p-3 shadow-sm",
        h6(class = "fw-bold", bs_icon("hospital"), " Regulação e Comunicação em Saúde"),
        p(class = "small text-muted mb-2", "NIR hospitalar, leitos de retaguarda, boletins oficiais e combate a boatos"),
        tags$ul(class = "lista-acoes-integra", lapply(acoes$regulacao_comunicacao, tags$li))
      )
    )
  })
  
  # Painel informativo de status da coleta
  output$painel_status_cron <- renderUI({
    dados <- dados_painel()
    
    div(
      p(strong("Status da Conexão: "), if (dados$sucesso) span(class = "badge bg-success", "Conectado / Sucesso") else span(class = "badge bg-warning text-dark", "Operando em Fallback")),
      p(strong("Origem dos Dados: "), dados$origem),
      p(strong("Última Consulta: "), dados$hora_consulta),
      p(strong("URL Oficial Consultada: "), tags$a(href = dados$fonte_url, target = "_blank", dados$fonte_url)),
      p(strong("Ciclo de Atualização Reativa: "), "A cada 10 minutos automaticamente enquanto houver usuários conectados."),
      p(strong("Coleta Automática 24/7 (CRONJOB): "), "Pode ser disparada via GitHub Actions (.github/workflows/cron_coleta_clima.yml) ou Agendador do Windows (configurar_tarefa_agendada.ps1).")
    )
  })
  
  # MAPA OFICIAL DE VIGILÂNCIA BIOCLIMÁTICA — BELÉM / PA
  output$card_mapa_belem <- renderUI({
    dados <- dados_painel()
    ind <- dados$indicadores_mapa
    
    ehf_val <- if (!is.null(ind$ehf)) ind$ehf else dados$hoje$ehf
    media_val <- if (!is.null(ind$media)) ind$media else 29.5
    hoje_val <- if (!is.null(ind$hoje)) ind$hoje else dados$hoje$tmax
    pico_val <- if (!is.null(ind$pico_habitual)) ind$pico_habitual else 34.1
    lat_val <- if (!is.null(ind$lat)) ind$lat else -1.240717
    lon_val <- if (!is.null(ind$lon)) ind$lon else -48.459911
    
    classe_hoje <- dados$hoje$classe
    info_nivel <- matriz_niveis[[classe_hoje]]
    cor_nivel <- if (!is.null(info_nivel$cor_alerta)) info_nivel$cor_alerta else "#1b5e20"

    # Leitura da malha territorial oficial de Belém (IBGE 1501402)
    caminho_geo <- if (file.exists("belem_malha.geojson")) {
      "belem_malha.geojson"
    } else if (file.exists("www/belem_malha.geojson")) {
      "www/belem_malha.geojson"
    } else {
      NULL
    }
    
    geo_json_txt <- if (!is.null(caminho_geo)) {
      paste(readLines(caminho_geo, warn = FALSE, encoding = "UTF-8"), collapse = " ")
    } else {
      "{}"
    }
    
    previsoes_json <- jsonlite::toJSON(dados$previsoes, auto_unbox = TRUE)

    # Botões dos dias operacionais (D+0 a D+4)
    botoes_dias <- lapply(seq_along(dados$previsoes), function(i) {
      p <- dados$previsoes[[i]]
      cls <- p$classe
      inf <- matriz_niveis[[cls]]
      cor_dia <- if (!is.null(inf$cor_alerta)) inf$cor_alerta else "#1b5e20"
      rotulo_curto <- if (!is.null(inf$rotulo_curto)) inf$rotulo_curto else "NÍVEL 1: NORMALIDADE"
      is_hoje <- (i == 1)
      
      tags$button(
        type = "button",
        id = paste0("btn-mapa-dia-", i - 1),
        class = paste0("btn btn-sm me-1 mb-1 ", if (is_hoje) "btn-primary shadow-sm" else "btn-outline-secondary"),
        style = paste0(
          "font-size: 0.82rem; font-weight: 600; border-radius: 20px; padding: 4px 12px; ",
          if (is_hoje) paste0("background-color: ", cor_dia, " !important; border-color: ", cor_dia, " !important; color: #ffffff !important;") else ""
        ),
        onclick = paste0("window.mudarNivelMapaR(", i - 1, ");"),
        tags$span(style = paste0("display:inline-block; width:10px; height:10px; border-radius:50%; margin-right:5px; background-color:", cor_dia, ";")),
        paste0(if (is_hoje) "Hoje " else paste0("D+", i - 1, " "), "(", p$dia, "): ", p$tmax, "°C")
      )
    })

    card(
      class = "shadow-sm mb-4 border-0 rounded-3",
      card_header(
        class = "bg-light py-2 px-3 fw-bold titulo-padrao-escuro d-flex justify-content-between align-items-center flex-wrap gap-2",
        div(
          div(class = "d-flex align-items-center gap-2",
              span(class = "text-danger", bs_icon("geo-alt-fill")),
              span(class = "fs-6", "MAPA OFICIAL DE VIGILÂNCIA BIOCLIMÁTICA — BELÉM / PA")
          ),
          div(class = "small fw-normal text-muted", style = "font-size: 0.82rem; margin-top: 1px;",
              "Malha Territorial Oficial IBGE (1501402) pintada na cor do nível vigente · Modelo EHF Ministério da Saúde")
        ),
        span(class = "badge px-3 py-2 fs-6 shadow-sm", style = "background-color: #1e3a8a; color: #ffffff;",
             bs_icon("shield-check"), " Dados Oficiais do Ministério da Saúde")
      ),
      card_body(
        class = "p-3",
        # 4 Indicadores Oficiais Dispostos Acima do Mapa: EHF, Média, Hoje, Pico habitual
        div(
          class = "row g-2 mb-3",
          # 1. EHF
          div(class = "col-6 col-md-3",
              div(class = "card p-3 border-0 shadow-sm rounded-3 h-100", style = "border-left: 5px solid #16a34a !important; background: #fff;",
                  div(class = "small text-muted fw-bold text-uppercase d-flex align-items-center gap-1",
                      bs_icon("activity"), " EHF"),
                  div(class = "d-flex align-items-baseline gap-2 mt-1",
                      h3(id = "kpi-mapa-ehf", class = "fw-bold mb-0 text-dark", as.character(ehf_val)),
                      span(id = "kpi-mapa-classe", class = "badge text-white small", style = paste0("background-color:", cor_nivel, ";"), info_nivel$rotulo_curto)
                  ),
                  div(class = "small text-muted mt-1", style = "font-size: 0.76rem;", "Fator de Excesso de Calor (MS)")
              )
          ),
          # 2. Média
          div(class = "col-6 col-md-3",
              div(class = "card p-3 border-0 shadow-sm rounded-3 h-100", style = "border-left: 5px solid #0284c7 !important; background: #fff;",
                  div(class = "small text-muted fw-bold text-uppercase d-flex align-items-center gap-1",
                      bs_icon("thermometer-half"), " Média"),
                  div(class = "d-flex align-items-baseline gap-2 mt-1",
                      h3(id = "kpi-mapa-media", class = "fw-bold mb-0 text-dark", paste0(media_val, "°C")),
                      span(class = "badge bg-primary text-white small", "Tmean")
                  ),
                  div(class = "small text-muted mt-1", style = "font-size: 0.76rem;", "Temperatura média de 24h")
              )
          ),
          # 3. Hoje
          div(class = "col-6 col-md-3",
              div(class = "card p-3 border-0 shadow-sm rounded-3 h-100", style = "border-left: 5px solid #ea580c !important; background: #fff;",
                  div(class = "small text-muted fw-bold text-uppercase d-flex align-items-center gap-1",
                      bs_icon("thermometer-sun"), " Hoje"),
                  div(class = "d-flex align-items-baseline gap-2 mt-1",
                      h3(id = "kpi-mapa-hoje", class = "fw-bold mb-0 text-dark", paste0(hoje_val, "°C")),
                      span(class = "badge bg-warning text-dark small", "Tmax")
                  ),
                  div(class = "small text-muted mt-1", style = "font-size: 0.76rem;", "Máxima prevista para hoje")
              )
          ),
          # 4. Pico habitual
          div(class = "col-6 col-md-3",
              div(class = "card p-3 border-0 shadow-sm rounded-3 h-100", style = "border-left: 5px solid #dc2626 !important; background: #fff;",
                  div(class = "small text-muted fw-bold text-uppercase d-flex align-items-center gap-1",
                      bs_icon("graph-up-arrow"), " Pico habitual"),
                  div(class = "d-flex align-items-baseline gap-2 mt-1",
                      h3(id = "kpi-mapa-pico", class = "fw-bold mb-0 text-dark", paste0(pico_val, "°C")),
                      span(class = "badge bg-danger text-white small", "P75 Clima")
                  ),
                  div(class = "small text-muted mt-1", style = "font-size: 0.76rem;", "Climatologia percentil 75 MS")
              )
          )
        ),
        
        # Barra com Mecanismo Automático de Seleção de Níveis (D+0 a D+4)
        div(
          class = "d-flex align-items-center justify-content-between flex-wrap gap-2 mb-2 p-2 rounded-2",
          style = "background: #f1f5f9; border: 1px solid #e2e8f0;",
          div(
            class = "d-flex align-items-center gap-2 flex-wrap",
            span(class = "small fw-bold text-muted text-uppercase", bs_icon("sliders"), " Alternância de Projeção no Mapa:"),
            botoes_dias
          ),
          span(class = "badge bg-light text-muted border", style = "font-size: 0.75rem;",
               "Clique para alternar o nível operacional no mapa")
        ),

        # Container do Mapa Oficial Leaflet de Belém
        tags$div(
          id = "mapa-belem-oficial-r",
          style = "height: 500px; width: 100%; border-radius: 10px; border: 1px solid #cbd5e1; z-index: 1;"
        ),
        
        # Script Nativo de Inicialização do Mapa com Malha IBGE e Pintura do Nível Vigente
        tags$script(HTML(paste0("
          (function() {
            var rawGeo = ", geo_json_txt, ";
            var previsoes = ", previsoes_json, ";
            var corVigente = '", cor_nivel, "';
            var tituloVigente = '", info_nivel$titulo_nivel, "';
            var subtituloVigente = '", info_nivel$subtitulo_ehf, "';
            var rotuloCurtoVigente = '", info_nivel$rotulo_curto, "';
            var picoHabitual = '", pico_val, "';
            
            var mapaInst = null;
            var camadaGeo = null;
            var marcadorCentro = null;
            var diaAtivoIndex = 0;
            
            var mapaCores = {
              'Sem excesso': { cor: '#1b5e20', titulo: 'NÍVEL DE CALOR 1: NORMALIDADE', sub: 'CLASSIFICAÇÃO DO EHF: SEM EXCESSO DE CALOR', rotulo: 'NÍVEL 1: NORMALIDADE' },
              'Baixo': { cor: '#ca8a04', titulo: 'NÍVEL DE CALOR 2: ATENÇÃO', sub: 'CLASSIFICAÇÃO DO EHF: BAIXO', rotulo: 'NÍVEL 2: ATENÇÃO' },
              'Severo': { cor: '#ea580c', titulo: 'NÍVEL DE CALOR 3: ALERTA', sub: 'CLASSIFICAÇÃO DO EHF: SEVERO', rotulo: 'NÍVEL 3: ALERTA' },
              'Extremo': { cor: '#dc2626', titulo: 'NÍVEL DE CALOR 4: EMERGÊNCIA', sub: 'CLASSIFICAÇÃO DO EHF: EXTREMO', rotulo: 'NÍVEL 4: EMERGÊNCIA' }
            };

            function gerarPopup(infoDia, cor) {
              return '<div style=\"min-width: 250px; font-family: system-ui, -apple-system, sans-serif;\">' +
                '<div style=\"border-bottom: 2px solid ' + cor + '; padding-bottom: 5px; margin-bottom: 8px;\">' +
                  '<h6 style=\"margin: 0; font-weight: 800; color: #1e3a8a; font-size: 1.05rem;\">MUNICÍPIO DE BELÉM - PA</h6>' +
                  '<div style=\"font-size: 0.78rem; color: #64748b; font-weight: 600;\">Código IBGE: 1501402 · Ministério da Saúde</div>' +
                '</div>' +
                '<div style=\"background: #f8fafc; border-radius: 8px; padding: 10px; margin-bottom: 8px; border: 1px solid #e2e8f0; font-size: 0.85rem;\">' +
                  '<div style=\"display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;\">' +
                    '<span style=\"color: #475569; font-weight: 600;\">Nível de Calor:</span>' +
                    '<span style=\"font-weight: 800; color: ' + cor + ';\">' + (infoDia.titulo_nivel || '') + '</span>' +
                  '</div>' +
                  '<div style=\"display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;\">' +
                    '<span style=\"color: #64748b;\">Classificação EHF:</span>' +
                    '<span style=\"font-weight: 600; color: #1e293b;\">' + (infoDia.subtitulo_ehf || '') + '</span>' +
                  '</div>' +
                  '<div style=\"display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;\">' +
                    '<span style=\"color: #64748b;\">Fator EHF:</span>' +
                    '<code>' + infoDia.ehf + '</code>' +
                  '</div>' +
                  '<div style=\"display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;\">' +
                    '<span style=\"color: #64748b;\">Temp. Máxima:</span>' +
                    '<span style=\"font-weight: 800; color: #b91c1c; font-size: 1.05rem;\">' + infoDia.tmax + ' °C</span>' +
                  '</div>' +
                  '<div style=\"display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;\">' +
                    '<span style=\"color: #64748b;\">Temp. Média (24h):</span>' +
                    '<span style=\"font-weight: 700; color: #0284c7;\">' + (infoDia.tmean || '29.5') + ' °C</span>' +
                  '</div>' +
                  '<div style=\"display: flex; justify-content: space-between; align-items: center;\">' +
                    '<span style=\"color: #64748b;\">Pico habitual (P75):</span>' +
                    '<span style=\"font-weight: 700; color: #dc2626;\">' + picoHabitual + ' °C</span>' +
                  '</div>' +
                '</div>' +
                '<div style=\"font-size: 0.73rem; color: #94a3b8; text-align: center;\">' +
                  'Malha Territorial Oficial IBGE · Vigilância em Saúde (SESMA/MS)' +
                '</div>' +
              '</div>';
            }

            window.mudarNivelMapaR = function(idx) {
              if (!previsoes || !previsoes[idx]) return;
              diaAtivoIndex = idx;
              var p = previsoes[idx];
              var conf = mapaCores[p.classe] || mapaCores['Sem excesso'];
              var cor = conf.cor;

              // Atualiza polígono do mapa
              if (camadaGeo) {
                camadaGeo.setStyle({
                  fillColor: cor,
                  color: cor,
                  weight: 3,
                  opacity: 0.95,
                  fillOpacity: 0.55
                });
                camadaGeo.bindPopup(gerarPopup(p, cor));
              }

              // Atualiza KPIs
              var elEhf = document.getElementById('kpi-mapa-ehf');
              if (elEhf) elEhf.innerText = p.ehf;
              
              var elClasse = document.getElementById('kpi-mapa-classe');
              if (elClasse) {
                elClasse.innerText = conf.rotulo;
                elClasse.style.backgroundColor = cor;
              }

              var elMedia = document.getElementById('kpi-mapa-media');
              if (elMedia) elMedia.innerText = (p.tmean || '29.5') + '°C';

              var elHoje = document.getElementById('kpi-mapa-hoje');
              if (elHoje) elHoje.innerText = p.tmax + '°C';

              // Atualiza botões
              for (var i = 0; i < previsoes.length; i++) {
                var btn = document.getElementById('btn-mapa-dia-' + i);
                if (btn) {
                  if (i === idx) {
                    btn.className = 'btn btn-sm me-1 mb-1 btn-primary shadow-sm';
                    btn.style.backgroundColor = cor + ' !important';
                    btn.style.borderColor = cor + ' !important';
                    btn.style.color = '#ffffff !important';
                  } else {
                    btn.className = 'btn btn-sm me-1 mb-1 btn-outline-secondary';
                    btn.style.backgroundColor = '';
                    btn.style.borderColor = '';
                    btn.style.color = '';
                  }
                }
              }
            };

            function iniciarMapa() {
              var el = document.getElementById('mapa-belem-oficial-r');
              if (!el) return;

              if (typeof L === 'undefined') {
                if (!document.getElementById('leaflet-cdn-script')) {
                  var lcss = document.createElement('link');
                  lcss.rel = 'stylesheet';
                  lcss.href = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';
                  document.head.appendChild(lcss);

                  var ljs = document.createElement('script');
                  ljs.id = 'leaflet-cdn-script';
                  ljs.src = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js';
                  ljs.onload = function() { setTimeout(iniciarMapa, 100); };
                  document.head.appendChild(ljs);
                } else {
                  setTimeout(iniciarMapa, 150);
                }
                return;
              }

              if (window._mapaBelemR) {
                try { window._mapaBelemR.remove(); } catch(e) {}
                window._mapaBelemR = null;
              }

              mapaInst = L.map('mapa-belem-oficial-r', {
                center: [-1.36, -48.46],
                zoom: 11,
                scrollWheelZoom: true
              });
              window._mapaBelemR = mapaInst;

              L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 18,
                attribution: '&copy; OpenStreetMap | Ministério da Saúde · CIEVS Belém / SESMA · IBGE'
              }).addTo(mapaInst);

              function renderizarPoligono(geoJsonData) {
                camadaGeo = L.geoJSON(geoJsonData, {
                  style: {
                    fillColor: corVigente,
                    color: corVigente,
                    weight: 3,
                    opacity: 0.95,
                    fillOpacity: 0.55
                  },
                  onEachFeature: function(feat, layer) {
                    var p0 = (previsoes && previsoes[0]) ? previsoes[0] : { ehf: 0, tmax: 34.8, tmean: 29.5, titulo_nivel: tituloVigente, subtitulo_ehf: subtituloVigente };
                    layer.bindPopup(gerarPopup(p0, corVigente));
                    layer.on('mouseover', function(e) {
                      e.target.setStyle({ weight: 4, fillOpacity: 0.7 });
                    });
                    layer.on('mouseout', function(e) {
                      e.target.setStyle({ weight: 3, fillOpacity: 0.55 });
                    });
                  }
                }).addTo(mapaInst);

                try {
                  mapaInst.fitBounds(camadaGeo.getBounds(), { padding: [15, 15] });
                } catch(e) {}
              }

              if (rawGeo && rawGeo.features && rawGeo.features.length > 0) {
                renderizarPoligono(rawGeo);
              } else {
                fetch('https://servicodados.ibge.gov.br/api/v3/malhas/municipios/1501402?formato=application/vnd.geo+json')
                  .then(function(r) { return r.json(); })
                  .then(function(data) { renderizarPoligono(data); })
                  .catch(function(err) {
                    console.warn('Fallback para círculo:', err);
                    L.circle([-1.240717, -48.459911], {
                      color: corVigente,
                      fillColor: corVigente,
                      fillOpacity: 0.55,
                      radius: 9500,
                      weight: 3
                    }).addTo(mapaInst);
                  });
              }

              // Legenda dos 4 Níveis Oficiais
              var legenda = L.control({ position: 'bottomright' });
              legenda.onAdd = function() {
                var div = L.DomUtil.create('div', 'info legend shadow-sm');
                div.style.background = '#ffffff';
                div.style.padding = '8px 12px';
                div.style.borderRadius = '8px';
                div.style.border = '1px solid #cbd5e1';
                div.style.fontSize = '12px';
                div.style.lineHeight = '1.5';
                div.innerHTML = '<b style=\"color:#1e3a8a;\">Níveis de Calor (EHF/MS)</b><br>' +
                  '<div style=\"display:flex;align-items:center;gap:6px;margin-top:4px;\">' +
                    '<span style=\"background:#1b5e20;width:14px;height:14px;display:inline-block;border-radius:3px;\"></span>' +
                    '<span>Nível 1: Normalidade</span>' +
                  '</div>' +
                  '<div style=\"display:flex;align-items:center;gap:6px;margin-top:2px;\">' +
                    '<span style=\"background:#ca8a04;width:14px;height:14px;display:inline-block;border-radius:3px;\"></span>' +
                    '<span>Nível 2: Atenção</span>' +
                  '</div>' +
                  '<div style=\"display:flex;align-items:center;gap:6px;margin-top:2px;\">' +
                    '<span style=\"background:#ea580c;width:14px;height:14px;display:inline-block;border-radius:3px;\"></span>' +
                    '<span>Nível 3: Alerta</span>' +
                  '</div>' +
                  '<div style=\"display:flex;align-items:center;gap:6px;margin-top:2px;\">' +
                    '<span style=\"background:#dc2626;width:14px;height:14px;display:inline-block;border-radius:3px;\"></span>' +
                    '<span>Nível 4: Emergência</span>' +
                  '</div>';
                return div;
              };
              legenda.addTo(mapaInst);

              setTimeout(function() { mapaInst.invalidateSize(); }, 350);
              setTimeout(function() { mapaInst.invalidateSize(); }, 800);
            }

            setTimeout(iniciarMapa, 200);
          })();
        ")))
      )
    )
  })
}

# ==============================================================================
# 5. EXECUÇÃO DA APLICAÇÃO
# ==============================================================================
shinyApp(ui = ui, server = server)
