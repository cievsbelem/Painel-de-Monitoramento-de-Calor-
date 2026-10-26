// ==============================================================================
// SISTEMA OFICIAL DE VIGILÂNCIA DE EXCESSO DE CALOR - CIEVS BELÉM / SESMA
// Aplicação Web Estática para GitHub Pages com Alimentação via GitHub Actions CRON
// ==============================================================================

const matrizNiveis = {
  "Sem excesso": {
    classe: "Sem excesso",
    tituloNivel: "NÍVEL DE CALOR 1: NORMALIDADE",
    subtituloEhf: "CLASSIFICAÇÃO DO EHF: SEM EXCESSO DE CALOR",
    rotuloCurto: "NÍVEL 1: NORMALIDADE",
    corAlerta: "#1b5e20",
    corTexto: "#ffffff",
    icone: "bi-check-circle-fill",
    statusMs: "CLASSIFICAÇÃO DO EHF: SEM EXCESSO DE CALOR",
    nivelContingencia: "NÍVEL DE CALOR 1: NORMALIDADE",
    populacao: "Rotina, sem cuidado extra.",
    servicoSaude: "Vigilância de rotina, com a rede em prontidão.",
    coeBadge: '<span class="badge bg-success fs-6 p-2 text-white"><i class="bi bi-shield-check"></i> OPERAÇÃO ROTINEIRA / NORMALIDADE</span>',
    acoesSetores: {
      cievsVe: [
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
      ],
      controleEndemias: [
        "Visita Domiciliar: Inspeção de imóveis para identificação de criadouros do Aedes aegypti. Orientação aos moradores sobre prevenção e eliminação de focos.",
        "Instalação e Manutenção de Estações Disseminadoras de Larvicidas (EDLs).",
        "Monitoramento Entomológico: Bloqueio de Transmissão.",
        "Controle Químico.",
        "Inspeção de Pontos Estratégicos (PE).",
        "Inspeção de Imóveis Especiais (IE).",
        "Educação em Saúde.",
        "Registro e Monitoramento das Atividades."
      ],
      vigSanitariaAmbiental: [
        "Vigilância Sanitária: Elaborar e manter atualizado o Plano Operacional de atuação da Vigilância Sanitária para eventos de calor extremo.",
        "Vigilância Sanitária: Mapear e manter cadastro atualizado dos estabelecimentos prioritários para fiscalização, incluindo serviços de saúde, instituições de longa permanência para idosos, serviços de alimentação, estabelecimentos de ensino, eventos de massa e demais locais de interesse sanitário.",
        "Vigilância Sanitária: Capacitar as equipes para atuação em situações de calor extremo e atualizar os protocolos de inspeção sanitária.",
        "Vigilância Sanitária: Desenvolver ações educativas e orientações técnicas aos estabelecimentos sujeitos à Vigilância Sanitária quanto às medidas de prevenção dos riscos relacionados ao calor.",
        "Vigilância Sanitária: Integrar-se ao CIEVS e demais áreas da Vigilância em Saúde para monitoramento do cenário epidemiológico e climático.",
        "Vigilância Ambiental: Classificar o monitoramento da qualidade da água, qualidade do ar, queimadas e vetores.",
        "Vigilância Ambiental: Monitorar áreas com risco de desabastecimento de água.",
        "Vigilância Ambiental: Apoiar ações de prevenção e controle ambiental."
      ],
      trabalhador: [
        "Realizar ações de educação em saúde com os grupos de trabalhadores vulneráveis voltadas à prevenção do impacto do calor nos trabalhadores.",
        "Articular com empregadores/serviços privados e públicos a distribuição de EPIs para os grupos de trabalhadores vulneráveis (trabalhadores ao ar livre e trabalhadores expostos a fontes de calor).",
        "Capacitar empregadores/serviços públicos e privados e estabelecimentos de saúde a preencher as fichas de notificação do SINAN relacionadas ao trabalho de trabalhadores que tenham sofrido impactos na saúde devido ao calor.",
        "Capacitar os grupos de trabalhadores vulneráveis sobre os sinais e sintomas da exposição ao calor excessivo.",
        "Articular com empregadores/serviços públicos e privados o ajuste da carga horária de grupos de trabalhadores vulneráveis nos Níveis de alerta 1, 2 e 3.",
        "Articular um fluxograma de envio de fichas de notificação do SINAN.",
        "Criar canal de denúncia para trabalhadores que observarem serviços públicos e privados que não cumpram as recomendações de prevenção ao calor dos níveis 1, 2 e 3."
      ],
      atencaoSaude: [
        "DAS: Avaliar a capacidade operacional da rede de atenção em saúde.",
        "DAS: Monitorar a disponibilidade de profissionais, medicamentos, insumos e equipamentos.",
        "DAS: Reforçar a comunicação entre os pontos da rede assistencial.",
        "APS: Realizar ações educativas nas unidades de saúde e no território.",
        "APS: Realizar busca ativa e acompanhamento dos grupos vulneráveis.",
        "APS: Orientar usuários quanto a hidratação, alimentação, proteção contra o calor e reconhecimento precoce dos sinais de gravidade.",
        "DAES: Mapear a capacidade de climatização das salas de acolhimento e retaguarda de usuários crônicos e especializados.",
        "SAMU: Revisar protocolos assistenciais e verificar equipamentos e insumos."
      ],
      regulacaoComunicacao: [
        "Central de Leitos: Monitorar diariamente a disponibilidade de leitos e serviços especializados.",
        "Central de Leitos: Revisar fluxos de encaminhamento conforme necessidade.",
        "Central de Leitos: Mapear a capacidade de climatização das enfermarias e UTIs da rede contratualizada para identificar pontos críticos de suporte térmico.",
        "Central de Leitos: Manter Censo hospitalar diário atualizado; Relatório de conformidade de climatização hospitalar.",
        "ASCOM: Combater informações falsas por meio da comunicação de risco.",
        "ASCOM: Orientar a população sobre medidas de prevenção em canais de atendimento."
      ]
    }
  },
  
  "Baixo": {
    classe: "Baixo",
    tituloNivel: "NÍVEL DE CALOR 2: ATENÇÃO",
    subtituloEhf: "CLASSIFICAÇÃO DO EHF: BAIXO",
    rotuloCurto: "NÍVEL 2: ATENÇÃO",
    corAlerta: "#ca8a04",
    corTexto: "#ffffff",
    icone: "bi-exclamation-circle-fill",
    statusMs: "CLASSIFICAÇÃO DO EHF: BAIXO",
    nivelContingencia: "NÍVEL DE CALOR 2: ATENÇÃO",
    populacao: "Beba água ao longo do dia, mesmo sem sede.",
    servicoSaude: "Comunicar os sinais de mal-estar pelo calor e reforçar a hidratação, com atenção aos grupos de risco.",
    coeBadge: '<span class="badge fs-6 p-2 text-white" style="background-color: #ca8a04 !important;"><i class="bi bi-shield-exclamation"></i> OPERAÇÃO EM NÍVEL DE ATENÇÃO</span>',
    acoesSetores: {
      cievsVe: [
        "CIEVS: Monitorar DNC relacionados à variação do clima.",
        "CIEVS: Ativar monitoramento diário dos eventos de notificações relacionados à exposição ao calor extremo.",
        "CIEVS: Produzir informes epidemiológicos periodicamente.",
        "CIEVS: Compartilhar informações com setores estratégicos.",
        "CIEVS: Realizar a avaliação de risco semanalmente ou sempre que necessário.",
        "CIEVS: Monitorar eventos de massa e ou de grande porte na cidade.",
        "Vigilância Epidemiológica: Emissão de Boletins epidemiológicos em conjunto com CIEVS para nortear ações da assistência à saúde relacionadas ao calor no intuito de melhorar estratégias de prevenção e resposta.",
        "Vigilância Epidemiológica: Monitoramento epidemiológico através da avaliação dos impactos das ondas de calor na saúde da população através da detecção do aumento do número de casos de atendimentos, notificações, internações e óbitos associados a alta temperatura, especialmente em grupos vulneráveis.",
        "Vigilância Epidemiológica: Reuniões intersetoriais sempre que necessário para planejamento, monitoramento, avaliação e resposta aos eventos climáticos.",
        "NHE: Intensificação de busca ativa em prontuários eletrônicos e presencial de atendimentos relacionados à exposição de calor extremo.",
        "NHE: Fortalecimento da notificação e comunicação imediata dos casos."
      ],
      controleEndemias: [
        "Período da Manhã (07:30 às 10:30): Visitas domiciliares, inspeção de imóveis, tratamento focal, instalação e manutenção de EDLs, instalação e leitura de ovitrampas, levantamento entomológicos, controle mecânico de criadouros.",
        "Período da Tarde: Priorizar as atividades em Imóveis Especiais (IE).",
        "Medidas de Proteção dos profissionais ACE: Pausas de 10 minutos a cada hora, hidratação, resfriamento, e reaplicação de protetor solar."
      ],
      vigSanitariaAmbiental: [
        "Vigilância Sanitária: Intensificar inspeções em estabelecimentos prioritários (hospitais, UPAs, ILPIs, escolas, creches, supermercados, serviços de alimentação, hotéis, shopping centers, clubes recreativos e eventos de massa).",
        "Vigilância Sanitária: Verificar as condições de abastecimento de água, climatização, conservação de alimentos, funcionamento da cadeia de frio e armazenamento de medicamentos termolábeis.",
        "Vigilância Sanitária: Orientar os responsáveis pelos estabelecimentos quanto às medidas preventivas para redução dos riscos decorrentes do calor extremo.",
        "Vigilância Sanitária: Intensificar a fiscalização das condições higiênico-sanitárias dos serviços sujeitos à Vigilância Sanitária.",
        "Vigilância Sanitária: Compartilhar informações relevantes com o CIEVS para subsidiar a avaliação de risco.",
        "Vigilância Ambiental: Intensificar o monitoramento do desabastecimento de água.",
        "Vigilância Ambiental: Reforçar as ações de fiscalização em ambientes de assistência à saúde e serviços essenciais."
      ],
      trabalhador: [
        "Monitorar a distribuição de EPIs para os grupos de trabalhadores vulneráveis (trabalhadores ao ar livre e expostos a fontes de calor).",
        "Monitorar a realização de medidas protetivas dos empregadores/serviços públicos e privados que contenham grupos de trabalhadores vulneráveis.",
        "Monitorar a saúde dos grupos de trabalhadores vulneráveis através das fichas de notificação relacionadas ao trabalho do SINAN.",
        "Contatar os serviços de medicina do trabalho dos serviços públicos ou privados com grupos de trabalhadores vulneráveis para acompanhamento de situação de saúde dos trabalhadores.",
        "Ativar o canal de denúncias de inconformidades nas recomendações de prevenção."
      ],
      atencaoSaude: [
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
      ],
      regulacaoComunicacao: [
        "Central de Leitos: Emitir alerta interno para os núcleos internos de regulação (NIR) dos hospitais ao atingir sensação térmica de até 39°C.",
        "Central de Leitos: Monitorar o aumento de pedidos de transferência de pacientes nas UPAs e HPSMs com foco em CIDs de eixos distúrbios hidroeletrolíticos, cardiorrespiratório, gastrointestinal e Arboviroses.",
        "ASCOM: Intensificar campanhas educativas, divulgar boletins e orientações oficiais."
      ]
    }
  },
  
  "Severo": {
    classe: "Severo",
    tituloNivel: "NÍVEL DE CALOR 3: ALERTA",
    subtituloEhf: "CLASSIFICAÇÃO DO EHF: SEVERO",
    rotuloCurto: "NÍVEL 3: ALERTA",
    corAlerta: "#ea580c",
    corTexto: "#ffffff",
    icone: "bi-thermometer-half",
    statusMs: "CLASSIFICAÇÃO DO EHF: SEVERO",
    nivelContingencia: "NÍVEL DE CALOR 3: ALERTA",
    populacao: "Evite o sol das 10h às 16h, procure sombra e beba bastante água.",
    servicoSaude: "Intensificar a comunicação de risco, orientar pontos de hidratação e priorizar o cuidado a idosos, crianças, gestantes e pessoas com doenças crônicas.",
    coeBadge: '<span class="badge fs-6 p-2 text-white" style="background-color: #ea580c !important;"><i class="bi bi-exclamation-circle"></i> SALA DE SITUAÇÃO EM ALERTA PRÉVIO</span>',
    acoesSetores: {
      cievsVe: [
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
      ],
      controleEndemias: [
        "Período da Manhã (07:00 às 10:30): Priorizar exclusivamente tratamento de imóveis positivos, controle de focos em áreas prioritárias, instalação e manutenção de EDL, leitura de ovitrampas, atendimentos decorrentes de denúncias classificadas como prioritárias, inspeção em pontos estratégicos.",
        "Após as 10:30: Suspender visitas domiciliares de rotina.",
        "Executar Atividades Internas: Atividades em imóveis especiais, digitação de produção, consolidação de dados, planejamento das equipes, capacitações, educação em saúde em ambientes climatizados e reuniões técnicas.",
        "Medidas de Proteção: Pausa de 15 minutos por hora, reforço da hidratação, monitoramento contínuo das equipes, encerramento imediato das atividades em caso de mal-estar."
      ],
      vigSanitariaAmbiental: [
        "Vigilância Sanitária: Priorizar inspeções em serviços de saúde, instituições de longa permanência para idosos, serviços de alimentação e eventos de grande porte.",
        "Vigilância Sanitária: Intensificar a fiscalização da qualidade da água destinada ao consumo humano, fabricação e comercialização de gelo e alimentos perecíveis.",
        "Vigilância Sanitária: Verificar o funcionamento de sistemas de climatização, abastecimento de água, armazenamento de medicamentos e produtos sujeitos ao controle sanitário.",
        "Vigilância Sanitária: Emitir orientações e determinar medidas corretivas imediatas para eliminação de riscos sanitários.",
        "Vigilância Sanitária: Apoiar o CIEVS e o COE com informações provenientes das ações de fiscalização sanitária.",
        "Vigilância Ambiental: Intensificar inspeções em áreas críticas."
      ],
      trabalhador: [
        "Monitorar a adaptação de carga horária dos grupos de trabalhadores vulneráveis (trabalhadores ao ar livre e expostos ao calor).",
        "Orientar os grupos de trabalhadores vulneráveis a procurar os serviços de saúde na presença de sinais e sintomas da exposição ao calor excessivo.",
        "Monitorar diariamente as fichas de notificação relacionadas ao trabalho do SINAN.",
        "Ativar o canal de denúncias de inconformidades nas recomendações de prevenção."
      ],
      atencaoSaude: [
        "DAS: Reorganizar a rede assistencial e ampliar a capacidade de atendimento, caso necessário.",
        "APS: Priorizar atendimento a grupos vulneráveis e ampliar o horário de ações estratégicas, evitando ações externas no calor extremo.",
        "APS: Intensificar vigilância territorial e notificações imediatas.",
        "DAES: Intensificar o monitoramento e acompanhamento dos usuários em maior vulnerabilidade clínica e psicossocial com risco de descompensação (incluindo busca ativa).",
        "DAES: Reorganizar as atividades assistenciais e coletivas para ambientes climatizados com conforto térmico, adequando horários.",
        "DAES: Fortalecer a articulação com a APS, Urgência e Emergência e demais pontos da Rede de Atenção Psicossocial (RAPS).",
        "DAES: Disponibilizar água potável durante ações externas e ofertar ambiente para hidratação e recuperação térmica.",
        "DAES: Garantir disponibilização de EPIs aos servidores em atividades externas.",
        "SAMU: Reforçar equipes e ambulâncias."
      ],
      regulacaoComunicacao: [
        "Central de Leitos: Mapear e reservar 'Leitos de Retaguarda Climática' em parceria com a DAS/DAES para demandas urgentes de desidratação e síncope térmica.",
        "Central de Leitos: Realizar reuniões extraordinárias de gerenciamento de capacidade com os hospitais para agilizar altas seguras.",
        "Central de Leitos: Monitorar taxa de ocupação de leitos de retaguarda e giro de leito nas clínicas médica e pediátrica.",
        "ASCOM: Divulgar alertas oficiais e intensificar a divulgação de medidas de autoproteção à exposição solar.",
        "ASCOM: Combater a desinformação com transparência."
      ]
    }
  },
  
  "Extremo": {
    classe: "Extremo",
    tituloNivel: "NÍVEL DE CALOR 4: EMERGÊNCIA",
    subtituloEhf: "CLASSIFICAÇÃO DO EHF: EXTREMO",
    rotuloCurto: "NÍVEL 4: EMERGÊNCIA",
    corAlerta: "#dc2626",
    corTexto: "#ffffff",
    icone: "bi-exclamation-triangle-fill",
    statusMs: "CLASSIFICAÇÃO DO EHF: EXTREMO",
    nivelContingencia: "NÍVEL DE CALOR 4: EMERGÊNCIA",
    populacao: "Hidrate-se e, se houver mal-estar, procure o posto de saúde ou ligue 192 (SAMU).",
    servicoSaude: "Reforçar o atendimento aos grupos vulneráveis e seguir o plano local de enfrentamento ao calor extremo.",
    coeBadge: '<span class="badge fs-6 p-2 text-white" style="background-color: #dc2626 !important;"><i class="bi bi-radioactive"></i> CENTRO DE OPERAÇÕES DE EMERGÊNCIA (COE) ATIVADO</span>',
    acoesSetores: {
      cievsVe: [
        "CIEVS: Apoiar a ativação do COE.",
        "CIEVS: Monitorar a ocupação de leitos.",
        "CIEVS: Realizar a avaliação de risco considerando excesso de demanda de atendimentos e colapso da rede.",
        "Vigilância Epidemiológica: Ampliar capacidade operacional e priorizar o aumento das equipes de respostas.",
        "Vigilância Epidemiológica: Intensificar monitoramento da morbidade e mortalidades.",
        "Vigilância Epidemiológica: Elaborar boletins de informes diários.",
        "NHE: Apoiar na execução de protocolos internos de Contingenciamento.",
        "NHE: Monitorar excesso de atendimentos e óbitos relacionados ao calor extremo e garantir a comunicação oportuna por meio da notificação."
      ],
      controleEndemias: [
        "Atividades Externas: Suspensas temporariamente até redução dos níveis de calor.",
        "Manutenção Apenas das Atividades de ações de Bloqueio em Surtos ou Epidemias, mediante avaliação técnica e de atividades indispensáveis determinadas pela vigilância em saúde.",
        "Atividades Internas: Digitação da Produção, Georreferenciamento, planejamento operacional, revisão de mapas, elaboração de relatórios, capacitações, educação permanente, preparação de materiais educativos.",
        "Medidas de Proteção do trabalhador (ACE): Suspensão das atividades ao ar livre durante o período crítico, permanência em ambientes cobertos e ventilados ou climatizados, hidratação permanente, acompanhamento dos servidores com fatores de risco, avaliação contínua da necessidade de manutenção do nível de emergência."
      ],
      vigSanitariaAmbiental: [
        "Vigilância Sanitária: Executar operações extraordinárias de fiscalização nos estabelecimentos considerados críticos e essenciais.",
        "Vigilância Sanitária: Fiscalizar continuamente hospitais, UPAs, ILPIs, pontos de hidratação, serviços de alimentação, eventos de massa e demais locais com grande concentração de pessoas.",
        "Vigilância Sanitária: Adotar medidas administrativas previstas na legislação sanitária, incluindo apreensão de produtos impróprios, inutilização de alimentos, interdição cautelar de equipamentos, setores ou estabelecimentos quando constatado risco iminente à saúde.",
        "Vigilância Sanitária: Monitorar as condições sanitárias do abastecimento de água, alimentos, medicamentos e produtos sujeitos ao controle sanitário durante a emergência.",
        "Vigilância Sanitária: Integrar as ações do Centro de Operações de Emergência (COE), fornecendo informações técnicas e apoiando as decisões para redução dos riscos sanitários.",
        "Vigilância Ambiental: Atuar em áreas de calor extremo.",
        "Vigilância Ambiental: Intensificar ações de saneamento e controle ambiental."
      ],
      trabalhador: [
        "CEREST: Articular a suspensão total de atividades pesadas e exposição solar direta junto a órgãos de fiscalização do trabalho.",
        "CEREST: Atendimento e acolhimento imediato a trabalhadores acometidos por exaustão ou síncope térmica.",
        "CEREST: Monitoramento ininterrupto de notificações compulsórias no SINAN de agravos decorrentes de calor."
      ],
      atencaoSaude: [
        "DAS: Garantir funcionamento da rede de atenção à saúde e reorganizar serviços conforme a demanda.",
        "APS: Manter atendimento prioritário aos grupos vulneráveis e monitoramento intensivo aos pacientes de risco.",
        "APS: Apoiar ações comunitárias de hidratação e proteção.",
        "DAES: Garantir a continuidade dos atendimentos essenciais, priorizando usuários em situação de crise, maior vulnerabilidade clínica e psicossocial (com busca ativa).",
        "DAES: Reorganizar os processos de trabalho e as equipes para assegurar a manutenção da assistência na emergência.",
        "DAES: Intensificar a articulação com a APS, Urgência e Emergência, Defesa Civil e RAPS.",
        "DAES: Atuar como ponto de apoio aos usuários ofertando hidratação, ambiente climatizado e higiene pessoal.",
        "SAMU: Ampliar capacidade operacional, responder rapidamente às urgências e apoiar o transporte de pacientes."
      ],
      regulacaoComunicacao: [
        "Central de Leitos: Ativar o plano de contingência e reserva leitos exclusivos para agravos sensíveis ao clima.",
        "Central de Leitos: Suspensão temporária de cirurgias eletivas que demandem leitos de UTI/enfermaria pós-operatória.",
        "Central de Leitos: Atuar conjuntamente ao CISC, CIEVS e COE para gerenciar o risco de colapso da rede e saturação de leitos.",
        "Central de Leitos: Monitorar percentual de solicitações de leitos de urgência atendidas e taxa de saturação de UTIs.",
        "ASCOM: Emitir boletins diários e orientar a população sobre medidas de proteção.",
        "ASCOM: Manter comunicação transparente com a imprensa e sociedade."
      ]
    }
  }
};

