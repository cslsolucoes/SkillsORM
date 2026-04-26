# Especificação do Módulo {NomeModulo} (src/Modulos/{NomeModulo})

Documento de referência do módulo **{NomeModulo}** para implementação e manutenção. Inclui estrutura de arquivos, diretivas de compilação e padrões de código. Alinhado ao **Providers ORM v2.0** e às regras em `.cursor/rules/` (Inicial_V1.0.mdc, Documentacao_V1.0.mdc).

**Convenção:** Apenas **descrição e responsabilidade** — sem implementação. Ao alterar código, seguir esta especificação e atualizar **FileVersion**, **Date** e **Changelog (file)** no cabeçalho das units.

---

## 1. Visão Geral

O módulo **{NomeModulo}** (pasta `src/Modulos/{NomeModulo}`) implementa **{IClassName}**, abstração para {propósito}.

**Arquivos atuais:**

| Arquivo | Responsabilidade | Status |
|---------|------------------|--------|
| `{Unit}.Interfaces.pas` | Interface {IClassName} ({lista de métodos principais}). | [ ] A implementar / [X] Implementado |
| `{Unit}.pas` | Implementação {TClassName}; {métodos principais}. | [ ] A implementar / [X] Implementado |

**Consumidores:** {lista de módulos que dependem deste}.

---

## 2. O que está implementado

- **{IClassName}:** {métodos/propriedades implementados}.
- **{TClassName}:** {detalhes de implementação}.
- **Exceções:** {onde e como}.

---

## 3. O que falta (evolução)

1. **{Pendência 1}** — {descrição}.
2. **{Pendência 2}** — {descrição}.

---

## 4. Diretivas de Compilação (ORM.Defines.inc)

### 4.1 Localização e inclusão

- Arquivo: **`ORM.Defines.inc`** na raiz do projeto.
- Cada unit: `{$I ORM.Defines.inc}` após `interface` ou no início.

### 4.2 Diretiva do módulo

- **{USE_MODULO}** — ativa/desativa este módulo.
- Quando ausente: {comportamento sem o módulo}.

### 4.3 Compilador (FPC vs Delphi)

- Uses FPC: `SysUtils, Classes, {unidades FPC}`.
- Uses Delphi: `System.SysUtils, System.Classes, {unidades Delphi}`.

---

## 5. Estrutura de cada arquivo (realidade atual)

### 5.1 {Unit}.Interfaces.pas

- **Uses:** {dependências}.
- **{IClassName}:** {métodos declarados}.

### 5.2 {Unit}.pas

- **Herança:** {TClassName} = class(TInterfacedObject, {IClassName}).
- **Uses:** {dependências}.
- **Campos:** {campos FX principais}.
- **Métodos:** {lista resumida}.

---

## 6. Dependências entre arquivos

```
{Unit}.pas
  ├── {Unit}.Interfaces
  ├── Commons.{Consts/Types/Exceptions}
  └── {outras dependências}
```

---

## 7. Convenções de código

- **Cabeçalho:** bloco `{ ========== ... }` com **Project:** ProvidersORM, **ProjectVersion:** 2.0.0, **FileVersion**, **Author**, **Date**, **Changelog (file)**. Ver [Inicial_V1.0.mdc](../../.cursor/rules/Inicial_V1.0.mdc).
- **Nomenclatura:** {I/TClassName}, {ERR_MODULO_*}, {DEFAULT_*}.
- **Códigos de erro:** {faixa XXX} para {NomeModulo} — [Inicial_V1.0.mdc](../../.cursor/rules/Inicial_V1.0.mdc).

---

## 8. Checklist para manutenção

- [ ] {Item 1 testável}.
- [ ] {Item 2 testável}.
- [ ] Atualizar **FileVersion**, **Date** e **Changelog (file)** no cabeçalho de cada unit alterada.

---

**Referências:** [Inicial_V1.0.mdc](../../.cursor/rules/Inicial_V1.0.mdc) | [Documentacao_V1.0.mdc](../../.cursor/rules/Documentacao_V1.0.mdc) | [.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md](../../.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md) | [ROTEIROS_CONSOLIDADO.md](../../Documentation/ROTEIROS_CONSOLIDADO.md)

---

**Changelog (este arquivo):**

- 1.0.0 (DD/MM/AAAA): Criação da especificação do módulo {NomeModulo}.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
