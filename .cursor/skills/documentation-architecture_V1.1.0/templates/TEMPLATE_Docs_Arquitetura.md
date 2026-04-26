# Arquitetura — {Projeto} (visão canônica)

Documento de arquitetura para o ecossistema do projeto **{Projeto}**.

**Versao:** `Vx.y`
**Escopo:** {descrição do que este documento cobre — camadas, integração, padrões}.

---

## 1) Modelo mental (camadas)

1. **{Camada 1 — ex.: UI / Test Forms}**
   - Localização: `{caminho/}`.
   - Responsabilidade: {o que faz; o que não faz}.

2. **{Camada 2 — ex.: APIs públicas dos módulos}**
   - Localização: `{caminho/}`.
   - Responsabilidade: {o que faz}.

3. **{Camada 3 — ex.: Núcleo/Core}**
   - Hierarquia de domínio: `{A → B → C}`.
   - Execução e geração: {descrição}.

4. **{Camada 4 — ex.: Infraestrutura / Transversais}**
   - {Eventos, exceções, commons}.

---

## 2) {Padrão principal — ex.: Modo de conexão}

{Descrição do padrão arquitetural central e suas regras.}

---

## 3) {Aspecto técnico — ex.: Engines / Diretivas}

| Diretiva | Engine / Funcionalidade |
|----------|-------------------------|
| `{DIRETIVA}` | {Descrição} |

Regras:
- {Regra de arquitetura 1}.
- {Regra de arquitetura 2}.

---

## 4) Hierarquia de componentes

```
{ComponenteRaiz}
  ├── {ComponenteA}
  │     └── {ComponenteA1}
  └── {ComponenteB}
```

---

## 5) Fluxo de dados principal

```
{EntradaDados} → {ProcessamentoA} → {ProcessamentoB} → {SaidaDados}
```

---

## 6) Decisões arquiteturais registradas

| ID | Decisão | Motivo | Data |
|----|---------|--------|------|
| DA-01 | {Decisão} | {Motivo} | DD/MM/AAAA |

---

## 7) Restrições e invariantes

- {Restrição 1 — ex.: um engine por compilação}.
- {Restrição 2}.

---

**Referências:** [Inicial_V1.0.mdc](../../.cursor/rules/Inicial_V1.0.mdc) | [roadmap_V1.0.mdc](../../.cursor/rules/roadmap_V1.0.mdc) | [Analise/README.md](../../Analise/README.md)

---

## Parte 2 — Componentes em profundidade

> Para CADA componente-chave do projeto, criar uma secao numerada seguindo o sub-padrao abaixo.
> Referencia de qualidade: `Documentation/ProvidersORM_Overview_Arquitetura.md`.
> Skill de qualidade: `documentation-overview-architecture`.

## {N}. {NomeComponente}

### O que e

{2-4 paragrafos: proposito, padrao de design, papel na arquitetura. Citar Fowler se aplicavel.}

### Analogia (opcional)

{Metafora do mundo real para conceitos complexos — ex: "gerente de armazem" para EntityManager.}

### Por que e necessario

{Problema resolvido. OBRIGATORIO: codigo mostrando cenario SEM o componente.}

```{linguagem}
// SEM {NomeComponente}:
{codigo mostrando o problema}

// COM {NomeComponente}:
{codigo mostrando a solucao}
```

### Definicao tipica / Interface

```{linguagem}
type
  I{NomeComponente} = interface
    // assinaturas completas com tipos de retorno
  end;
```

### Responsabilidades detalhadas

| Responsabilidade | Descricao |
| --- | --- |
| **{Resp1}** | {descricao} |
| **{Resp2}** | {descricao} |

### Sub-secoes numeradas ({N}.1, {N}.2, ...)

{Cada aspecto relevante com codigo e explicacao.}

### Fluxo / Diagrama (ASCII art)

```
┌──────────────┐    SIM    ┌─────────────────┐
│  {Decisao}   │──────────>│ {CaminhoA}      │
└──────┬───────┘           └─────────────────┘
       │ NAO
       ▼
┌──────────────┐
│  {CaminhoB}  │
└──────────────┘
```

### Beneficios

- **{Beneficio1}**: {descricao}.
- **{Beneficio2}**: {descricao}.
- **{Beneficio3}**: {descricao}.

### Consideracoes

- {Caveat sobre memoria, escopo, ciclo de vida, etc.}

---

<!-- Repetir "## {N}. {NomeComponente}" para cada componente -->

---

## Parte 3 — Engines (se multi-engine)

### {N}. {NomeEngine}

#### Visao geral

{1-2 paragrafos: origem, plataforma, licenca.}

#### Caracteristicas

{5-8 bullets com features-chave.}

#### Componentes-chave

| Componente | Funcao |
| --- | --- |
| `{Comp1}` | {funcao} |
| `{Comp2}` | {funcao} |

#### Implementacao da abstracao

