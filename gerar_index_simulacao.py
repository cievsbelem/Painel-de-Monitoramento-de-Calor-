#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gera o portal principal comparativo de simulação:
simulacoes_niveis_calor/index.html
"""

import os
import base64

def main():
    with open("app.js", "r", encoding="utf-8") as f:
        code = f.read()

    start = code.find("const matrizNiveis = {")
    end = code.find("let dadosClimaCache = null;")
    js_matriz = code[start:end].strip()

    logo_b64 = ""
    if os.path.exists("logo_sesma.png"):
        with open("logo_sesma.png", "rb") as f:
            logo_b64 = f"data:image/png;base64,{base64.b64encode(f.read()).decode('utf-8')}"

    html_content = f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Portal de Simulação dos Níveis de Calor — CIEVS Belém / SESMA</title>
  
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

  <style>
    body {{
      background-color: #f1f5f9;
      color: #1e293b;
      font-family: 'Plus Jakarta Sans', sans-serif;
    }}
    .titulo-padrao {{
      color: #1e3a8a;
      font-weight: 800;
    }}
    .card-nivel {{
      border: none;
      border-radius: 14px;
      transition: all 0.25s ease;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(15, 23, 42, 0.06);
    }}
    .card-nivel:hover {{
      transform: translateY(-4px);
      box-shadow: 0 12px 24px rgba(15, 23, 42, 0.12);
    }}
    .header-nivel-1 {{ background: linear-gradient(135deg, #1b5e20, #2e7d32); color: white; }}
    .header-nivel-2 {{ background: linear-gradient(135deg, #ca8a04, #eab308); color: white; }}
    .header-nivel-3 {{ background: linear-gradient(135deg, #ea580c, #f97316); color: white; }}
    .header-nivel-4 {{ background: linear-gradient(135deg, #dc2626, #b91c1c); color: white; }}
    
    .nav-pills .nav-link {{
      color: #475569;
      font-weight: 600;
      border-radius: 10px;
      padding: 10px 16px;
      border: 1px solid #cbd5e1;
      background-color: #ffffff;
      margin-right: 6px;
      margin-bottom: 6px;
      transition: all 0.2s ease;
    }}
    .nav-pills .nav-link.active {{
      background-color: #1e3a8a;
      color: #ffffff;
      border-color: #1e3a8a;
      box-shadow: 0 4px 10px rgba(30, 58, 138, 0.25);
    }}
    .card-setor-comparativo {{
      border-radius: 12px;
      background-color: #ffffff;
      border: 1px solid #e2e8f0;
      height: 100%;
      box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    }}
    .card-setor-comparativo .card-header {{
      font-weight: 700;
      font-size: 0.95rem;
      border-top-left-radius: 12px;
      border-top-right-radius: 12px;
    }}
    .lista-acoes {{
      padding-left: 20px;
      font-size: 0.88rem;
      line-height: 1.55;
      color: #334155;
    }}
    .lista-acoes li {{
      margin-bottom: 8px;
    }}
    .badge-temperatura {{
      font-size: 1.15rem;
      font-weight: 800;
      padding: 6px 14px;
      border-radius: 8px;
    }}
  </style>
</head>
<body class="p-3 p-md-4">

  <div class="container-fluid max-w-7xl">
    
    <!-- CABEÇALHO INSTITUCIONAL -->
    <div class="d-flex flex-wrap justify-content-between align-items-center py-3 px-4 mb-4 border-bottom shadow-sm bg-white rounded-3 gap-3">
      <div class="d-flex align-items-center gap-3">
        <div style="width: 60px; height: 60px; display: flex; align-items: center; justify-content: center; background: #f8fafc; border-radius: 10px; border: 1px solid #e2e8f0;">
          <img src="{logo_b64}" alt="SESMA Belém" style="max-height: 50px; max-width: 50px; object-fit: contain;">
        </div>
        <div>
          <h4 class="mb-0 titulo-padrao">SISTEMA OFICIAL DE VIGILÂNCIA DE EXCESSO DE CALOR</h4>
          <p class="mb-0 small text-muted"><strong>CIEVS Belém / SESMA</strong> · Centro de Operações de Simulação e Protocolos de Contingência</p>
        </div>
      </div>
      
      <div class="d-flex align-items-center gap-2">
        <a href="../index.html" class="btn btn-outline-primary fw-bold">
          <i class="bi bi-box-arrow-up-right me-1"></i> Abrir Painel Oficial em Tempo Real
        </a>
      </div>
    </div>

    <!-- BANNER DE ORIENTAÇÃO TÉCNICA -->
    <div class="alert alert-info border-info d-flex align-items-center shadow-sm rounded-3 mb-4 p-3" role="alert">
      <i class="bi bi-info-circle-fill fs-3 text-info me-3 flex-shrink-0"></i>
      <div>
        <h6 class="alert-heading fw-bold mb-1">Ambiente de Simulação de Contingência (Fase de Testes & Treinamento)</h6>
        <p class="mb-0 small text-secondary">
          Como o município de Belém encontra-se atualmente em <strong>Nível 1 (Normalidade)</strong>, esta central de testes permite visualizar o comportamento do painel, os layouts de alertas e, principalmente, as <strong>Ações Reais de Resposta dos Setores de Belém</strong> para cada um dos outros níveis previstos no Plano de Contingência da SESMA.
        </p>
      </div>
    </div>

    <!-- SEÇÃO 1: OS 4 NÍVEIS DE CALOR COM ACESSO DIRETO AOS PAINÉIS COMPLETOS -->
    <div class="mb-4">
      <h5 class="fw-bold text-dark mb-3"><i class="bi bi-layers-fill text-primary me-2"></i>Selecione um Nível para Abrir o Painel Completo de Simulação:</h5>
      
      <div class="row g-3">
        <!-- NÍVEL 1: NORMALIDADE -->
        <div class="col-md-6 col-lg-3">
          <div class="card card-nivel h-100">
            <div class="header-nivel-1 p-3">
              <span class="badge bg-white text-success fw-bold mb-1">EHF: 0.0 (Sem excesso)</span>
              <h5 class="fw-bold mb-0">NÍVEL 1: NORMALIDADE</h5>
              <small class="opacity-75">Tmax habitual (~34.5°C)</small>
            </div>
            <div class="card-body p-3 d-flex flex-column justify-content-between">
              <div>
                <p class="small text-muted mb-2"><strong>Operação:</strong> Rotineira da rede em prontidão.</p>
                <p class="small text-muted mb-3"><strong>População:</strong> Rotina, sem cuidado extra.</p>
              </div>
              <a href="nivel_1_normalidade.html" class="btn btn-success fw-bold w-100">
                <i class="bi bi-display me-1"></i> Abrir Painel Nível 1
              </a>
            </div>
          </div>
        </div>

        <!-- NÍVEL 2: ATENÇÃO -->
        <div class="col-md-6 col-lg-3">
          <div class="card card-nivel h-100">
            <div class="header-nivel-2 p-3">
              <span class="badge bg-white text-dark fw-bold mb-1">EHF: Baixo (>0 e &lt;P85)</span>
              <h5 class="fw-bold mb-0">NÍVEL 2: ATENÇÃO</h5>
              <small class="opacity-90">Tmax elevada (~35.8°C)</small>
            </div>
            <div class="card-body p-3 d-flex flex-column justify-content-between">
              <div>
                <p class="small text-muted mb-2"><strong>Operação:</strong> Monitoramento diário e informes periódicos.</p>
                <p class="small text-muted mb-3"><strong>População:</strong> Beba água ao longo do dia mesmo sem sede.</p>
              </div>
              <a href="nivel_2_atencao.html" class="btn btn-warning fw-bold text-dark w-100">
                <i class="bi bi-display me-1"></i> Abrir Painel Nível 2
              </a>
            </div>
          </div>
        </div>

        <!-- NÍVEL 3: ALERTA -->
        <div class="col-md-6 col-lg-3">
          <div class="card card-nivel h-100">
            <div class="header-nivel-3 p-3">
              <span class="badge bg-white text-danger fw-bold mb-1" style="color: #ea580c !important;">EHF: Severo (&ge;P85)</span>
              <h5 class="fw-bold mb-0">NÍVEL 3: ALERTA</h5>
              <small class="opacity-90">Tmax muito alta (~37.4°C)</small>
            </div>
            <div class="card-body p-3 d-flex flex-column justify-content-between">
              <div>
                <p class="small text-muted mb-2"><strong>Operação:</strong> Sala de Situação em Alerta Prévio (24h).</p>
                <p class="small text-muted mb-3"><strong>População:</strong> Evite o sol 10h-16h e busque sombra.</p>
              </div>
              <a href="nivel_3_alerta.html" class="btn text-white fw-bold w-100" style="background-color: #ea580c;">
                <i class="bi bi-display me-1"></i> Abrir Painel Nível 3
              </a>
            </div>
          </div>
        </div>

        <!-- NÍVEL 4: EMERGÊNCIA -->
        <div class="col-md-6 col-lg-3">
          <div class="card card-nivel h-100">
            <div class="header-nivel-4 p-3">
              <span class="badge bg-white text-danger fw-bold mb-1">EHF: Extremo (&ge;2x P85)</span>
              <h5 class="fw-bold mb-0">NÍVEL 4: EMERGÊNCIA</h5>
              <small class="opacity-90">Onda de Calor Extrema (~38.8°C)</small>
            </div>
            <div class="card-body p-3 d-flex flex-column justify-content-between">
              <div>
                <p class="small text-muted mb-2"><strong>Operação:</strong> Centro de Operações (COE) Ativado.</p>
                <p class="small text-muted mb-3"><strong>População:</strong> Hidrate-se; mal-estar ligue 192 (SAMU).</p>
              </div>
              <a href="nivel_4_emergencia.html" class="btn btn-danger fw-bold w-100">
                <i class="bi bi-display me-1"></i> Abrir Painel Nível 4
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- SEÇÃO 2: MATRIZ COMPARATIVA DE AÇÕES REAIS POR SETOR -->
    <div class="card shadow-sm rounded-3 border-0 bg-white mb-4">
      <div class="card-header bg-white py-3 border-bottom d-flex flex-wrap justify-content-between align-items-center gap-2">
        <div>
          <h5 class="mb-0 fw-bold text-dark">
            <i class="bi bi-building-check text-primary me-2"></i>Matriz Comparativa de Ações Reais de Resposta dos Setores de Belém
          </h5>
          <small class="text-muted">Ações oficiais extraídas diretamente do código do sistema para planejamento e auditoria dos setores</small>
        </div>
        
        <div class="input-group input-group-sm" style="max-width: 280px;">
          <span class="input-group-text bg-light"><i class="bi bi-search"></i></span>
          <input type="text" id="filtro-acoes" class="form-control" placeholder="Filtrar ação (ex: EPI, SAMU, COE)..." onkeyup="filtrarAcoes()">
        </div>
      </div>

      <div class="card-body p-4">
        <!-- NAVEGAÇÃO DE ABAS POR SETOR -->
        <ul class="nav nav-pills mb-4" id="pills-tab-setores" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" id="tab-cievs" data-bs-toggle="pill" data-bs-target="#conteudo-cievs" type="button" role="tab">
              <i class="bi bi-activity me-1"></i> 1. CIEVS, VE & NHEs
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="tab-endemias" data-bs-toggle="pill" data-bs-target="#conteudo-endemias" type="button" role="tab">
              <i class="bi bi-bug-fill me-1"></i> 2. Controle de Endemias
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="tab-vigilancia" data-bs-toggle="pill" data-bs-target="#conteudo-vigilancia" type="button" role="tab">
              <i class="bi bi-shield-fill-check me-1"></i> 3. Vigilância Sanitária & Ambiental
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="tab-trabalhador" data-bs-toggle="pill" data-bs-target="#conteudo-trabalhador" type="button" role="tab">
              <i class="bi bi-person-workspace me-1"></i> 4. Saúde do Trabalhador (CEREST)
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="tab-atencao" data-bs-toggle="pill" data-bs-target="#conteudo-atencao" type="button" role="tab">
              <i class="bi bi-heart-pulse-fill me-1"></i> 5. Atenção à Saúde & Casas Especializadas
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="tab-regulacao" data-bs-toggle="pill" data-bs-target="#conteudo-regulacao" type="button" role="tab">
              <i class="bi bi-hospital me-1"></i> 6. Regulação & ASCOM
            </button>
          </li>
        </ul>

        <!-- CONTEÚDO DINÂMICO DAS ABAS COMPARATIVAS -->
        <div class="tab-content" id="pills-tabContentSetores">
          <!-- O JavaScript preencherá as 6 abas comparativas lado a lado -->
          <div class="tab-pane fade show active" id="conteudo-cievs" role="tabpanel"></div>
          <div class="tab-pane fade" id="conteudo-endemias" role="tabpanel"></div>
          <div class="tab-pane fade" id="conteudo-vigilancia" role="tabpanel"></div>
          <div class="tab-pane fade" id="conteudo-trabalhador" role="tabpanel"></div>
          <div class="tab-pane fade" id="conteudo-atencao" role="tabpanel"></div>
          <div class="tab-pane fade" id="conteudo-regulacao" role="tabpanel"></div>
        </div>

      </div>
    </div>

    <!-- RODAPÉ TÉCNICO -->
    <div class="text-center text-muted small py-3">
      <p class="mb-1"><strong>Prefeitura Municipal de Belém · Secretaria Municipal de Saúde (SESMA)</strong></p>
      <p class="mb-0">Centro de Informações Estratégicas em Vigilância em Saúde (CIEVS Belém) · Matriz de Contingência Climática</p>
    </div>

  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  
  <script>
{js_matriz}

const setoresChaves = [
  {{ id: "conteudo-cievs", chave: "cievsVe", nome: "CIEVS Belém, Vigilância Epidemiológica & NHEs", icone: "bi-activity" }},
  {{ id: "conteudo-endemias", chave: "controleEndemias", nome: "Controle de Endemias (DVS / SESMA)", icone: "bi-bug-fill" }},
  {{ id: "conteudo-vigilancia", chave: "vigSanitariaAmbiental", nome: "Vigilância Sanitária e Ambiental (DEVA / DEVS)", icone: "bi-shield-fill-check" }},
  {{ id: "conteudo-trabalhador", chave: "trabalhador", nome: "Saúde do Trabalhador (CEREST Belém)", icone: "bi-person-workspace" }},
  {{ id: "conteudo-atencao", chave: "atencaoSaude", nome: "Atenção à Saúde (APS, Urgência/Emergência, SAMU e Casas especializadas)", icone: "bi-heart-pulse-fill" }},
  {{ id: "conteudo-regulacao", chave: "regulacaoComunicacao", nome: "Regulação e Comunicação em Saúde (Central de Leitos / ASCOM)", icone: "bi-hospital" }}
];

const niveisConfig = [
  {{ chave: "Sem excesso", rotulo: "Nível 1: Normalidade", cor: "#1b5e20", headerBg: "header-nivel-1", arquivo: "nivel_1_normalidade.html" }},
  {{ chave: "Baixo", rotulo: "Nível 2: Atenção", cor: "#ffc107", headerBg: "header-nivel-2", arquivo: "nivel_2_atencao.html" }},
  {{ chave: "Severo", rotulo: "Nível 3: Alerta", cor: "#ea580c", headerBg: "header-nivel-3", arquivo: "nivel_3_alerta.html" }},
  {{ chave: "Extremo", rotulo: "Nível 4: Emergência", cor: "#dc2626", headerBg: "header-nivel-4", arquivo: "nivel_4_emergencia.html" }}
];

function montarAbasComparativas() {{
  setoresChaves.forEach(setor => {{
    const el = document.getElementById(setor.id);
    if (!el) return;

    let html = `
      <div class="row g-3">
    `;

    niveisConfig.forEach(niv => {{
      const acoes = (matrizNiveis[niv.chave] && matrizNiveis[niv.chave].acoesSetores && matrizNiveis[niv.chave].acoesSetores[setor.chave]) || [];
      
      html += `
        <div class="col-lg-3 col-md-6 col-12">
          <div class="card card-setor-comparativo h-100">
            <div class="card-header ${{niv.headerBg}} text-white py-2 px-3 d-flex justify-content-between align-items-center">
              <span>${{niv.rotulo}}</span>
              <span class="badge bg-white text-dark small">${{acoes.length}} ações</span>
            </div>
            <div class="card-body p-3">
              <ul class="lista-acoes">
                ${{acoes.map(a => `<li class="item-acao">${{a}}</li>`).join('')}}
              </ul>
            </div>
            <div class="card-footer bg-light p-2 text-center border-0">
              <a href="${{niv.arquivo}}" class="btn btn-sm btn-outline-secondary w-100">
                Ver neste Painel <i class="bi bi-arrow-right"></i>
              </a>
            </div>
          </div>
        </div>
      `;
    }});

    html += `</div>`;
    el.innerHTML = html;
  }});
}}

function filtrarAcoes() {{
  const termo = document.getElementById("filtro-acoes").value.toLowerCase().trim();
  const itens = document.querySelectorAll(".item-acao");
  
  itens.forEach(item => {{
    if (!termo || item.textContent.toLowerCase().includes(termo)) {{
      item.style.display = "";
      item.style.backgroundColor = termo ? "#fef08a" : "";
    }} else {{
      item.style.display = "none";
      item.style.backgroundColor = "";
    }}
  }});
}}

document.addEventListener("DOMContentLoaded", montarAbasComparativas);
  </script>
</body>
</html>
"""

    caminho = os.path.join("simulacoes_niveis_calor", "index.html")
    with open(caminho, "w", encoding="utf-8") as f:
        f.write(html_content)
    print(f"[OK] Portal comparativo gerado em: {caminho}")

if __name__ == "__main__":
    main()
