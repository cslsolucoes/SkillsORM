---
name: developer-delphi-coding-standards
description: >
  Delphi Style Guide completo: prefixos obrigatórios (F/A/L/C_/T/I/E/P), comandos proibidos
  (with/Break/Continue/Exit/Real), formatação (indentação 2 espaços, margem 120, begin em linha
  própria), estrutura de classes, prefixos de componentes VCL/FMX. Bilíngue pt-BR/en-US.
  Ativar quando o usuário mencionar: arquivos .pas/.dpr/.dfm/.dpk/.dproj, código Object Pascal,
  Delphi, FireMonkey (FMX), VCL, FireDAC, RAD Studio, Embarcadero, nomenclatura, indentação,
  prefixos, classes, métodos, componentes, formatação de código Delphi, Delphi Style Guide,
  padrões de codificação, naming conventions.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-coding-standards

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | Standards / Style Guide |

## Responsabilidade única

Carregar e aplicar automaticamente o Delphi Style Guide completo: prefixos, formatação,
comandos proibidos, estrutura de classes e prefixos de componentes VCL/FMX.

## When to use

- Revisar ou escrever código Delphi seguindo padrões canônicos
- Definir nomenclatura em projeto novo ou legado
- Auditar conformidade com o Delphi Style Guide

## When NOT to use

- Laudo técnico completo → `developer-delphi-project-audit`
- Escrever código novo completo → `developer-delphi-coding-workflow`
- Testes unitários → `developer-delphi-testing-dunitx`

---

## §1 — Idioma de saída

Detecte o idioma da primeira mensagem. pt-BR (padrão) ou en-US.
Identificadores Delphi (prefixos, exemplos de código) **não são traduzidos** — apenas a prosa.

---

## §2 — Prefixos obrigatórios

| Escopo | Prefixo | Correto | Errado |
|--------|---------|---------|--------|
| Field de classe | `F` | `FNome`, `FValorTotal` | sem prefixo |
| Parâmetro de método | `A` | `ANome`, `AValor` | `p`, `P` |
| Variável local | `L` | `LNome`, `LQryAux` | `w`, sem prefixo |
| Constante | `C_` + MAIÚSC | `C_MAX_TENT` | `cMax`, `MAX` |
| Classe / Tipo | `T` | `TCliente` | sem prefixo |
| Interface | `I` | `IClienteService` | sem prefixo |
| Exceção | `E` | `EClienteNaoEncontrado` | sem prefixo |
| Ponteiro | `P` | `PCliente` | sem prefixo |

> **NUNCA** usar `p` como prefixo de parâmetro — confunde com ponteiro.
> **NUNCA** notação húngara: `sNome`, `iCount`, `bAtivo`.
> **NUNCA** underline em identificadores (exceto `C_` em constantes).

Referência completa: `references/naming-conventions.md`

---

## §3 — Comandos proibidos

| Comando | Motivo | Alternativa |
|---------|--------|-------------|
| `with` | Dificulta depuração, confunde compilador | Referência explícita `Obj.Campo` |
| `Break` | Saída deve estar na condição do loop | Reestruturar o loop |
| `Continue` | Desvio dificulta compreensão | Reestruturar o bloco |
| `Exit` | Apenas como guard clause no INÍCIO | Guard clause única no início do método |
| `Real` | Obsoleto | `Double` ou `Currency` |
| Variáveis globais de unit | Acoplamento implícito | `class var` |

Referência completa: `references/forbidden-commands.md`

---

## §4 — Tipos de ponto flutuante

| Tipo | Uso | Status |
|------|-----|--------|
| `Currency` | Valores monetários | ✅ preferido (evita arredondamento) |
| `Double` | Cálculos científicos | ✅ OK |
| `Extended` | Apenas quando estritamente necessário | ⚠️ usar com cuidado |
| `Real` | — | 🚫 PROIBIDO |

---

## §5 — Passagem de parâmetros

```pascal
// CORRETO — const em string/record/array
procedure Salvar(const ACliente: TCliente);
procedure Imprimir(const ANome: string);

// ERRADO — const em interface (quebra ARC → memory leak)
procedure Processar(const AService: IClienteService); // PROIBIDO

// Integer/Boolean/Double — const opcional
procedure Calcular(AValor: Double);
```

---

## §6 — Formatação

```pascal
// Indentação: 2 espaços (sem TAB)
// Margem direita: 120 caracteres
// begin em linha própria
// else em linha própria alinhada ao if

if LCondicao then
begin
  Processar;
end
else
begin
  Cancelar;
end;

// Uma variável por linha
var
  LNome: string;
  LValor: Currency;

// Uma unit por linha na cláusula uses
uses
  System.SysUtils,
  System.Classes,
  Data.DB;
```

Referência completa: `references/formatting.md`

---

## §7 — Estrutura de classes

```pascal
TMinhaClasse = class(TInterfacedObject, IMinhaInterface)
strict private
  FNome: string;
  FValor: Currency;
private
  // membros privados não-strict
protected
  // membros protegidos
public
  constructor Create(const ANome: string);
  destructor Destroy; override;
  function Calcular: Currency;
published
  // apenas componentes visuais
end;
```

Ordem obrigatória: `strict private` → `private` → `protected` → `public` → `published`.
Referência: `references/classes-structure.md`

---

## §8 — Prefixos de componentes VCL/FMX

Exemplos principais (tabela completa em `references/component-prefixes.md`):

| Prefixo | Componente |
|---------|-----------|
| `btn` | TButton |
| `edt` | TEdit |
| `mmo` | TMemo |
| `lbl` | TLabel |
| `cmb` | TComboBox |
| `grd` | TDBGrid / TStringGrid |
| `pnl` | TPanel |
| `frm` | TForm |
| `dm` | TDataModule |
| `qry` | TFDQuery |
| `tbl` | TFDTable |
| `con` | TFDConnection |

---

## §9 — Checklist de qualidade — Standards

- [ ] Todos os fields com prefixo `F`
- [ ] Todos os parâmetros com prefixo `A` (nunca `p`)
- [ ] Todas as variáveis locais com prefixo `L`
- [ ] Constantes com `C_` + MAIÚSCULO
- [ ] Zero ocorrências de `with`, `Break`, `Continue`
- [ ] `Exit` apenas como guard clause no início
- [ ] Indentação de 2 espaços, margem 120 chars
- [ ] `begin` em linha própria
- [ ] Componentes renomeados com prefixo (sem `Button1`, `Edit1`)
- [ ] Zero `Real` — usar `Double` ou `Currency`

## Referências cruzadas

- `developer-delphi-coding-workflow` — escrita de código com padrões aplicados
- `developer-delphi-project-audit` — auditoria de conformidade + code smells
