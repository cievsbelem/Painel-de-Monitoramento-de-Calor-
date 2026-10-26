# Painel Oficial de Vigilância de Excesso de Calor — Belém / PA
### Centro de Informações Estratégicas em Vigilância em Saúde (CIEVS Belém)
### Secretaria Municipal de Saúde de Belém (SESMA) · Prefeitura Municipal de Belém

[![Status](https://img.shields.io/badge/Status-Operacional-success.svg)](#)
[![GitHub Pages](https://img.shields.io/badge/Acesso_Online-GitHub_Pages-blue.svg)](https://cievsbelem.github.io/Painel-de-Monitoramento-de-Calor-/)
[![Fonte Oficial](https://img.shields.io/badge/Fonte-Minist%C3%A9rio_da_Sa%C3%BAde-1e3a8a.svg)](https://clima.saude.gov.br/pa/belem?modo=ehf)
[![IBGE Belém](https://img.shields.io/badge/IBGE-1501402-0284c7.svg)](#)

---

## 🌐 Acesso Público ao Painel (GitHub Pages)

Acesse o painel em tempo real:
👉 **[https://cievsbelem.github.io/Painel-de-Monitoramento-de-Calor-/](https://cievsbelem.github.io/Painel-de-Monitoramento-de-Calor-/)**

---

## 📌 Visão Geral

Painel oficial desenvolvido para monitoramento contínuo e alerta precoce de ondas e excesso de calor no município de **Belém - PA (Código IBGE: 1501402)**, em conformidade com o **Plano de Contingência Local de Enfrentamento ao Calor Extremo (2026)** da SESMA e os dados operacionais do **Ministério da Saúde**.

O sistema baseia-se na metodologia internacional do **EHF (*Excess Heat Factor* / Nairn & Fawcett)**, alimentado automaticamente pelos modelos meteorológicos de alta resolução do **ECMWF** integrados à plataforma oficial de Clima e Saúde do Ministério da Saúde.

---

## 🌡️ Matriz Oficial dos 4 Níveis de Calor

| Nível | Classificação EHF | Cor do Alerta | Ações para a População |
| :--- | :--- | :--- | :--- |
| **NÍVEL 1: NORMALIDADE** | Sem excesso de calor | 🟢 Verde (`#1b5e20`) | Rotina habitual; hidratação regular. |
| **NÍVEL 2: ATENÇÃO** | EHF Baixo | 🟡 Amarelo (`#ca8a04`) | Aumento da ingestão de água mesmo sem sede; atenção a idosos e crianças. |
| **NÍVEL 3: ALERTA** | EHF Severo | 🟠 Laranja (`#ea580c`) | Evitar exposição solar direta entre 10h e 16h; procurar ambientes arejados. |
| **NÍVEL 4: EMERGÊNCIA** | EHF Extremo | 🔴 Vermelho (`#dc2626`) | Risco elevado à saúde humana; acionamento imediato da rede de urgência e SAMU 192. |

---

## 🗺️ Mapa Oficial com Malha Territorial do IBGE

- **Malha Territorial:** Vetor geográfico oficial do município de Belém (`IBGE 1501402`), obtido via API do IBGE (`https://servicodados.ibge.gov.br/api/v3/malhas/municipios/1501402?formato=application/vnd.geo+json`).
- **Pintura Dinâmica:** O polígono de Belém é colorido automaticamente na cor correspondente ao **nível vigente** e permite alternância interativa na barra operacional para visualização das projeções de **D+0 a D+4**.
- **Indicadores Oficiais Acima do Mapa:**
  - **EHF:** Fator de Excesso de Calor do Ministério da Saúde.
  - **Média:** Temperatura média diária de 24h (*Tmean*).
  - **Hoje:** Temperatura máxima prevista para o dia da consulta (*Tmax*).
  - **Pico habitual:** Climatologia de referência do 75º percentil (*P75 Clima*).

---

## 🤖 Coleta Automática 24/7 (GitHub Actions / CRONJOB)

O repositório conta com um fluxo de automação configurado em [`.github/workflows/cron_coleta_clima.yml`](.github/workflows/cron_coleta_clima.yml):
- **Execução:** 3 vezes ao dia (06:00, 12:00 e 18:00 no Horário de Belém).
- **Robô Extrator:** [coletor_clima.py](coletor_clima.py) realiza a consulta simultânea ao portal oficial do Ministério da Saúde (`clima.saude.gov.br/pa/belem`).
- **Publicação:** Salva `dados_clima_atual.json` e faz o deploy automático no GitHub Pages, garantindo custo zero e disponibilidade ininterrupta.

---

## 📋 Ações Integradas dos Setores de Belém

O painel consolida e orienta as ações imediatas dos setores estratégicos da capital para cada nível de alerta:
1. **CIEVS Belém, Vigilância Epidemiológica & NHEs**
2. **Controle de Endemias**
3. **Vigilância Sanitária e Vigilância Ambiental**
4. **CEREST — Saúde do Trabalhador**
5. **Atenção Primária à Saúde (APS), Urgência e SAMU 192**
6. **Regulação do Acesso e Comunicação em Saúde**

---

## 🏛️ Realização

- **Prefeitura Municipal de Belém**
- **Secretaria Municipal de Saúde de Belém (SESMA)**
- **Departamento de Vigilância em Saúde (DEVS)**
- **Centro de Informações Estratégicas em Vigilância em Saúde (CIEVS Belém)**
- **Fonte Oficial:** Ministério da Saúde · Governo Federal
