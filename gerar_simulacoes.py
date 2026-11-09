#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script gerador de simulações dos 4 Níveis de Calor para o Painel de Belém.
Gera arquivos HTML autocontidos na pasta 'simulacoes_niveis_calor/'
sem interferir no fluxo de produção oficial.
"""

import os
import json
import base64
from datetime import datetime, timedelta

def main():
    pasta_saida = "simulacoes_niveis_calor"
    os.makedirs(pasta_saida, exist_ok=True)

    # 1. Carregar recursos base
    with open("index.html", "r", encoding="utf-8") as f:
        html_base = f.read()

    with open("app.js", "r", encoding="utf-8") as f:
        js_base = f.read()

    logo_b64 = ""
    if os.path.exists("logo_sesma.png"):
        with open("logo_sesma.png", "rb") as f:
            logo_b64 = f"data:image/png;base64,{base64.b64encode(f.read()).decode('utf-8')}"

    malha_txt = "{}"
    if os.path.exists("belem_malha.geojson"):
        with open("belem_malha.geojson", "r", encoding="utf-8") as f:
            malha_txt = f.read()

    # Atualizar caminhos de imagem com Base64
    if logo_b64:
        html_base = html_base.replace('src="logo_sesma.png"', f'src="{logo_b64}"')
        html_base = html_base.replace('src="imagens_locais/logo_sesma.png"', f'src="{logo_b64}"')

    hoje = datetime.now()
    hoje_str = hoje.strftime("%d/%m/%Y")
    hoje_iso = hoje.strftime("%Y-%m-%d")

    # 2. Definição das configurações meteorológicas de cada nível
    cenarios = [
        {
            "arquivo": "nivel_1_normalidade.html",
            "nivel_num": 1,
            "classe": "Sem excesso",
            "titulo_nivel": "NÍVEL DE CALOR 1: NORMALIDADE",
            "subtitulo_ehf": "CLASSIFICAÇÃO DO EHF: SEM EXCESSO DE CALOR",
            "cor": "#1b5e20",
            "tmax": 34.5,
            "tmin": 23.7,
            "tmean": 29.1,
            "ehf": 0.0,
            "badge_class": "bg-success",
            "dias_previsao": [
                {"delta": 0, "classe": "Sem excesso", "tmax": 34.5, "tmin": 23.7, "ehf": 0.0},
                {"delta": 1, "classe": "Sem excesso", "tmax": 34.8, "tmin": 23.9, "ehf": 0.0},
                {"delta": 2, "classe": "Sem excesso", "tmax": 34.8, "tmin": 24.1, "ehf": 0.0},
                {"delta": 3, "classe": "Sem excesso", "tmax": 34.3, "tmin": 23.8, "ehf": 0.0},
                {"delta": 4, "classe": "Sem excesso", "tmax": 34.0, "tmin": 23.6, "ehf": 0.0},
            ]
        },
        {
            "arquivo": "nivel_2_atencao.html",
            "nivel_num": 2,
            "classe": "Baixo",
            "titulo_nivel": "NÍVEL DE CALOR 2: ATENÇÃO",
            "subtitulo_ehf": "CLASSIFICAÇÃO DO EHF: BAIXO",
            "cor": "#ffc107",
            "tmax": 35.8,
            "tmin": 24.6,
            "tmean": 30.2,
            "ehf": 1.45,
            "badge_class": "bg-warning text-dark",
            "dias_previsao": [
                {"delta": 0, "classe": "Baixo", "tmax": 35.8, "tmin": 24.6, "ehf": 1.45},
                {"delta": 1, "classe": "Baixo", "tmax": 36.1, "tmin": 24.8, "ehf": 1.60},
                {"delta": 2, "classe": "Baixo", "tmax": 35.5, "tmin": 24.5, "ehf": 1.20},
                {"delta": 3, "classe": "Baixo", "tmax": 34.9, "tmin": 24.2, "ehf": 0.50},
                {"delta": 4, "classe": "Sem excesso", "tmax": 34.2, "tmin": 23.8, "ehf": 0.0},
            ]
        },
        {
            "arquivo": "nivel_3_alerta.html",
            "nivel_num": 3,
            "classe": "Severo",
            "titulo_nivel": "NÍVEL DE CALOR 3: ALERTA",
            "subtitulo_ehf": "CLASSIFICAÇÃO DO EHF: SEVERO",
            "cor": "#ea580c",
            "tmax": 37.4,
            "tmin": 25.4,
            "tmean": 31.4,
            "ehf": 3.85,
            "badge_class": "bg-warning text-dark",
            "dias_previsao": [
                {"delta": 0, "classe": "Severo", "tmax": 37.4, "tmin": 25.4, "ehf": 3.85},
                {"delta": 1, "classe": "Severo", "tmax": 37.8, "tmin": 25.6, "ehf": 4.10},
                {"delta": 2, "classe": "Severo", "tmax": 37.2, "tmin": 25.3, "ehf": 3.50},
                {"delta": 3, "classe": "Baixo", "tmax": 36.4, "tmin": 24.9, "ehf": 2.20},
                {"delta": 4, "classe": "Baixo", "tmax": 35.2, "tmin": 24.5, "ehf": 1.10},
            ]
        },
        {
            "arquivo": "nivel_4_emergencia.html",
            "nivel_num": 4,
            "classe": "Extremo",
            "titulo_nivel": "NÍVEL DE CALOR 4: EMERGÊNCIA",
            "subtitulo_ehf": "CLASSIFICAÇÃO DO EHF: EXTREMO",
            "cor": "#dc2626",
            "tmax": 38.8,
            "tmin": 26.2,
            "tmean": 32.5,
            "ehf": 7.50,
            "badge_class": "bg-danger text-white",
            "dias_previsao": [
                {"delta": 0, "classe": "Extremo", "tmax": 38.8, "tmin": 26.2, "ehf": 7.50},
                {"delta": 1, "classe": "Extremo", "tmax": 39.1, "tmin": 26.5, "ehf": 8.20},
                {"delta": 2, "classe": "Extremo", "tmax": 38.5, "tmin": 26.1, "ehf": 6.90},
                {"delta": 3, "classe": "Severo", "tmax": 37.6, "tmin": 25.5, "ehf": 4.50},
                {"delta": 4, "classe": "Severo", "tmax": 36.8, "tmin": 25.0, "ehf": 3.10},
            ]
        }
    ]

    meses = {1: "jan.", 2: "fev.", 3: "mar.", 4: "abr.", 5: "mai.", 6: "jun.", 7: "jul.", 8: "ago.", 9: "set.", 10: "out.", 11: "nov.", 12: "dez."}
    
    mapa_titulos = {
        "Sem excesso": ("NÍVEL DE CALOR 1: NORMALIDADE", "CLASSIFICAÇÃO DO EHF: SEM EXCESSO DE CALOR"),
        "Baixo": ("NÍVEL DE CALOR 2: ATENÇÃO", "CLASSIFICAÇÃO DO EHF: BAIXO"),
        "Severo": ("NÍVEL DE CALOR 3: ALERTA", "CLASSIFICAÇÃO DO EHF: SEVERO"),
        "Extremo": ("NÍVEL DE CALOR 4: EMERGÊNCIA", "CLASSIFICAÇÃO DO EHF: EXTREMO")
    }

    # 3. Gerar cada HTML de simulação
    for c in cenarios:
        previsoes = []
        for d in c["dias_previsao"]:
            dt = hoje + timedelta(days=d["delta"])
            dia_str = f"{dt.day} de {meses[dt.month]}"
            dt_br = dt.strftime("%d/%m/%Y")
            tit, sub = mapa_titulos[d["classe"]]
            previsoes.append({
                "dia": dia_str,
                "data_br": dt_br,
                "classe": d["classe"],
                "ehf": d["ehf"],
                "tmax": d["tmax"],
                "tmin": d["tmin"],
                "tmean": round((d["tmax"] + d["tmin"]) / 2, 1),
                "titulo_nivel": tit,
                "subtitulo_ehf": sub
            })

        payload = {
            "municipio": "Belém - PA",
            "codigo_ibge": "1501402",
            "data_base_iso": hoje_iso,
            "data_base_br": hoje_str,
            "hora_consulta": "11:00:00 (Simulação)",
            "sucesso": True,
            "fonte_url": f"https://clima.saude.gov.br/pa/belem?modo=ehf&data={hoje_iso}",
            "titulo_nivel": c["titulo_nivel"],
            "subtitulo_ehf": c["subtitulo_ehf"],
            "indicadores_mapa": {
                "ehf": c["ehf"],
                "media": c["tmean"],
                "hoje": c["tmax"],
                "pico_habitual": 34.1,
                "tmin": c["tmin"],
                "lat": -1.240717,
                "lon": -48.459911
            },
            "hoje": previsoes[0],
            "previsoes": previsoes
        }

        dados_json = json.dumps(payload, ensure_ascii=False)

        # Montar a barra de navegação de simulação no topo
        barra_simulacao = f"""
    <!-- BARRA SUPERIOR DE CONTROLE DA SIMULAÇÃO (CIEVS BELÉM) -->
    <div class="simulation-banner bg-dark text-white py-2 px-3 mb-3 border-bottom shadow-sm rounded-3">
      <div class="container-fluid d-flex flex-wrap justify-content-between align-items-center gap-2">
        <div class="d-flex align-items-center gap-2">
          <span class="badge {c['badge_class']} fw-bold fs-6"><i class="bi bi-flask-fill"></i> CENÁRIO SIMULADO: NÍVEL {c['nivel_num']}</span>
          <span class="small text-light d-none d-md-inline">Demonstração das <strong>Ações Reais dos Setores de Belém</strong> para este patamar térmico</span>
        </div>
        <div class="btn-group btn-group-sm flex-wrap my-1" role="group">
          <a href="nivel_1_normalidade.html" class="btn btn-sm {'btn-success fw-bold' if c['nivel_num'] == 1 else 'btn-outline-light'}">🟢 Nível 1: Normalidade</a>
          <a href="nivel_2_atencao.html" class="btn btn-sm {'btn-warning fw-bold text-dark' if c['nivel_num'] == 2 else 'btn-outline-light'}">🟡 Nível 2: Atenção</a>
          <a href="nivel_3_alerta.html" class="btn btn-sm {'btn-danger fw-bold' if c['nivel_num'] == 3 else 'btn-outline-light'}" style="{'background-color: #ea580c; border-color: #ea580c;' if c['nivel_num'] == 3 else ''}">🟠 Nível 3: Alerta</a>
          <a href="nivel_4_emergencia.html" class="btn btn-sm {'btn-danger fw-bold' if c['nivel_num'] == 4 else 'btn-outline-light'}" style="{'background-color: #dc2626; border-color: #dc2626;' if c['nivel_num'] == 4 else ''}">🔴 Nível 4: Emergência</a>
          <a href="index.html" class="btn btn-sm btn-info text-white"><i class="bi bi-grid-3x3-gap-fill"></i> Comparativo de Setores</a>
        </div>
        <div>
          <a href="../index.html" class="btn btn-sm btn-outline-light"><i class="bi bi-arrow-left-circle"></i> Painel Oficial em Tempo Real</a>
        </div>
      </div>
    </div>
