# Guia de Publicação no GitHub Pages com CRONJOB Automático (GitHub Actions)
### Sistema Oficial de Vigilância de Excesso de Calor — CIEVS Belém / SESMA

---

## 1. O que foi Preparado nesta Pasta

Esta pasta foi configurada para funcionar como um portal web estático moderno no **GitHub Pages**, com atualização automática de dados através de um **CRONJOB no GitHub Actions**:

```
Painel calor/
├── index.html                     # Portal principal oficial para o GitHub Pages
├── app.js                         # Lógica reativa do dashboard (consome o JSON)
├── dados_clima_atual.json         # Base de dados atualizada pela automação
├── destinatarios.json             # Lista de pontos focais setoriais
├── historico_ehf.csv              # Série temporal com registro diário de calor
├── coletor_clima.py               # Robô coletor em Python (roda em 2s no GitHub Actions)
├── coletor_clima.R                # Robô coletor alternativo em R
├── app.R                          # Versão R Shiny (caso queira rodar localmente)
└── .github/
    └── workflows/
        └── cron_coleta_clima.yml  # CRONJOB que extrai dados e publica no Pages
```

---

## 2. Como Funciona a Arquitetura em Nuvem

```
  [Ministério da Saúde]
  (clima.saude.gov.br)
          │
          │ (06:00, 12:00 e 18:00 diariamente via CRON)
          ▼
   [GitHub Actions]
  (coletor_clima.py)
          │
          ├─► Atualiza 'dados_clima_atual.json' e 'historico_ehf.csv'
          ├─► Faz o commit automático no repositório
          ▼
   [GitHub Pages]
    (index.html)  ◄─── Acessado pela população e equipes de saúde
                       (Carregamento instantâneo, 100% gratuito e sem limites)
```

---

## 3. Passo a Passo para Publicar no GitHub Pages

### 1º Passo: Repositório Configurado no GitHub
O repositório já está definido em:
👉 **`https://github.com/cievsbelem/Painel-de-Monitoramento-de-Calor-`**

### 2º Passo: Subir os Arquivos para o Repositório
O remote `origin` já foi adicionado na sua máquina local apontando para este repositório. Para enviar tudo:
```bash
git push -u origin main
```

### 3º Passo: Habilitar o GitHub Actions no GitHub Pages
1. No seu repositório no GitHub (`https://github.com/cievsbelem/Painel-de-Monitoramento-de-Calor-`), clique na aba **Settings** (Configurações).
2. No menu lateral esquerdo, clique em **Pages**.
3. Em **Build and deployment** $\rightarrow$ **Source**, mude de *Deploy from a branch* para:
   👉 **GitHub Actions**
4. Salve a alteração.

### 4º Passo: Conceder Permissão de Escrita ao Robô
Para que o CRONJOB consiga salvar o `dados_clima_atual.json` no repositório todos os dias:
1. Ainda em **Settings**, clique em **Actions** $\rightarrow$ **General** no menu esquerdo.
2. Role até a seção **Workflow permissions** (no final da página).
3. Selecione a opção:
   👉 **Read and write permissions**
4. Marque a caixa **Allow GitHub Actions to create and approve pull requests** e clique em **Save**.

---

## 4. Como Testar o CRONJOB Imediatamente

Você não precisa esperar o próximo horário programado para ver o sistema funcionando:
1. No seu repositório, clique na aba **Actions**.
2. No menu lateral esquerdo, clique no fluxo:
   👉 **CRONJOB & Deploy GitHub Pages - Clima Belém**
3. Clique no botão **Run workflow** (no lado direito) e confirme em **Run workflow**.
4. Em aproximadamente 30 a 45 segundos, o GitHub Actions:
   - Conectará ao portal do Ministério da Saúde.
   - Extrairá a temperatura e o EHF oficial de Belém.
   - Atualizará o `dados_clima_atual.json`.
   - Publicará o site no ar.

O link público definitivo do painel é:
🌐 **`https://cievsbelem.github.io/Painel-de-Monitoramento-de-Calor-/`**

---

## 5. Vantagens desta Abordagem

1. **Custo Zero e Sem Limites:** O Shinyapps.io no plano gratuito tem um limite de 25 horas mensais e desliga o servidor quando inativo. O GitHub Pages não tem limite de horas e fica 24 horas por dia online.
2. **Velocidade Extrema:** A página carrega em menos de 1 segundo em qualquer celular ou computador.
3. **Autonomia:** O CRONJOB roda nos servidores do GitHub, sem necessitar de nenhum computador do CIEVS ligado para manter os dados atualizados.
