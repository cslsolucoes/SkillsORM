# Esboço de Telas — {Projeto} (Vx.y)

Documentação de telas/formulários do projeto **{Projeto}**. Inclui responsabilidade, campos, ações e fluxo de cada form de teste ou produção.

**Versao:** `Vx.y`
**Escopo:** {lista de telas/formulários cobertos}.

---

## Convenção

- **Sem lógica de negócio nem SQL direto em Views** (RN-5).
- Views chamam APIs de módulos/ORM e exibem resultados.
- Nomes de form: `ufrm{NomeForm}.pas` em `src/Views/`.

---

## {TfrmNomeForm} — {Título humano do formulário}

**Unit:** `ufrm{NomeForm}.pas`
**Localização:** `src/Views/ufrm{NomeForm}.pas`
**Status:** [ ] Esboço | [X] Implementado | [ ] Pendente

### Propósito

{Descrição do que este formulário demonstra ou testa.}

### Componentes principais

| Componente | Tipo | Propósito |
|------------|------|-----------|
| {btn{Acao}} | TButton | {ação ao clicar} |
| {lbl{Info}} | TLabel | {informação exibida} |
| {memo{Log}} | TMemo | {log/resultado} |

### Fluxo principal

1. {Passo 1 — ex.: Usuário preenche campos de conexão}.
2. {Passo 2 — ex.: Clica em Conectar}.
3. {Passo 3 — ex.: Resultado exibido no Memo}.

### APIs chamadas

- `{IClassName}.{Metodo}` — {propósito}.

### Observações

- {Observação ou pendência específica deste form}.

---

## {TfrmOutroForm} — {Título}

*(Repetir seção acima para cada formulário coberto.)*

---

## Índice de formulários

| Form | Unit | Status | DPR |
|------|------|--------|-----|
| `Tfrm{NomeForm}` | `ufrm{NomeForm}.pas` | [X] / [ ] | [X] / [ ] no uses |

---

**Referências:** [Analise/Views/Views_Formularios.md](../../Analise/Views/Views_Formularios.md) | [roadmap_V1.0.mdc](../../.cursor/rules/roadmap_V1.0.mdc)

---

**Changelog (este arquivo):**

- Vx.y (DD/MM/AAAA): {descrição}.
- V1.0 (DD/MM/AAAA): Criação do esboço de telas de {projeto}.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).