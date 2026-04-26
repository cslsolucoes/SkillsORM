# {ClassName}

> {Descricao de uma linha — papel do tipo no projeto.}

**Unit:** `{NomeDaUnit.pas}`
**Tipo:** Interface | Classe | Record | Enum | Exception
**Modulo:** {NomeDoModulo} (`{caminho relativo em src/}`)
**Diretiva:** `{USE_XXX}` ou `{$IFDEF USE_XXX}` ou **Sempre compilado**

**Opcional (Pascal / interface):** **GUID:** `{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}`

**Opcional (classe):** **Tipo base:** `TInterfacedObject` / `TObject` / … **Implementa:** `INomeInterface`

---

## O que e?

{2–4 frases: proposito, papel arquitectural, integracao com outros modulos. Mencionar padroes relevantes — Factory, Fluent, etc.}

---

## Caracteristicas

- **{Nome da caracteristica}** — {descricao breve}
- **{Outra caracteristica}** — {descricao}

---

## Engine

(Omitir esta secao inteira se o tipo for agnostico de engine/driver.)

| Diretiva | Engine / contexto | Suporte |
| --- | --- | --- |
| `{USE_XXX}` | {FireDAC / Zeos / …} | {nota} |

---

## Funcionalidades

### {Grupo — ex.: Metodos publicos, API fluente, CRUD}

| Metodo | Assinatura | Retorno (opcional) | Descricao |
| --- | --- | --- | --- |
| `{Nome}` | `{assinatura completa}` | `{tipo}` | {o que faz} |

### Interface com poucos metodos

Pode usar uma unica tabela **Metodos** (como em `IAttributeMapper.md`):

| Metodo | Assinatura | Retorno | Descricao |
| --- | --- | --- | --- |

---

## Fluxo interno (opcional)

{Passos numerados para o metodo principal ou pipeline critico — quando ajudar a leitura, como em `IAttributeMapper.md` **Fluxo interno do FromClass**.}

1. {Passo}
2. {Passo}

---

## Campos internos (opcional — classes / records)

### private / strict private

| Campo | Tipo | Descricao |
| --- | --- | --- |
| `F{Nome}` | `{tipo}` | {papel} |

---

## Metodos privados / internos (opcional)

| Metodo | Assinatura | Descricao |
| --- | --- | --- |
| `{Nome}` | `{assinatura}` | {papel interno} |

---

## Aplicabilidades

- **{Cenario 1}:** {descricao de uso real}
- **{Cenario 2}:** {descricao}

---

## Exemplos de Uso

### {Titulo do cenario}

```{linguagem}
// Exemplo sintaticamente valido para o stack do projeto
```

---

## Relacionamentos

- [`{OutroClassName}`]({OutroClassName}.md) — {papel da ligacao}
- `{Unit.pas}` — {tipos/unidades externas referenciadas}
- `ORM.Defines.inc` / diretivas — {quando aplicavel}

---

## Codigos de Erro (opcional — exceptions)

| Codigo / constante | Significado |
| --- | --- |
| `{ERR_XXX}` | {descricao} |

---

**Changelog (este arquivo):**

- 1.0.0 (DD/MM/AAAA): Documento gerado a partir de **TEMPLATE_ClassName_Full_Documentation.md**.

---

## Versao interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Politica** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.0 (01/04/2026): Template alinhado a **documentation-class-analysis-generator** (7 secoes + variantes ORM: `IAttributeMapper`, `TEntityManager`).