"""

        # Injetar a barra de navegação no início do body
        html_page = html_base.replace(
            '<body class="p-3 p-md-4">',
            f'<body class="p-3 p-md-4">\n{barra_simulacao}'
        )

        # Injetar dados embutidos e malha no script
        bloco_dados = f"""
window.DADOS_CLIMA_EMBUTIDOS = {dados_json};
window.MALHA_BELEM_EMBUTIDA = {malha_txt};
"""
        js_mod = bloco_dados + "\n" + js_base
        if logo_b64:
            js_mod = js_mod.replace('src="logo_sesma.png"', f'src="{logo_b64}"')
        
        # Assegurar que carregarDadosClima usa DADOS_CLIMA_EMBUTIDOS imediatamente
        js_mod = js_mod.replace(
            "function carregarDadosClima() {",
            "function carregarDadosClima() {\n  if (window.DADOS_CLIMA_EMBUTIDOS) {\n    renderizarPainel(window.DADOS_CLIMA_EMBUTIDOS);\n    return;\n  }"
        )
        js_mod = js_mod.replace(
            "async function obterMalhaGeoBelem() {",
            "async function obterMalhaGeoBelem() {\n  if (window.MALHA_BELEM_EMBUTIDA) return window.MALHA_BELEM_EMBUTIDA;"
        )

        html_final = html_page.replace(
            '<script src="app.js"></script>',
            f'<script>\n{js_mod}\n</script>'
        )

        caminho_arquivo = os.path.join(pasta_saida, c["arquivo"])
        with open(caminho_arquivo, "w", encoding="utf-8") as f_out:
            f_out.write(html_final)
        print(f"[OK] Arquivo de simulação gerado: {caminho_arquivo}")

    print("\nTodos os 4 cenários foram gerados com sucesso!")

if __name__ == "__main__":
    main()