let dadosClimaCache = null;
let tempoRestante = 600; // 10 minutos em segundos

function normalizarClasse(cls) {
  if (!cls) return "Sem excesso";
  const c = cls.trim().toLowerCase();
  if (c.includes("normal") || c.includes("sem") || c.includes("nenhum")) return "Sem excesso";
  if (c.includes("baixo") || c.includes("moderado") || c.includes("atenção") || c.includes("atencao")) return "Baixo";
  if (c.includes("severo") || c.includes("alerta") || c.includes("laranja")) return "Severo";
  if (c.includes("extremo") || c.includes("emergência") || c.includes("emergencia") || c.includes("vermelho")) return "Extremo";
  return "Sem excesso";
}

// Renderiza a interface a partir do JSON de dados
function renderizarPainel(dados) {
  dadosClimaCache = dados;
  const classeHoje = normalizarClasse(dados.hoje.classe);
  const infoNivel = matrizNiveis[classeHoje] || matrizNiveis["Sem excesso"];
  
  // 1. Banner Pulsante
  const blocoAlerta = document.getElementById("bloco-alerta");
  if (blocoAlerta) {
    blocoAlerta.style.backgroundColor = infoNivel.corAlerta;
    blocoAlerta.style.border = "3px solid rgba(255,255,255,0.7)";
    blocoAlerta.innerHTML = `
      <div class="row align-items-center text-white">
        <div class="col-md-2 text-center">
          <i class="bi ${infoNivel.icone}" style="font-size: 4.8rem; color: #ffffff !important;"></i>
        </div>
        <div class="col-md-7 text-start">
          <div class="mb-2">
            <span class="badge badge-alerta-inner px-3 py-1 fw-bold text-uppercase">CIEVS BELÉM · SESMA</span>
            <span class="badge badge-alerta-inner px-2 py-1 ms-2 fw-normal">DATA: ${dados.hoje.data_br || dados.data_base_br}</span>
          </div>
          <h1 class="fw-black m-0 tracking-tight text-white display-6" style="font-weight: 900; letter-spacing: -0.01em;">${infoNivel.tituloNivel}</h1>
          <div class="mt-2 text-white fw-bold opacity-90" style="font-size: 1.15rem; letter-spacing: 0.03em;">
            ${infoNivel.subtituloEhf}
          </div>
        </div>
        <div class="col-md-3 text-center border-start border-white-50">
          <h6 class="text-uppercase opacity-75 mb-1 text-white">Temperatura Prevista</h6>
          <h2 class="fw-bold mb-0 text-white">${dados.hoje.tmax} °C</h2>
          <span class="badge badge-alerta-inner mt-2">EHF Diário: ${dados.hoje.ehf}</span>
        </div>
      </div>
    `;
  }
  
  // 2. Quadro O que fazer hoje
  const quadroOrientacoes = document.getElementById("quadro-orientacoes");
  if (quadroOrientacoes) {
    quadroOrientacoes.innerHTML = `
      <div class="row g-3">
        <div class="col-md-6">
          <div class="p-3 p-md-4 rounded-3 border shadow-sm bg-white h-100" style="border-left: 5px solid #1e3a8a !important;">
            <div class="d-flex align-items-center mb-3">
              <i class="bi bi-people-fill fs-3 me-2" style="color: #1e3a8a;"></i>
              <h5 class="m-0" style="color: #1e3a8a !important; font-weight: 800; font-size: 1.15rem; letter-spacing: 0.04em; word-spacing: 0.15em;">O QUE FAZER HOJE: POPULAÇÃO</h5>
            </div>
            <p class="mb-0" style="color: #1e293b !important; font-size: 1.15rem; line-height: 1.6; word-spacing: 0.05em; font-weight: 500;">${infoNivel.populacao}</p>
          </div>
        </div>
        <div class="col-md-6">
          <div class="p-3 p-md-4 rounded-3 border shadow-sm bg-white h-100" style="border-left: 5px solid #1e3a8a !important;">
            <div class="d-flex align-items-center mb-3">
              <i class="bi bi-hospital fs-3 me-2" style="color: #1e3a8a;"></i>
              <h5 class="m-0" style="color: #1e3a8a !important; font-weight: 800; font-size: 1.15rem; letter-spacing: 0.04em; word-spacing: 0.15em;">O QUE FAZER HOJE: SERVIÇO DE SAÚDE</h5>
            </div>
            <p class="mb-0" style="color: #1e293b !important; font-size: 1.15rem; line-height: 1.6; word-spacing: 0.05em; font-weight: 500;">${infoNivel.servicoSaude}</p>
          </div>
        </div>
      </div>
    `;
  }
  
  // 3. Previsão Operacional de Calor (D+0 a D+4)
  const gradePrevisao = document.getElementById("grade-previsao");
  if (gradePrevisao && dados.previsoes) {
    let htmlPrevisoes = '<div class="row row-cols-1 row-cols-md-5 g-2">';
    dados.previsoes.forEach(prev => {
      const clsPrev = normalizarClasse(prev.classe);
      const confPrev = matrizNiveis[clsPrev] || matrizNiveis["Sem excesso"];
      htmlPrevisoes += `
        <div class="col text-center">
          <div class="card h-100 shadow-sm border rounded-3" style="border-top: 6px solid ${confPrev.corAlerta} !important;">
            <div class="card-body p-3">
              <h6 class="card-title text-muted fw-bold mb-1">${prev.dia}</h6>
              <p class="small text-muted mb-2 fw-semibold">${prev.data_br}</p>
              <h3 class="fw-bold my-2 text-dark">${prev.tmax}°C</h3>
              <span class="badge badge-dia w-100 py-2 mb-1" style="background-color: ${confPrev.corAlerta}; font-weight: 700;">
                ${confPrev.rotuloCurto}
              </span>
              <p class="mt-1 mb-0 text-muted small fw-semibold" style="font-size: 0.78rem;">${confPrev.subtituloEhf}</p>
              <p class="mt-1 mb-0 text-muted small">EHF: ${prev.ehf}</p>
            </div>
          </div>
        </div>
      `;
    });
    htmlPrevisoes += '</div>';
    gradePrevisao.innerHTML = htmlPrevisoes;
  }
  
  // 4. Status COE Badge
  const badgeCoe = document.getElementById("badge-coe-status");
  if (badgeCoe) {
    badgeCoe.innerHTML = infoNivel.coeBadge;
  }
  
  // 5. Ações dos Setores de Belém
  const quadroAcoes = document.getElementById("quadro-acoes-setores");
  if (quadroAcoes) {
    const ac = infoNivel.acoesSetores;
    quadroAcoes.innerHTML = `
      <div class="row g-3">
        <!-- 1. CIEVS Belém & Vigilância Epidemiológica -->
        <div class="col-md-4">
          <div class="card card-setor p-3 shadow-sm h-100">
            <h6 class="fw-bold"><i class="bi bi-activity"></i> CIEVS Belém, Vigilância Epidemiológica & NHEs</h6>
            <p class="small text-muted mb-2">Monitoramento de rumores, avaliação de risco e busca ativa hospitalar</p>
            <ul class="lista-acoes-integra">
              ${ac.cievsVe.map(item => `<li>${item}</li>`).join('')}
            </ul>
          </div>
        </div>
        
        <!-- 2. Controle de Endemias -->
        <div class="col-md-4">
          <div class="card card-setor p-3 shadow-sm h-100">
            <h6 class="fw-bold"><i class="bi bi-bug-fill"></i> Controle de Endemias</h6>
            <p class="small text-muted mb-2">Horários de campo, rotinas de bloqueio e proteção ocupacional</p>
            <ul class="lista-acoes-integra">
              ${ac.controleEndemias.map(item => `<li>${item}</li>`).join('')}
            </ul>
          </div>
        </div>
        
        <!-- 3. Vigilância Sanitária e Ambiental -->
        <div class="col-md-4">
          <div class="card card-setor p-3 shadow-sm h-100">
            <h6 class="fw-bold"><i class="bi bi-shield-fill-check"></i> Vigilância Sanitária e Ambiental</h6>
            <p class="small text-muted mb-2">Inspeção de ILPIs, cadeia de frio, água, gelo e medidas cautelares</p>
            <ul class="lista-acoes-integra">
              ${ac.vigSanitariaAmbiental.map(item => `<li>${item}</li>`).join('')}
            </ul>
          </div>
        </div>
        
        <!-- 4. CEREST Saúde do Trabalhador -->
        <div class="col-md-4">
          <div class="card card-setor p-3 shadow-sm h-100">
            <h6 class="fw-bold"><i class="bi bi-person-workspace"></i> CEREST Saúde do Trabalhador</h6>
            <p class="small text-muted mb-2">Proteção a trabalhadores ao ar livre, EPIs e denúncias</p>
            <ul class="lista-acoes-integra">
              ${ac.trabalhador.map(item => `<li>${item}</li>`).join('')}
            </ul>
          </div>
        </div>
        
        <!-- 5. Atenção à Saúde -->
        <div class="col-md-4">
          <div class="card card-setor p-3 shadow-sm h-100">
            <h6 class="fw-bold"><i class="bi bi-heart-pulse-fill"></i> Atenção à Saúde (APS, Urgência/Emergência, SAMU e Casas)</h6>
            <p class="small text-muted mb-2">Visitas domiciliares, climatização, resfriamento corporal e suporte intensivo</p>
            <ul class="lista-acoes-integra">
              ${ac.atencaoSaude.map(item => `<li>${item}</li>`).join('')}
            </ul>
          </div>
        </div>
        
        <!-- 6. Regulação e Comunicação em Saúde -->
        <div class="col-md-4">
          <div class="card card-setor p-3 shadow-sm h-100">
            <h6 class="fw-bold"><i class="bi bi-hospital"></i> Regulação e Comunicação em Saúde</h6>
            <p class="small text-muted mb-2">NIR hospitalar, leitos de retaguarda, boletins oficiais e combate a boatos</p>
            <ul class="lista-acoes-integra">
              ${ac.regulacaoComunicacao.map(item => `<li>${item}</li>`).join('')}
            </ul>
          </div>
        </div>
      </div>
    `;
  }
  
  // 6. Status da Coleta / CRON
  const painelCron = document.getElementById("painel-status-cron");
  if (painelCron) {
    painelCron.innerHTML = `
      <div class="p-3 bg-light rounded-3 border">
        <p class="mb-1"><strong>Status da Integração:</strong> <span class="badge bg-success">Conectado / Operante</span></p>
        <p class="mb-1"><strong>Última Sincronização dos Dados:</strong> ${dados.data_base_br} às ${dados.hora_consulta || '12:00:00'}</p>
        <p class="mb-1"><strong>Fonte Oficial:</strong> <a href="${dados.fonte_url || 'https://clima.saude.gov.br/pa/belem?data=2026-10-27&modo=ehf'}" target="_blank">clima.saude.gov.br</a> (ECMWF & Ministério da Saúde)</p>
        <p class="mb-1"><strong>Automação (CRONJOB):</strong> Executada pelo <code>GitHub Actions</code> às 06:00, 12:00 e 18:00 diariamente.</p>
        <p class="mb-0 text-muted small">O arquivo <code>dados_clima_atual.json</code> é atualizado automaticamente na nuvem sem necessidade de servidores locais ligados.</p>
      </div>
    `;
  }

  // 7. Renderizar Boletim Oficial (Modal / Impressão)
  renderizarBoletim(dados);

  // 8. Inicializar Mapa Oficial de Belém com Dados do Ministério da Saúde
  inicializarMapaBelem(dados);
}

