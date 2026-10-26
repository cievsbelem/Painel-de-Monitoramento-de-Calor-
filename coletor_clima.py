#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
==============================================================================
COLETOR AUTOMATIZADO DE DADOS CLIMÁTICOS (CRONJOB) - BELÉM / PA
Execução em Nuvem via GitHub Actions ou localmente.
Fonte Oficial: Ministério da Saúde (https://clima.saude.gov.br/pa/belem?modo=ehf)
Com suporte a dados sensíveis (Secrets) para disparo de e-mails restritos.
==============================================================================
"""

import sys
import os
import re
import json
import urllib.request
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime, timedelta

MESES_PT = {
    1: "jan.", 2: "fev.", 3: "mar.", 4: "abr.", 5: "mai.", 6: "jun.",
    7: "jul.", 8: "ago.", 9: "set.", 10: "out.", 11: "nov.", 12: "dez."
}

def formatar_dia_br(dt):
    mes = MESES_PT.get(dt.month, "")
    return f"{dt.day} de {mes}"

def mapear_classe(cls_str):
    if not cls_str:
        return "Sem excesso"
    c = cls_str.strip().lower()
    if any(k in c for k in ["normal", "sem", "nenhum"]):
        return "Sem excesso"
    if any(k in c for k in ["baixo", "moderado", "atencao", "atenção"]):
        return "Baixo"
    if any(k in c for k in ["severo", "alerta", "laranja"]):
        return "Severo"
    if any(k in c for k in ["extremo", "emergencia", "emergência", "vermelho"]):
        return "Extremo"
    return "Sem excesso"

MAPA_DESCRICOES = {
    "Sem excesso": {
        "titulo": "NÍVEL DE CALOR 1: NORMALIDADE",
        "subtitulo": "CLASSIFICAÇÃO DO EHF: SEM EXCESSO DE CALOR",
        "cor": "#1b5e20"
    },
    "Baixo": {
        "titulo": "NÍVEL DE CALOR 2: ATENÇÃO",
        "subtitulo": "CLASSIFICAÇÃO DO EHF: BAIXO",
        "cor": "#ca8a04"
    },
    "Severo": {
        "titulo": "NÍVEL DE CALOR 3: ALERTA",
        "subtitulo": "CLASSIFICAÇÃO DO EHF: SEVERO",
        "cor": "#ea580c"
    },
    "Extremo": {
        "titulo": "NÍVEL DE CALOR 4: EMERGÊNCIA",
        "subtitulo": "CLASSIFICAÇÃO DO EHF: EXTREMO",
        "cor": "#dc2626"
    }
}

def disparar_alerta_smtp(payload):
    """
    Envia alertas por e-mail utilizando credenciais e lista de destinatários
    armazenadas de forma 100% segura nos GitHub Secrets (sem expor no repositório).
    """
    smtp_host = os.environ.get("SMTP_HOST")
    smtp_port = os.environ.get("SMTP_PORT", "465")
    smtp_user = os.environ.get("SMTP_USER")
    smtp_pass = os.environ.get("SMTP_PASS")
    dest_secret = os.environ.get("DESTINATARIOS_SECRET") # Lista privada em Secret

    if not (smtp_host and smtp_user and smtp_pass and dest_secret):
        print("Aviso: Credenciais SMTP ou lista secreta não configuradas nos Secrets. Disparo de e-mail ignorado.")
        return

    # Parse da lista de e-mails secretos (aceita separação por vírgula ou JSON)
    destinatarios = []
    if dest_secret.strip().startswith("["):
        try:
            parsed = json.loads(dest_secret)
            destinatarios = [item.get("Email", item) if isinstance(item, dict) else item for item in parsed]
        except Exception:
            destinatarios = [e.strip() for e in dest_secret.split(",") if "@" in e]
    else:
        destinatarios = [e.strip() for e in dest_secret.split(",") if "@" in e]

    if not destinatarios:
        print("Nenhum destinatário válido encontrado no Secret.")
        return

    classe = payload["hoje"]["classe"]
    info_desc = MAPA_DESCRICOES.get(classe, MAPA_DESCRICOES["Sem excesso"])
    ehf = payload["hoje"]["ehf"]
    tmax = payload["hoje"]["tmax"]
    data_br = payload["data_base_br"]

    assunto = f"[ALERTA OFICIAL CIEVS BELÉM] {info_desc['titulo']} ({tmax}°C)"
    
    corpo_html = f"""
    <html>
      <body style="font-family: Arial, sans-serif; color: #1e293b;">
        <h2 style="color: #1e3a8a;">SISTEMA OFICIAL DE VIGILÂNCIA DE EXCESSO DE CALOR</h2>
        <p><strong>CIEVS Belém / SESMA · Prefeitura de Belém</strong></p>
        <hr>
        <div style="padding: 15px; background-color: #f1f5f9; border-left: 5px solid {info_desc['cor']}; border-radius: 4px;">
          <p><strong>Data de Referência:</strong> {data_br}</p>
          <p><strong>Status de Contingência:</strong> <span style="font-weight: bold; font-size: 1.1em;">{info_desc['titulo']}</span></p>
          <p><strong>Classificação Oficial Ministério da Saúde:</strong> <span style="font-weight: bold;">{info_desc['subtitulo']}</span></p>
          <p><strong>Temperatura Máxima Prevista:</strong> {tmax} °C</p>
          <p><strong>Fator de Excesso de Calor (EHF):</strong> {ehf}</p>
        </div>
        <br>
        <p>Consulte as ações imediatas de contingência no portal web oficial de Belém.</p>
        <small style="color: #64748b;">Notificação gerada automaticamente pelo fluxo seguro do GitHub Actions.</small>
      </body>
    </html>
    """

    try:
        msg = MIMEMultipart()
        msg["From"] = smtp_user
        msg["To"] = ", ".join(destinatarios)
        msg["Subject"] = assunto
        msg.attach(MIMEText(corpo_html, "html"))

        if int(smtp_port) == 465:
            server = smtplib.SMTP_SSL(smtp_host, int(smtp_port), timeout=15)
        else:
            server = smtplib.SMTP(smtp_host, int(smtp_port), timeout=15)
            server.starttls()
            
        server.login(smtp_user, smtp_pass)
        server.sendmail(smtp_user, destinatarios, msg.as_string())
        server.quit()
        print(f"Alerta transmitido com sucesso para {len(destinatarios)} destinatários sigilosos.")
    except Exception as e:
        print(f"Erro ao transmitir e-mails via SMTP: {e}", file=sys.stderr)

def garantir_malha_geografica_belem():
    """Garante o download da malha territorial oficial de Belém (IBGE 1501402) via API GeoJSON."""
    caminho = "belem_malha.geojson"
    if os.path.exists(caminho) and os.path.getsize(caminho) > 1000:
        return caminho
    url_ibge = "https://servicodados.ibge.gov.br/api/v3/malhas/municipios/1501402?formato=application/vnd.geo+json"
    try:
        import gzip
        req = urllib.request.Request(url_ibge, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=12) as resp:
            raw = resp.read()
            try:
                txt = gzip.decompress(raw).decode("utf-8")
            except Exception:
                txt = raw.decode("utf-8")
            with open(caminho, "w", encoding="utf-8") as f:
                f.write(txt)
            print("Malha territorial oficial de Belém (IBGE 1501402) baixada e salva com sucesso.")
    except Exception as e:
        print(f"Aviso ao baixar malha territorial IBGE de Belém: {e}")
    return caminho

def gerar_html_autocontido(payload):
    """Gera o arquivo HTML autocontido com dados, malha e logo embutidos para visualização local imediata."""
    try:
        import base64
        logo_b64 = ""
        if os.path.exists("logo_sesma.png"):
            with open("logo_sesma.png", "rb") as f:
                logo_b64 = f"data:image/png;base64,{base64.b64encode(f.read()).decode('utf-8')}"
        
        malha_txt = "{}"
        if os.path.exists("belem_malha.geojson"):
            with open("belem_malha.geojson", "r", encoding="utf-8") as f:
                malha_txt = f.read()

        dados_txt = json.dumps(payload, ensure_ascii=False)

        if os.path.exists("index.html") and os.path.exists("app.js"):
            with open("index.html", "r", encoding="utf-8") as f:
                html_base = f.read()
            with open("app.js", "r", encoding="utf-8") as f:
                js_base = f.read()

            if logo_b64:
                html_base = html_base.replace('src="logo_sesma.png"', f'src="{logo_b64}"')
                html_base = html_base.replace('src="imagens_locais/logo_sesma.png"', f'src="{logo_b64}"')

            bloco_dados = f"""
window.DADOS_CLIMA_EMBUTIDOS = {dados_txt};
window.MALHA_BELEM_EMBUTIDA = {malha_txt};
"""
            js_mod = bloco_dados + "\n" + js_base
            js_mod = js_mod.replace(
                "async function obterMalhaGeoBelem() {",
                "async function obterMalhaGeoBelem() {\n  if (window.MALHA_BELEM_EMBUTIDA) return window.MALHA_BELEM_EMBUTIDA;"
            )
            js_mod = js_mod.replace(
                'console.warn("Carregando fallback padrão devido a:", err);',
                'console.warn("Carregando dados oficiais embutidos:", err);\n      if (window.DADOS_CLIMA_EMBUTIDOS) {\n        renderizarPainel(window.DADOS_CLIMA_EMBUTIDOS);\n        return;\n      }'
            )

            html_final = html_base.replace(
                '<script src="app.js"></script>',
                f'<script>\n{js_mod}\n</script>'
            )

            with open("painel_calor_belem.html", "w", encoding="utf-8") as f:
                f.write(html_final)
            print("Arquivo HTML autocontido atualizado: painel_calor_belem.html")
    except Exception as e:
        print(f"Aviso ao gerar HTML autocontido: {e}")

def executar_coleta():
    from datetime import timezone
    hoje = datetime.now(timezone.utc) - timedelta(hours=3) # UTC-3 Belém
    data_alvo = hoje + timedelta(days=4)
    data_alvo_str = data_alvo.strftime("%Y-%m-%d")
    
    url = f"https://clima.saude.gov.br/pa/belem?data={data_alvo_str}&modo=ehf"
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Conectando ao Ministério da Saúde: {url}")
    
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        }
    )
    
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            html = resp.read().decode("utf-8", errors="ignore")
    except Exception as e:
        print(f"Erro ao acessar {url}: {e}", file=sys.stderr)
        sys.exit(1)
        
    padrao = re.compile(r'\{[^{}]*cd_mun:"1501402"[^{}]*\}')
    matches = padrao.findall(html)
    
    if not matches:
        print("Aviso: Nenhum registro de Belém (1501402) encontrado.", file=sys.stderr)
        sys.exit(1)
        
    print(f"Registros brutos localizados: {len(matches)}")
    
    dados_por_data = {}
    for m in matches:
        d_match = re.search(r'data:"([^"]+)"', m)
        if not d_match:
            continue
        dt_str = d_match.group(1)
        
        tmax_m = re.search(r'tmax:([0-9.]+)', m)
        tmin_m = re.search(r'tmin:([0-9.]+)', m)
        tmean_m = re.search(r'tmean:([0-9.]+)', m)
        ehf_m = re.search(r'ehf:([0-9.-]+)', m)
        cls_m = re.search(r'classification:"([^"]+)"', m)
        
        tmax = round(float(tmax_m.group(1)), 1) if tmax_m else 34.0
        tmin = round(float(tmin_m.group(1)), 1) if tmin_m else 23.0
        tmean = round(float(tmean_m.group(1)), 1) if tmean_m else 29.5
        ehf = round(float(ehf_m.group(1)), 2) if ehf_m else 0.0
        classe = mapear_classe(cls_m.group(1)) if cls_m else "Sem excesso"
        
        dados_por_data[dt_str] = {
            "data_iso": dt_str,
            "tmax": tmax,
            "tmin": tmin,
            "tmean": tmean,
            "ehf": ehf,
            "classe": classe
        }
        
    previsoes = []
    for i in range(5):
        dia_dt = hoje + timedelta(days=i)
        iso_str = dia_dt.strftime("%Y-%m-%d")
        dia_nome = formatar_dia_br(dia_dt)
        data_br = dia_dt.strftime("%d/%m/%Y")
        
        if iso_str in dados_por_data:
            item = dados_por_data[iso_str]
            previsoes.append({
                "dia": dia_nome,
                "data_br": data_br,
                "classe": item["classe"],
                "ehf": item["ehf"],
                "tmax": item["tmax"],
                "tmin": item["tmin"],
                "tmean": item.get("tmean", 29.5)
            })
        else:
            previsoes.append({
                "dia": dia_nome,
                "data_br": data_br,
                "classe": "Sem excesso",
                "ehf": 0.0,
                "tmax": 34.0,
                "tmin": 23.0,
                "tmean": 29.5
            })
            
    for p in previsoes:
        info_p = MAPA_DESCRICOES.get(p["classe"], MAPA_DESCRICOES["Sem excesso"])
        p["titulo_nivel"] = info_p["titulo"]
        p["subtitulo_ehf"] = info_p["subtitulo"]

    info_hoje = MAPA_DESCRICOES.get(previsoes[0]["classe"], MAPA_DESCRICOES["Sem excesso"])
    
    # Extração dos parâmetros oficiais do Ministério da Saúde para o mapa de Belém
    p_lat = re.search(r'cd_mun:"1501402"[^}]*lat:([0-9.-]+)', html)
    p_lon = re.search(r'cd_mun:"1501402"[^}]*lon:([0-9.-]+)', html)
    p_pico = re.search(r'cd_mun:"1501402"[^}]*tmax_pico_p75:([0-9.]+)', html)

    lat_belem = float(p_lat.group(1)) if p_lat else -1.240717
    lon_belem = float(p_lon.group(1)) if p_lon else -48.459911
    pico_habitual = round(float(p_pico.group(1)), 1) if p_pico else 34.1

    indicadores_mapa = {
        "ehf": previsoes[0]["ehf"],
        "media": previsoes[0].get("tmean", 29.5),
        "hoje": previsoes[0]["tmax"],
        "pico_habitual": pico_habitual,
        "tmin": previsoes[0]["tmin"],
        "lat": lat_belem,
        "lon": lon_belem
    }
    
    payload = {
        "municipio": "Belém - PA",
        "codigo_ibge": "1501402",
        "data_base_iso": hoje.strftime("%Y-%m-%d"),
        "data_base_br": hoje.strftime("%d/%m/%Y"),
        "hora_consulta": hoje.strftime("%H:%M:%S"),
        "sucesso": True,
        "fonte_url": f"https://clima.saude.gov.br/pa/belem?modo=ehf&data={hoje.strftime('%Y-%m-%d')}",
        "titulo_nivel": info_hoje["titulo"],
        "subtitulo_ehf": info_hoje["subtitulo"],
        "indicadores_mapa": indicadores_mapa,
        "hoje": previsoes[0],
        "previsoes": previsoes
    }
    
    # Salvar JSON público que alimenta o GitHub Pages e garantir malha oficial IBGE
    garantir_malha_geografica_belem()
    arquivo_json = "dados_clima_atual.json"
    with open(arquivo_json, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=4, ensure_ascii=False)
    print(f"Arquivo gerado com sucesso: {arquivo_json}")
    
    # Gerar HTML autocontido com os dados atualizados
    gerar_html_autocontido(payload)
    
    # Salvar CSV Histórico
    arquivo_csv = "historico_ehf.csv"
    existe = os.path.exists(arquivo_csv)
    with open(arquivo_csv, "a", encoding="utf-8") as f:
        if not existe:
            f.write("data_iso,hora_consulta,tmax,tmin,ehf,classe\n")
        f.write(f"{payload['data_base_iso']},{payload['hora_consulta']},{payload['hoje']['tmax']},{payload['hoje']['tmin']},{payload['hoje']['ehf']},{payload['hoje']['classe']}\n")
    print(f"Histórico atualizado: {arquivo_csv}")
    
    # Disparar alertas por e-mail caso o nível seja crítico ou se configurado
    if payload["hoje"]["classe"] in ["Severo", "Extremo"]:
        print(f"Status em nível crítico ({payload['hoje']['classe']}). Acionando disparo de alertas...")
        disparar_alerta_smtp(payload)
    elif os.environ.get("FORCAR_DISPARO_TESTE") == "true":
        disparar_alerta_smtp(payload)

    print(f"\nSTATUS VIGENTE EM BELÉM: {info_hoje['titulo']}")
    print(f"{info_hoje['subtitulo']}")
    print(f"Hoje ({payload['data_base_br']}): {payload['hoje']['tmax']}°C | EHF: {payload['hoje']['ehf']}")
    for p in payload["previsoes"]:
        print(f"  * {p['dia']} ({p['data_br']}) -> Tmax: {p['tmax']}°C | EHF: {p['ehf']} | {p['titulo_nivel']} | {p['subtitulo_ehf']}")

if __name__ == "__main__":
    executar_coleta()
