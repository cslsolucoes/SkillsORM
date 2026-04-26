# Guia IARC — Classificacao de Conteudo na Microsoft Store

**IARC (International Age Rating Coalition):** sistema unificado de
classificacao de conteudo para apps e jogos, adotado pela Microsoft Store,
Google Play, PlayStation Store e outras plataformas.

> **AVISO:** O questionario IARC e o processo podem mudar. Verificar em
> `https://www.globalratings.com/` e no Partner Center.

---

## O que e IARC e por que e obrigatorio

- Sistema de classificacao de conteudo que gera ratings simultaneos para
  multiplas regioes com um unico questionario
- **Obrigatorio** para TODOS os apps na Microsoft Store
- Sem classificacao: a submission e **rejeitada automaticamente**
- Gratuito — sem custo adicional alem da taxa de conta do Partner Center

### Orgaos de classificacao suportados pelo IARC

| Regiao | Orgao | Escalas |
|--------|-------|---------|
| EUA / Canada | ESRB | Everyone (E), E10+, Teen (T), Mature (M), Adults Only (AO) |
| Europa / maioria do mundo | PEGI | PEGI 3, 7, 12, 16, 18 |
| Alemanha | USK | 0, 6, 12, 16, 18 |
| Brasil | DJCTQ (Classind) | Livre, 10, 12, 14, 16, 18 |
| Australia | ACB | G, PG, M, MA 15+, R 18+ |
| Coreia do Sul | GRAC | ALL, 12, 15, 18 |

---

## Como Preencher o Questionario IARC

### Passo 1 — Acessar o questionario

**Caminho no Partner Center:**
```
Apps and games
  → [Seu app]
    → Age ratings
      → Start questionnaire
```

### Passo 2 — Tipo de produto

Selecionar: **App** (nao Game — exceto se for jogo)

### Passo 3 — Categorias de conteudo

O questionario pergunta sobre presenca de conteudo nas seguintes categorias:

| Categoria | Opcoes tipicas |
|-----------|---------------|
| Violence | None, Mild, Moderate, Intense |
| Sexual content | None, Mild, Moderate, Explicit |
| Language | None, Mild, Strong |
| Drug/alcohol use | None, Reference, Use |
| Gambling | None, Simulated, Real money |
| Fear / horror | None, Mild, Intense |
| In-app purchases | None, Yes (without real currency), Yes (with real currency) |
| Social interaction | None, Users interact, Shares location |
| User-generated content | None, Yes |

### Passo 4 — Submeter e receber as classificacoes

- Apos responder: classificacoes geradas instantaneamente
- Revisar as classificacoes antes de confirmar
- Se discordar: e possivel corrigir as respostas e regenerar

---

## Classificacoes Tipicas por Tipo de App

### Apps de Produtividade e Negocios (ex.: GestorERP)

| Orgao | Classificacao tipica | Motivo |
|-------|---------------------|--------|
| ESRB | **Everyone (E)** | Sem conteudo inadequado |
| PEGI | **PEGI 3** | Adequado para todas as idades |
| DJCTQ | **Livre** | Sem restricao de faixa etaria |
| USK | **USK 0** | Sem restricao |
| ACB | **G (General)** | Para todos os publicos |

**Respostas tipicas do questionario para ERP:**
- Violence: None
- Sexual content: None
- Language: None
- Drug/alcohol use: None
- Gambling: None
- In-app purchases: Yes (with real currency) [se houver compras]
- Social interaction: None [se nao tiver chat/colaboracao em tempo real]
- User-generated content: None

### Apps com In-App Purchases

- A presenca de compras in-app com dinheiro real adiciona um aviso:
  **"In-App Purchases"** ou **"Compras no app"** abaixo da classificacao
- Nao altera a faixa etaria se o restante do conteudo for adequado

### Apps com Chat / Colaboracao

- Se usuarios podem se comunicar em tempo real: adiciona aviso
  **"Users Interact"** ou similar
- Pode elevar a classificacao minima em alguns orgaos (ex.: PEGI 7)

### Aplicativos de Noticias / RSS

- Conteudo de noticias pode conter violencia ou conteudo adulto de terceiros
- Tipicamente: ESRB E10+ / PEGI 7 com aviso de "News/Information"

---

## Impacto da Classificacao na Store

| Classificacao | Impacto |
|--------------|---------|
| E / PEGI 3 / Livre | Visivel para todos; sem restricoes de busca |
| E10+ / PEGI 7 | Visivel para todos; pode aparecer em secoes "Teens" |
| Teen / PEGI 12 | Filtros parentais podem ocultar para menores |
| Mature / PEGI 16-18 | Filtros parentais ocultos; usuario deve confirmar idade |
| Adults Only / PEGI 18 | Nao disponivel na Store padrao do Windows |

### Configuracoes parentais do Windows

Pais que configuram contas de crianca no Windows (Family Safety) podem
restringir downloads por classificacao. Apps ESRB E e PEGI 3 passam por
qualquer configuracao parental.

---

## Atualizando a Classificacao

Se o conteudo do app mudar (ex.: adicionar recursos com conteudo mais
sensivel), o questionario deve ser refeito:

**Caminho:**
```
Apps and games → [Seu app] → Age ratings → Update questionnaire
```

Se a classificacao mudar significativamente, a Store pode solicitar revisao.

---

## Erros Comuns com IARC

| Erro | Solucao |
|------|---------|
| Submission rejeitada por falta de IARC | Preencher o questionario antes de submeter |
| Classificacao inesperadamente alta | Revisar respostas; "None" em todas as categorias de conteudo = E/PEGI 3 |
| Classificacao nao aparece na Store | Aguardar propagacao (algumas horas apos aprovacao) |
| Questionario nao disponivel | Verificar se o tipo de produto foi selecionado corretamente |

---

## Links de Referencia

- IARC global: `https://www.globalratings.com/`
- PEGI: `https://pegi.info/`
- ESRB: `https://www.esrb.org/`
- DJCTQ: `https://www.gov.br/mj/pt-br/assuntos/seus-direitos/classificacao/`
- Microsoft Store Age Ratings: `https://learn.microsoft.com/windows/apps/publish/age-ratings`
