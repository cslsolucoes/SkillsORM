# Guia de Metadados da Store — Preenchimento e ASO

**ASO (App Store Optimization):** conjunto de tecnicas para maximizar
visibilidade e conversao na Microsoft Store.

> **AVISO:** Validar campos e limites atuais em `partner.microsoft.com` —
> a Microsoft pode alterar limites e campos sem aviso previo.

---

## Parte 1 — Navegando ate os Metadados

**Caminho no Partner Center:**
```
Apps and games
  → [Seu app]
    → Submissions
      → [Submission atual]
        → Store listings
          → [Idioma: pt-BR]
```

Cada idioma tem sua propria pagina de metadados. Comece com `pt-BR` e `en-US`.

---

## Parte 2 — Campos de Texto

### 2.1 — Nome do app (App name)

- **Limite:** 256 caracteres
- **Dica ASO:** Incluir a palavra-chave principal no nome ajuda no ranqueamento
- **Exemplo:** "GestorERP — Gestao Empresarial" (melhor que apenas "GestorERP")
- **Regra:** Deve ser identico ao nome reservado no Partner Center

### 2.2 — Descricao curta (Short description)

- **Limite:** 270 caracteres
- **Exibicao:** Aparece nos resultados de busca da Store (como meta description)
- **Dica ASO:** Incluir as 2-3 palavras-chave principais; foco no beneficio central
- **Exemplo:**
  ```
  Sistema completo de gestao empresarial: vendas, estoque, financeiro e
  relatorios. Ideal para PMEs. Integracao nativa com NF-e e NFS-e.
  ```

### 2.3 — Descricao completa (Description)

- **Limite:** 10.000 caracteres por idioma
- **Estrutura recomendada:**
  ```
  [Paragrafo 1: proposta de valor — 2-3 sentencas]
  [Paragrafo 2: funcionalidades principais — lista com bullets]
  [Paragrafo 3: diferenciais — o que torna seu app unico]
  [Paragrafo 4: publico-alvo — quem vai se beneficiar]
  [Paragrafo 5: CTA — chamada para acao]
  ```
- **Dicas ASO:**
  - Usar palavras-chave nos primeiros 250 caracteres (mais peso no ranqueamento)
  - Mencionar features especificas que usuarios pesquisam
  - Evitar texto generico como "o melhor app de gestao"

### 2.4 — Notas de versao (What's new in this version)

- **Limite:** 1.500 caracteres por idioma
- **Obrigatorio:** em cada nova submission (incluindo a primeira)
- **Exemplo:**
  ```
  v1.0.0 — Lancamento inicial
  - Modulo de vendas com frente de caixa
  - Controle de estoque com alertas de minimo
  - Relatorios financeiros: DRE e fluxo de caixa
  - Integracao com NF-e (SEFAZ)
  - Suporte a multiplos usuarios e permissoes
  ```

### 2.5 — Palavras-chave (Keywords)

- **Limite:** 7 palavras ou frases por idioma
- **Dica ASO:** Focar em termos que os usuarios realmente pesquisam
- **Exemplo para GestorERP:**
  ```
  ERP, gestao empresarial, controle de estoque, emissao NF-e,
  software financeiro, PDV, PME
  ```

### 2.6 — Titulo curto (Short title)

- **Limite:** 50 caracteres
- **Uso:** Tiles e notificacoes do Windows
- **Exemplo:** "GestorERP"

---

## Parte 3 — URLs e Contato

| Campo | Obrigatorio | Dica |
|-------|------------|------|
| URL de politica de privacidade | Sim (se coleta dados) | Deve ser pagina dedicada, nao homepage |
| URL de suporte | Recomendado | Pagina com FAQ ou formulario de contato |
| URL de informacoes adicionais | Opcional | Site do produto ou landing page |
| Email de contato | Recomendado | Email que usuarios verao na Store |

> **ATENCAO:** A URL de politica de privacidade deve estar acessivel
> publicamente, sem login. A Microsoft verifica durante a certificacao.

---

## Parte 4 — Assets Visuais

### 4.1 — Icone da Store (Obrigatorio)

- **Tamanho:** 300×300 px
- **Formato:** PNG
- **Fundo:** Transparente ou com cor solida
- **Dica:** Usar o logo da empresa/produto com boa legibilidade em tamanho pequeno
- **Evitar:** Texto muito pequeno; bordas que se perdem no fundo da Store

### 4.2 — Screenshots (Obrigatorio — min. 1)

| Plataforma | Minimo | Maximo | Resolucao minima | Resolucao maxima |
|------------|--------|--------|-----------------|-----------------|
| Desktop | 1 | 10 | 1366×768 px | 3840×2160 px |
| Mobile | 0 | 10 | 768×1366 px | 3840×2160 px |

**Dicas para screenshots eficazes:**
- Mostrar a funcionalidade mais importante na primeira screenshot
- Adicionar texto explicativo sobre a imagem (overlay) indicando a feature
- Usar dados realistas, nao placeholders "Lorem ipsum"
- Capturar em modo Release, nao Debug (sem toolbars de debug)
- Formato: PNG ou JPEG

### 4.3 — Arte Promocional (Recomendado)

- **Hero art:** 1920×1080 px PNG — aparece em destaques editoriais
- **Opcional mas aumenta chances de featured placement**

### 4.4 — Trailer / Video (Opcional)

- URL do YouTube ou arquivo de video
- Limite: 60 segundos recomendado
- Idioma: adicionar video por idioma se possivel

---

## Parte 5 — Categoria e Publico

### 5.1 — Categoria principal

Escolher a categoria mais relevante:

| Categoria | Subcategoria sugerida para ERP |
|-----------|-------------------------------|
| Business | Productivity, Finance |
| Productivity | Business, Tools |

### 5.2 — Publico-alvo

- Marcar "Enterprise" se o app for voltado para empresas
- Isso pode influenciar onde o app aparece na Store para buscas corporativas

---

## Parte 6 — Localizacao

**Estrategia de idiomas:**

| Idioma | Prioridade | Motivo |
|--------|-----------|--------|
| pt-BR | Alta | Mercado primario |
| en-US | Alta | Store global; fallback padrao |
| es-ES / es-MX | Media | Mercado LATAM |

Para cada idioma adicional:
- Traduzir descricao e notas de versao (nao apenas Google Translate)
- Adaptar screenshots se a UI suportar o idioma
- Ajustar palavras-chave para os termos usados no pais

---

## Parte 7 — Preco e Disponibilidade

**Preco:**
- Free: distribuicao maxima; monetizar via in-app purchases
- Free trial: periodo definido; converte para pago automaticamente
- Pago: definir preco por mercado (a Microsoft sugere conversao automatica)

**Disponibilidade por mercado:**
- Por padrao: todos os mercados disponiveis
- Restringir se necessario por compliance ou licencas regionais
- Brasil = "Brazil" na lista de mercados

---

## Checklist de Metadados

- [ ] Icone 300×300 PNG carregado
- [ ] Pelo menos 1 screenshot desktop >= 1366×768 carregada
- [ ] Descricao preenchida em pt-BR (ate 10.000 chars)
- [ ] Descricao curta preenchida (ate 270 chars)
- [ ] Notas de versao preenchidas
- [ ] Ate 7 palavras-chave definidas
- [ ] URL de privacidade valida e acessivel
- [ ] Categoria selecionada
- [ ] Preco/disponibilidade configurados