// ==============================================================================
// MAPA OFICIAL DE VIGILÂNCIA BIOCLIMÁTICA DE BELÉM (MINISTÉRIO DA SAÚDE)
// ==============================================================================
let instanciaMapaBelem = null;
let camadaPoligonoBelem = null;
let geoJsonMalhaBelemCache = null;
let dadosPrevisoesAtuais = [];
let picoHabitualAtual = 34.1;

async function obterMalhaGeoBelem() {
  if (geoJsonMalhaBelemCache) return geoJsonMalhaBelemCache;
  try {
    const r = await fetch('belem_malha.geojson');
    if (r.ok) {
      geoJsonMalhaBelemCache = await r.json();
      return geoJsonMalhaBelemCache;
    }
  } catch(e) {}
  try {
    const r2 = await fetch('https://servicodados.ibge.gov.br/api/v3/malhas/municipios/1501402?formato=application/vnd.geo+json');
    if (r2.ok) {
      geoJsonMalhaBelemCache = await r2.json();
      return geoJsonMalhaBelemCache;
    }
  } catch(e) {}
  return null;
}

function gerarPopupMapaBelem(itemPrevisao, corNivel, pico) {
  return `
    <div style="min-width: 250px; font-family: system-ui, -apple-system, sans-serif;">
      <div style="border-bottom: 2px solid ${corNivel}; padding-bottom: 5px; margin-bottom: 8px;">
        <h6 style="margin: 0; font-weight: 800; color: #1e3a8a; font-size: 1.05rem;">MUNICÍPIO DE BELÉM - PA</h6>
        <div style="font-size: 0.78rem; color: #64748b; font-weight: 600;">Código IBGE: 1501402 · Ministério da Saúde</div>
      </div>
      <div style="background: #f8fafc; border-radius: 8px; padding: 10px; margin-bottom: 8px; border: 1px solid #e2e8f0; font-size: 0.85rem;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
          <span style="color: #475569; font-weight: 600;">Nível de Calor:</span>
          <span style="font-weight: 800; color: ${corNivel};">${itemPrevisao.titulo_nivel || ''}</span>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
          <span style="color: #64748b;">Classificação EHF:</span>
          <span style="font-weight: 600; color: #1e293b;">${itemPrevisao.subtitulo_ehf || ''}</span>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
          <span style="color: #64748b;">Fator EHF:</span>
          <code>${itemPrevisao.ehf}</code>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
          <span style="color: #64748b;">Temp. Máxima:</span>
          <span style="font-weight: 800; color: #b91c1c; font-size: 1.05rem;">${itemPrevisao.tmax} °C</span>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
          <span style="color: #64748b;">Temp. Média (24h):</span>
          <span style="font-weight: 700; color: #0284c7;">${itemPrevisao.tmean || '29.5'} °C</span>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="color: #64748b;">Pico habitual (P75):</span>
          <span style="font-weight: 700; color: #dc2626;">${pico} °C</span>
        </div>
      </div>
      <div style="font-size: 0.73rem; color: #94a3b8; text-align: center;">
        Malha Territorial Oficial IBGE · Vigilância em Saúde (SESMA/MS)
      </div>
    </div>
  `;
}