```{linguagem}
type
  T{Engine}Connection = class(TInterfacedObject, IDBConnection)
  private
    FConnection: T{ComponenteNativo};
  public
    constructor Create(const AConnectionString: string; ATypeDB: TTypeDatabase);
  end;

constructor T{Engine}Connection.Create(const AConnectionString: string;
  ATypeDB: TTypeDatabase);
begin
  FConnection := T{ComponenteNativo}.Create(nil);
  case ATypeDB of
    td{Alvo1}: FConnection.{Prop} := '{Valor1}';
    td{Alvo2}: FConnection.{Prop} := '{Valor2}';
    // todos os alvos suportados
  end;
end;
```

#### Strengths e limitacoes

| Aspecto | Detalhe |
| --- | --- |
| Plataforma | {plataformas} |
| Licenca | {tipo} |
| Performance | {nivel} |
| Modo direto | {Sim/Nao} |
| Cross-compile | {Sim/Nao} |
| Custo | {info} |

---

<!-- Repetir para cada engine -->

### Comparativo geral das engines

| Criterio | {Engine1} | {Engine2} | {Engine3} | {Engine4} |
| --- | --- | --- | --- | --- |

---

## Parte 4 — {Alvos} (se multi-alvo)

### {N}. {NomeAlvo}

#### Visao geral

{1-2 paragrafos: posicionamento, popularidade.}

#### Caracteristicas relevantes

| Caracteristica | Detalhe |
| --- | --- |
| **{ID generation}** | {mecanismo} |
| **{RETURNING}** | {suporte} |
| **{Schemas}** | {suporte} |
| **{Paginacao}** | {sintaxe} |
| **{Boolean}** | {tipo nativo} |
| **{JSON}** | {suporte} |
| **{Transacoes}** | {nivel} |
| **{Concorrencia}** | {mecanismo} |

#### Dialeto — particularidades

```sql
-- Paginacao
{SELECT ... LIMIT/TOP/FIRST/OFFSET FETCH}

-- Insert com retorno de ID
{INSERT INTO ... RETURNING/OUTPUT/LAST_INSERT_ID()}

-- Boolean
{SELECT ... WHERE ativo = true/1/True}

-- Quoting de identificadores
{SELECT [col] / `col` / "col"}

-- Concatenacao de strings
{|| / CONCAT() / + / &}
```

#### Tipos de dados para mapeamento

| Tipo {Linguagem} | Tipo {NomeAlvo} |
| --- | --- |
| `Integer` | {tipo} |
| `Int64` | {tipo} |
| `string` | {tipo} |
| `Boolean` | {tipo} |
| `TDateTime` | {tipo} |
| `TDate` | {tipo} |
| `TTime` | {tipo} |
| `Currency` | {tipo} |
| `Double` | {tipo} |
| `TBytes` / `TStream` | {tipo} |
| `TGUID` | {tipo} |

---

<!-- Repetir para cada alvo -->

## {N+1}. Comparativo Geral

| Caracteristica | {Alvo1} | {Alvo2} | {Alvo3} | {Alvo4} | {Alvo5} | {Alvo6} |
| --- | --- | --- | --- | --- | --- | --- |

## {N+2}. Factory Pattern — Unificando a Criacao

```{linguagem}
// Codigo completo do factory com case para TODOS os engines/alvos
```

### Uso na aplicacao

```{linguagem}
// Exemplo completo de uso end-to-end
```

## {N+3}. Resumo da Arquitetura

```
┌──────────────────────────────────────────────────┐
│              CAMADA DE APLICACAO                  │
├──────────────────────────────────────────────────┤
│            CAMADA DE ORQUESTRACAO                │
├──────────────────────────────────────────────────┤
│             CAMADA DE ABSTRACAO                  │
├──────────────────────────────────────────────────┤
│               CAMADA DE ENGINE                   │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐            │
│  │{Engine1}│ │{Engine2}│ │{Engine3}│            │
│  └────┬────┘ └────┬────┘ └────┬────┘            │
├───────┼──────────┼──────────┼────────────────────┤
│       │  CAMADA DE {ALVO}   │                    │
│  ┌────▼────┐ ┌────▼────┐ ┌──▼──────┐            │
│  │ {Alvo1} │ │ {Alvo2} │ │ {Alvo3} │            │
│  └─────────┘ └─────────┘ └─────────┘            │
└──────────────────────────────────────────────────┘
```

## {N+4}. Consideracoes Finais

{Paragrafo-resumo listando as qualidades alcancadas: portabilidade, testabilidade, performance, manutenibilidade. Referencia a principios SOLID.}

---

**Changelog (este arquivo):**

- Vx.y (DD/MM/AAAA): {descricao}.
- V1.0 (DD/MM/AAAA): Criacao do documento de arquitetura.

---

## Versao interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.2 |
| **Politica** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.2 (04/04/2026): Adicao de Partes 2-4 com sub-padrao por componente, engine e alvo extraido do gold standard ProvidersORM_Overview_Arquitetura.md. Skill de qualidade: `documentation-overview-architecture`.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (politica: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
