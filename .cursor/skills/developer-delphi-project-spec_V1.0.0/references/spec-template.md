# Template: Documento de Especificacao de Software (SPEC)

---

## SECAO 1 — Identificacao do Projeto

| Campo | Valor |
|---|---|
| Nome do Sistema | |
| Modulo / Subsistema | |
| Versao da SPEC | 1.0 |
| Data de Criacao | |
| Autor | |
| Revisado por | |
| Status | Rascunho / Em revisao / Aprovado |

---

## SECAO 2 — Objetivo e Escopo

### 2.1 Objetivo
Descreva em 2-4 frases qual problema este sistema/modulo resolve e qual e o resultado esperado.

### 2.2 Escopo (o que esta incluido)
- Item 1
- Item 2

### 2.3 Fora do Escopo (o que NAO esta incluido)
- Item 1
- Item 2

---

## SECAO 3 — Atores e Perfis de Usuario

Liste todos os usuarios/sistemas que interagem com o software.

| ID | Ator | Descricao | Permissoes |
|---|---|---|---|
| AT-001 | | | |
| AT-002 | | | |

---

## SECAO 4 — Requisitos Funcionais

O que o sistema **deve fazer**. Um requisito por linha, numerado.

| ID | Descricao | Prioridade | Ator | Observacoes |
|---|---|---|---|---|
| RF-001 | | Alta / Media / Baixa | | |
| RF-002 | | | | |

**Prioridades:**
- Alta: essencial para o funcionamento basico
- Media: importante mas pode ser entregue em fase posterior
- Baixa: desejavel, pode ser descartado se necessario

---

## SECAO 5 — Requisitos Nao Funcionais

Restricoes de qualidade, performance, seguranca e conformidade.

| ID | Categoria | Descricao | Criterio de Aceitacao |
|---|---|---|---|
| RNF-001 | Performance | | |
| RNF-002 | Seguranca | | |
| RNF-003 | Disponibilidade | | |
| RNF-004 | Usabilidade | | |
| RNF-005 | Compatibilidade | | |

**Categorias comuns:** Performance, Seguranca, Disponibilidade, Usabilidade, Compatibilidade,
Manutenibilidade, Escalabilidade, Conformidade Legal.

---

## SECAO 6 — Casos de Uso

### UC-001: [Nome do Caso de Uso]

| Campo | Valor |
|---|---|
| ID | UC-001 |
| Nome | |
| Ator Principal | |
| Pre-condicoes | |
| Pos-condicoes | |
| Trigger | |

**Fluxo Principal:**
1. Passo 1
2. Passo 2
3. Passo 3

**Fluxo Alternativo:**
- 2a. Se [condicao]: ...

**Fluxo de Excecao:**
- 2b. Se [erro]: ...

---

## SECAO 7 — User Stories (opcional / complementar aos casos de uso)

| ID | Como... | Quero... | Para que... | Criterios de Aceitacao |
|---|---|---|---|---|
| US-001 | [ator] | [acao] | [beneficio] | - [ ] criterio 1 |
| US-002 | | | | |

---

## SECAO 8 — Regras de Negocio

Restricoes e politicas que o sistema deve respeitar independentemente do fluxo.

| ID | Descricao | Origem (lei / politica / cliente) |
|---|---|---|
| RN-001 | | |
| RN-002 | | |

---

## SECAO 9 — Fluxos de Tela e Navegacao

Descreva a sequencia de telas e transicoes. Use diagramas ASCII ou lista de telas se nao houver wireframe.

### Mapa de Navegacao

```
[Tela Login]
    └─► [Tela Principal]
            ├─► [Modulo A]
            │       └─► [Cadastro]
            │               └─► [Confirmacao]
            └─► [Modulo B]
                    └─► [Listagem]
                            └─► [Edicao]
```

### Descricao de Telas

#### Tela: [Nome]
- **Proposito:** o que o usuario faz aqui
- **Campos:** lista de campos com tipo e obrigatoriedade
- **Acoes:** botoes e suas consequencias
- **Validacoes:** regras de validacao da tela
- **Requisitos relacionados:** RF-001, RN-002

---

## SECAO 10 — Modelo de Dados

### 10.1 Entidades Principais

| Entidade | Descricao | Atributos Principais |
|---|---|---|
| | | |

### 10.2 Relacionamentos

```
[Cliente] 1 ──── N [Pedido]
[Pedido]  1 ──── N [ItemPedido]
[ItemPedido] N ── 1 [Produto]
```

### 10.3 Tabelas / Estruturas de Dados

Descreva as tabelas de banco de dados ou estruturas Delphi relevantes para este modulo.

---

## SECAO 11 — Integracoes Externas

| ID | Sistema Externo | Tipo | Protocolo | Direcao | Descricao |
|---|---|---|---|---|---|
| INT-001 | | API REST / WebService / DLL | HTTP / TCP / COM | Entrada / Saida | |

---

## SECAO 12 — Restricoes e Premissas

### 12.1 Restricoes Tecnicas
- Delphi versao minima: [X]
- Banco de dados: [nome e versao]
- Sistema operacional: [Windows / macOS / mobile]
- Dependencias obrigatorias: [componentes, frameworks]

### 12.2 Premissas
Condicoes assumidas como verdadeiras para este documento. Se uma premissa for invalidada,
a SPEC deve ser revisada.

- Premissa 1
- Premissa 2

---

## SECAO 13 — Criterios de Aceitacao Global

O sistema sera considerado aprovado quando:

- [ ] Todos os requisitos de prioridade Alta estiverem implementados e testados
- [ ] Todos os casos de uso criticos executarem sem erros
- [ ] Requisitos nao funcionais de performance atendidos (ex: tempo de resposta < 2s)
- [ ] Testes unitarios cobrindo ao menos [X]% do codigo de negocio
- [ ] Aprovacao formal do cliente / product owner

---

## SECAO 14 — Historico de Revisoes

| Versao | Data | Autor | Descricao da Alteracao |
|---|---|---|---|
| 1.0 | | | Versao inicial |
| 1.1 | | | |