window.mudarNivelMapaWeb = function(idx) {
  if (!dadosPrevisoesAtuais || !dadosPrevisoesAtuais[idx]) return;
  const p = dadosPrevisoesAtuais[idx];
  const clsP = normalizarClasse(p.classe);
  const confP = matrizNiveis[clsP] || matrizNiveis["Sem excesso"];
  const cor = confP.corAlerta;

  // Atualiza polígono do mapa
  if (camadaPoligonoBelem) {
    camadaPoligonoBelem.setStyle({
      fillColor: cor,
      color: cor,
      weight: 3,
      opacity: 0.95,
      fillOpacity: 0.55
    });
    camadaPoligonoBelem.bindPopup(gerarPopupMapaBelem(p, cor, picoHabitualAtual));
  }

  // Atualiza indicadores KPI acima do mapa
  const elEhf = document.getElementById("kpi-mapa-ehf");
  if (elEhf) elEhf.innerText = p.ehf;

  const elClasse = document.getElementById("kpi-mapa-classe");
  if (elClasse) {
    elClasse.innerText = confP.rotuloCurto;
    elClasse.style.backgroundColor = cor;
  }

  const elMedia = document.getElementById("kpi-mapa-media");
  if (elMedia) elMedia.innerText = `${p.tmean || 29.5}°C`;

  const elHoje = document.getElementById("kpi-mapa-hoje");
  if (elHoje) elHoje.innerText = `${p.tmax}°C`;

  // Atualiza botões
  for (let i = 0; i < dadosPrevisoesAtuais.length; i++) {
    const btn = document.getElementById(`btn-web-mapa-dia-${i}`);
    if (btn) {
      if (i === idx) {
        btn.className = "btn btn-sm me-1 mb-1 btn-primary shadow-sm";
        btn.style.backgroundColor = `${cor} !important`;
        btn.style.borderColor = `${cor} !important`;
        btn.style.color = "#ffffff !important";
      } else {
        btn.className = "btn btn-sm me-1 mb-1 btn-outline-secondary";
        btn.style.backgroundColor = "";
        btn.style.borderColor = "";
        btn.style.color = "";
      }
    }
  }
};

async function inicializarMapaBelem(dados) {
  const containerMapa = document.getElementById("mapa-belem-oficial");
  if (!containerMapa || typeof L === "undefined") return;

  dadosPrevisoesAtuais = dados.previsoes || [];
  const classeHoje = normalizarClasse(dados.hoje ? dados.hoje.classe : "Sem excesso");
  const infoNivel = matrizNiveis[classeHoje] || matrizNiveis["Sem excesso"];

  const ind = dados.indicadores_mapa || {};
  const ehfVal = (ind.ehf !== undefined) ? ind.ehf : (dados.hoje ? dados.hoje.ehf : 0.0);
  const mediaVal = (ind.media !== undefined) ? ind.media : 29.5;
  const hojeVal = (ind.hoje !== undefined) ? ind.hoje : (dados.hoje ? dados.hoje.tmax : 34.8);
  const picoVal = (ind.pico_habitual !== undefined) ? ind.pico_habitual : 34.1;
  picoHabitualAtual = picoVal;

  // 1. Atualizar Indicadores Dispostos Acima do Mapa: EHF, Média, Hoje, Pico habitual
  const elEhf = document.getElementById("kpi-mapa-ehf");
  if (elEhf) elEhf.innerText = ehfVal;

  const elClasse = document.getElementById("kpi-mapa-classe");
  if (elClasse) {
    elClasse.innerText = infoNivel.rotuloCurto;
    elClasse.style.backgroundColor = infoNivel.corAlerta;
  }

  const elMedia = document.getElementById("kpi-mapa-media");
  if (elMedia) elMedia.innerText = `${mediaVal}°C`;

  const elHoje = document.getElementById("kpi-mapa-hoje");
  if (elHoje) elHoje.innerText = `${hojeVal}°C`;

  const elPico = document.getElementById("kpi-mapa-pico");
  if (elPico) elPico.innerText = `${picoVal}°C`;

  // 2. Renderizar botões de alternância de projeção no mapa (D+0 a D+4)
  const barraBotoes = document.getElementById("barra-botoes-dias-mapa");
  if (barraBotoes && dadosPrevisoesAtuais.length > 0) {
    let htmlBtns = '<span class="small fw-bold text-muted text-uppercase me-1"><i class="bi bi-sliders"></i> Alternância de Projeção no Mapa:</span>';
    dadosPrevisoesAtuais.forEach((p, idx) => {
      const clsP = normalizarClasse(p.classe);
      const confP = matrizNiveis[clsP] || matrizNiveis["Sem excesso"];
      const isHoje = (idx === 0);
      htmlBtns += `
        <button type="button" id="btn-web-mapa-dia-${idx}" class="btn btn-sm me-1 mb-1 ${isHoje ? 'btn-primary shadow-sm' : 'btn-outline-secondary'}"
          style="font-size: 0.82rem; font-weight: 600; border-radius: 20px; padding: 4px 12px; ${isHoje ? `background-color: ${confP.corAlerta} !important; border-color: ${confP.corAlerta} !important; color: #ffffff !important;` : ''}"
          onclick="window.mudarNivelMapaWeb(${idx});">
          <span style="display:inline-block; width:10px; height:10px; border-radius:50%; margin-right:5px; background-color:${confP.corAlerta};"></span>
          ${isHoje ? 'Hoje' : 'D+' + idx} (${p.dia}): ${p.tmax}°C
        </button>
      `;
    });
    barraBotoes.innerHTML = htmlBtns;
  }

  // 3. Inicialização do Mapa Leaflet
  if (instanciaMapaBelem) {
    try { instanciaMapaBelem.remove(); } catch(e) {}
    instanciaMapaBelem = null;
  }

  instanciaMapaBelem = L.map('mapa-belem-oficial', {
    center: [-1.36, -48.46],
    zoom: 11,
    scrollWheelZoom: true
  });

  // Camada Base OpenStreetMap
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 18,
    attribution: '&copy; OpenStreetMap contributors | Ministério da Saúde · CIEVS Belém / SESMA · IBGE'
  }).addTo(instanciaMapaBelem);

  // 4. Carregar malha territorial oficial do IBGE e pintar na cor do nível vigente
  const geoData = await obterMalhaGeoBelem();
  if (geoData) {
    camadaPoligonoBelem = L.geoJSON(geoData, {
      style: {
        fillColor: infoNivel.corAlerta,
        color: infoNivel.corAlerta,
        weight: 3,
        opacity: 0.95,
        fillOpacity: 0.55
      },
      onEachFeature: function(feat, layer) {
        const p0 = (dadosPrevisoesAtuais && dadosPrevisoesAtuais[0]) ? dadosPrevisoesAtuais[0] : { ehf: ehfVal, tmax: hojeVal, tmean: mediaVal, titulo_nivel: infoNivel.titulo, subtitulo_ehf: infoNivel.statusMs };
        layer.bindPopup(gerarPopupMapaBelem(p0, infoNivel.corAlerta, picoVal));
        layer.on('mouseover', function(e) {
          e.target.setStyle({ weight: 4, fillOpacity: 0.7 });
        });
        layer.on('mouseout', function(e) {
          e.target.setStyle({ weight: 3, fillOpacity: 0.55 });
        });
      }
    }).addTo(instanciaMapaBelem);

    try {
      instanciaMapaBelem.fitBounds(camadaPoligonoBelem.getBounds(), { padding: [15, 15] });
    } catch(e) {}
  } else {
    // Fallback caso a API esteja inacessível
    L.circle([-1.240717, -48.459911], {
      color: infoNivel.corAlerta,
      fillColor: infoNivel.corAlerta,
      fillOpacity: 0.55,
      radius: 9500,
      weight: 3
    }).addTo(instanciaMapaBelem);
  }

  // 5. Adicionar Legenda dos 4 Níveis Oficiais
  const legenda = L.control({ position: 'bottomright' });
  legenda.onAdd = function() {
    const div = L.DomUtil.create('div', 'info legend shadow-sm');
    div.style.background = '#ffffff';
    div.style.padding = '8px 12px';
    div.style.borderRadius = '8px';
    div.style.border = '1px solid #cbd5e1';
    div.style.fontSize = '12px';
    div.style.lineHeight = '1.5';
    div.innerHTML = `
      <b style="color:#1e3a8a;">Níveis de Calor (EHF/MS)</b><br>
      <div style="display:flex;align-items:center;gap:6px;margin-top:4px;">
        <span style="background:#1b5e20;width:14px;height:14px;display:inline-block;border-radius:3px;"></span>
        <span>Nível 1: Normalidade</span>
      </div>
      <div style="display:flex;align-items:center;gap:6px;margin-top:2px;">
        <span style="background:#ca8a04;width:14px;height:14px;display:inline-block;border-radius:3px;"></span>
        <span>Nível 2: Atenção</span>
      </div>
      <div style="display:flex;align-items:center;gap:6px;margin-top:2px;">
        <span style="background:#ea580c;width:14px;height:14px;display:inline-block;border-radius:3px;"></span>
        <span>Nível 3: Alerta</span>
      </div>
      <div style="display:flex;align-items:center;gap:6px;margin-top:2px;">
        <span style="background:#dc2626;width:14px;height:14px;display:inline-block;border-radius:3px;"></span>
        <span>Nível 4: Emergência</span>
      </div>
    `;
    return div;
  };
  legenda.addTo(instanciaMapaBelem);

  setTimeout(() => {
    if (instanciaMapaBelem) {
      instanciaMapaBelem.invalidateSize();
    }
  }, 250);
}

// Renderiza o Boletim Oficial: Informe do Clima em Belém
function renderizarBoletim(dados) {
  const container = document.getElementById("conteudo-boletim");
  if (!container) return;

  const classeHoje = normalizarClasse(dados.hoje.classe);
  const infoNivel = matrizNiveis[classeHoje] || matrizNiveis["Sem excesso"];
  const ac = infoNivel.acoesSetores;

  const linhasPrevisao = (dados.previsoes || []).map(p => {
    const cls = normalizarClasse(p.classe);
    const conf = matrizNiveis[cls] || matrizNiveis["Sem excesso"];
    return `
      <tr>
        <td class="fw-bold">${p.dia}</td>
        <td>${p.data_br}</td>
        <td class="fw-bold text-dark fs-6">${p.tmax} °C</td>
        <td class="text-muted">${p.tmin || 23.0} °C</td>
        <td>
          <span class="badge py-2 px-3 fw-bold text-white w-100" style="background-color: ${conf.corAlerta};">
            ${conf.rotuloCurto}
          </span>
        </td>
        <td class="fw-semibold small">${conf.subtituloEhf}</td>
        <td><code>${p.ehf}</code></td>
      </tr>
    `;
  }).join('');

  container.innerHTML = `
    <div class="boletim-documento bg-white p-3 p-md-4 rounded shadow-sm border">
      <!-- CABEÇALHO DO BOLETIM -->
      <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3 flex-wrap gap-3">
        <div class="d-flex align-items-center gap-3">
          <img src="logo_sesma.png" alt="SESMA" style="height: 56px; width: auto; object-fit: contain;">
          <div>
            <h5 class="fw-bold mb-0 text-dark" style="letter-spacing: 0.02em;">PREFEITURA MUNICIPAL DE BELÉM</h5>
            <h6 class="fw-bold mb-0 text-primary" style="font-size: 0.95rem;">SECRETARIA MUNICIPAL DE SAÚDE · SESMA</h6>
            <p class="small text-muted mb-0">Centro de Informações Estratégicas em Vigilância em Saúde · CIEVS Belém</p>
          </div>
        </div>
        <div class="text-end">
          <span class="badge bg-primary fs-6 px-3 py-2"><i class="bi bi-file-earmark-medical"></i> INFORME DO CLIMA EM BELÉM</span>
          <p class="small text-muted mt-1 mb-0">Data de Emissão: <strong>${dados.hoje.data_br || dados.data_base_br}</strong> às <strong>${dados.hora_consulta || '12:00:00'}</strong></p>
        </div>
      </div>

      <div class="text-center mb-4 pb-2 border-bottom">
        <h3 class="fw-black text-dark mb-1" style="font-weight: 800; letter-spacing: -0.01em;">BOLETIM OFICIAL: INFORME DO CLIMA EM BELÉM</h3>
        <p class="text-muted mb-2">Sistema Oficial de Vigilância de Excesso de Calor e Plano de Contingência Local</p>
        <div class="d-flex justify-content-center gap-3 small text-muted flex-wrap">
          <span><strong>Município:</strong> Belém - PA (1501402)</span>
          <span>•</span>
          <span><strong>Fonte Oficial:</strong> <a href="https://clima.saude.gov.br/pa/belem?data=2026-10-27&modo=ehf" target="_blank" class="text-decoration-none">Ministério da Saúde</a></span>
          <span>•</span>
          <span><strong>Metodologia:</strong> EHF (Excess Heat Factor)</span>
        </div>
      </div>

      <!-- SEÇÃO 1: NÍVEL DE CALOR DO DIA (ALERTA PISCANTE) -->
      <div class="mb-4">
        <h5 class="fw-bold titulo-padrao-escuro mb-2"><i class="bi bi-bell-fill text-danger"></i> 1. NÍVEL DE CALOR DO DIA (VIGÊNCIA HOJE)</h5>
        <div class="p-4 rounded-3 text-white shadow-sm" style="background-color: ${infoNivel.corAlerta}; border: 2px solid rgba(255,255,255,0.7);">
          <div class="row align-items-center">
            <div class="col-md-2 text-center mb-3 mb-md-0">
              <i class="bi ${infoNivel.icone}" style="font-size: 4rem; color: #ffffff !important;"></i>
            </div>
            <div class="col-md-7 text-start">
              <div class="mb-2">
                <span class="badge bg-white text-dark px-3 py-1 fw-bold text-uppercase">CIEVS BELÉM · SESMA</span>
                <span class="badge bg-white text-dark px-2 py-1 ms-2 fw-normal">DATA: ${dados.hoje.data_br || dados.data_base_br}</span>
              </div>
              <h2 class="fw-black m-0 text-white" style="font-weight: 900; letter-spacing: 0.02em;">${infoNivel.tituloNivel}</h2>
              <div class="mt-2 text-white fw-bold opacity-90" style="font-size: 1.15rem; letter-spacing: 0.03em;">
                ${infoNivel.subtituloEhf}
              </div>
            </div>
            <div class="col-md-3 text-center border-start border-white-50">
              <div class="small text-uppercase opacity-75 text-white">Temp. Máxima Prevista</div>
              <h2 class="fw-bold mb-0 text-white">${dados.hoje.tmax} °C</h2>
              <div class="small opacity-90 text-white mt-1">Mínima: ${dados.hoje.tmin || 23.0} °C</div>
              <span class="badge bg-black bg-opacity-25 mt-2">EHF Diário: ${dados.hoje.ehf}</span>
            </div>
          </div>
        </div>

        <div class="row g-3 mt-2">
          <div class="col-md-6">
            <div class="p-3 bg-light rounded border h-100" style="border-left: 4px solid #1e3a8a !important;">
              <h6 class="fw-bold text-primary mb-1"><i class="bi bi-people-fill"></i> O QUE FAZER HOJE: POPULAÇÃO</h6>
              <p class="mb-0 text-dark small" style="line-height: 1.5;">${infoNivel.populacao}</p>
            </div>
          </div>
          <div class="col-md-6">
            <div class="p-3 bg-light rounded border h-100" style="border-left: 4px solid #1e3a8a !important;">
              <h6 class="fw-bold text-primary mb-1"><i class="bi bi-hospital"></i> O QUE FAZER HOJE: SERVIÇOS DE SAÚDE</h6>
              <p class="mb-0 text-dark small" style="line-height: 1.5;">${infoNivel.servicoSaude}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- SEÇÃO 2: PREVISÃO OPERACIONAL DE CALOR -->
      <div class="mb-4">
        <h5 class="fw-bold titulo-padrao-escuro mb-1"><i class="bi bi-calendar3 text-primary"></i> 2. PREVISÃO OPERACIONAL DE CALOR</h5>
        <p class="small text-muted mb-2">(D+0 A D+4) — D+0 é a medição/previsão atual; D+1 a D+4 sinalizam a tendência para Belém.</p>
        <div class="table-responsive">
          <table class="table table-bordered table-striped align-middle text-center mb-0">
            <thead class="table-light">
              <tr>
                <th>Referência</th>
                <th>Data</th>
                <th>Temp. Máx</th>
                <th>Temp. Mín</th>
                <th>Nível de Calor</th>
                <th>Classificação do EHF</th>
                <th>Fator EHF</th>
              </tr>
            </thead>
            <tbody>
              ${linhasPrevisao}
            </tbody>
          </table>
        </div>
      </div>

      <!-- SEÇÃO 3: AÇÕES DE RESPOSTA DOS SETORES DE BELÉM (PARA O NÍVEL VIGENTE) -->
      <div class="mb-4">
        <h5 class="fw-bold titulo-padrao-escuro mb-1"><i class="bi bi-diagram-3-fill text-primary"></i> 3. AÇÕES DE RESPOSTA DOS SETORES DE BELÉM (PARA O NÍVEL VIGENTE)</h5>
        <p class="small text-muted mb-3">Protocolos e procedimentos setoriais ativos na rede de saúde para o <strong>${infoNivel.tituloNivel}</strong>:</p>
        <div class="row g-3">
          <div class="col-md-4">
            <div class="card card-setor p-3 shadow-sm h-100">
              <h6 class="fw-bold"><i class="bi bi-activity"></i> CIEVS Belém, VE & NHEs</h6>
              <ul class="lista-acoes-integra">
                ${ac.cievsVe.map(item => `<li>${item}</li>`).join('')}
              </ul>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card card-setor p-3 shadow-sm h-100">
              <h6 class="fw-bold"><i class="bi bi-bug-fill"></i> Controle de Endemias</h6>
              <ul class="lista-acoes-integra">
                ${ac.controleEndemias.map(item => `<li>${item}</li>`).join('')}
              </ul>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card card-setor p-3 shadow-sm h-100">
              <h6 class="fw-bold"><i class="bi bi-shield-fill-check"></i> Vigilância Sanitária e Ambiental</h6>
              <ul class="lista-acoes-integra">
                ${ac.vigSanitariaAmbiental.map(item => `<li>${item}</li>`).join('')}
              </ul>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card card-setor p-3 shadow-sm h-100">
              <h6 class="fw-bold"><i class="bi bi-person-workspace"></i> CEREST Saúde do Trabalhador</h6>
              <ul class="lista-acoes-integra">
                ${ac.trabalhador.map(item => `<li>${item}</li>`).join('')}
              </ul>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card card-setor p-3 shadow-sm h-100">
              <h6 class="fw-bold"><i class="bi bi-heart-pulse-fill"></i> Atenção à Saúde (APS, Urgência, SAMU)</h6>
              <ul class="lista-acoes-integra">
                ${ac.atencaoSaude.map(item => `<li>${item}</li>`).join('')}
              </ul>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card card-setor p-3 shadow-sm h-100">
              <h6 class="fw-bold"><i class="bi bi-hospital"></i> Regulação e Comunicação em Saúde</h6>
              <ul class="lista-acoes-integra">
                ${ac.regulacaoComunicacao.map(item => `<li>${item}</li>`).join('')}
              </ul>
            </div>
          </div>
        </div>
      </div>

      <!-- RODAPÉ INSTITUCIONAL DO BOLETIM -->
      <div class="border-top pt-3 mt-4 text-center text-muted small">
        <p class="mb-1"><strong>Prefeitura Municipal de Belém · Secretaria Municipal de Saúde (SESMA)</strong></p>
        <p class="mb-1">Centro de Informações Estratégicas em Vigilância em Saúde (CIEVS Belém) · Vigilância de Eventos Climáticos</p>
        <p class="mb-0">Página oficial do Ministério da Saúde: <a href="https://clima.saude.gov.br/pa/belem?data=2026-10-27&modo=ehf" target="_blank" class="text-decoration-none">https://clima.saude.gov.br/pa/belem?data=2026-10-27&modo=ehf</a></p>
      </div>
    </div>
  `;
}

function baixarBoletimPDF() {
  const elemento = document.getElementById("conteudo-boletim");
  if (!elemento) return;

  const botoesBaixar = document.querySelectorAll(".btn-baixar-pdf");
  botoesBaixar.forEach(btn => {
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status"></span> Gerando PDF...';
  });

  const opt = {
    margin: [8, 8, 8, 8],
    filename: 'Boletim_Informe_do_Clima_Belem_' + (new Date().toISOString().slice(0, 10)) + '.pdf',
    image: { type: 'jpeg', quality: 0.98 },
    html2canvas: { scale: 2, useCORS: true, logging: false },
    jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
  };

  if (typeof html2pdf !== 'undefined') {
    html2pdf().set(opt).from(elemento).save().then(() => {
      botoesBaixar.forEach(btn => {
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-file-earmark-pdf-fill me-1"></i> Baixar Arquivo em PDF';
      });
    }).catch(err => {
      console.warn("Falha no html2pdf, abrindo caixa de impressão para salvar em PDF:", err);
      window.print();
      botoesBaixar.forEach(btn => {
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-file-earmark-pdf-fill me-1"></i> Baixar Arquivo em PDF';
      });
    });
  } else {
    window.print();
    botoesBaixar.forEach(btn => {
      btn.disabled = false;
      btn.innerHTML = '<i class="bi bi-file-earmark-pdf-fill me-1"></i> Baixar Arquivo em PDF';
    });
  }
}

function imprimirBoletim() {
  window.print();
}

// Carrega os dados climáticos atuais
function carregarDadosClima() {
  fetch('dados_clima_atual.json?t=' + Date.now())
    .then(response => {
      if (!response.ok) throw new Error("Status " + response.status);
      return response.json();
    })
    .then(dados => {
      renderizarPainel(dados);
    })
    .catch(err => {
      console.warn("Carregando fallback padrão devido a:", err);
      // Fallback local se o fetch falhar
      const fallback = {
        municipio: "Belém - PA",
        data_base_br: new Date().toLocaleDateString('pt-BR'),
        hora_consulta: new Date().toLocaleTimeString('pt-BR'),
        hoje: { dia: "Hoje", data_br: new Date().toLocaleDateString('pt-BR'), classe: "Sem excesso", ehf: 0, tmax: 33.9, tmin: 23.7 },
        previsoes: [
          { dia: "Hoje", data_br: new Date().toLocaleDateString('pt-BR'), classe: "Sem excesso", ehf: 0, tmax: 33.9 },
          { dia: "D+1", data_br: "+1 dia", classe: "Sem excesso", ehf: 0, tmax: 34.4 },
          { dia: "D+2", data_br: "+2 dias", classe: "Sem excesso", ehf: 0, tmax: 36.1 },
          { dia: "D+3", data_br: "+3 dias", classe: "Sem excesso", ehf: 0.21, tmax: 34.9 },
          { dia: "D+4", data_br: "+4 dias", classe: "Sem excesso", ehf: 0.2, tmax: 34.8 }
        ]
      };
      renderizarPainel(fallback);
    });
}

// Contador regressivo para rechecagem no navegador
function iniciarCronometro() {
  const el = document.getElementById('cronometro-regressivo');
  setInterval(() => {
    tempoRestante--;
    if (tempoRestante < 0) {
      tempoRestante = 600;
      carregarDadosClima();
    }
    if (el) {
      const min = Math.floor(tempoRestante / 60);
      const seg = tempoRestante % 60;
      el.innerText = (min < 10 ? '0' + min : min) + ':' + (seg < 10 ? '0' + seg : seg);
    }
  }, 1000);
}

// Inicialização do painel no carregamento do DOM
document.addEventListener("DOMContentLoaded", () => {
  carregarDadosClima();
  iniciarCronometro();
});
