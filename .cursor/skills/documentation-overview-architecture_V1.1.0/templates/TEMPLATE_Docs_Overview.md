# {Projeto} {versao}

> {Descricao em uma linha — tipo do software, linguagem, proposta de valor principal.}

---

## O que e

{2-4 paragrafos: identidade do projeto, compatibilidade (compiladores, plataformas), modo de operacao principal.}

---

## Caracteristicas

- **{Feature 1}** -- {descricao}.
- **{Feature 2}** -- {descricao}.
- **{Feature 3}** -- {descricao}.
- **{Feature 4}** -- {descricao}.
- **{Feature 5}** -- {descricao}.
- **{Feature 6}** -- {descricao}.
- **{Feature 7}** -- {descricao}.
- **{Feature 8}** -- {descricao}.
- **{Feature 9}** -- {descricao}.
- **{Feature 10}** -- {descricao}.
- **{Feature 11}** -- {descricao}.
- **{Feature 12}** -- {descricao}.

---

## Engines

### Engines de {dominio} (um por build)

| Diretiva | Engine | {Compilador1} | {Compilador2} | {Alvos} suportados |
| --- | --- | --- | --- | --- |
| `{DIRETIVA_1}` | {Engine1} | {Sim/Nao} | {Sim/Nao} | {lista de alvos} |
| `{DIRETIVA_2}` | {Engine2} | {Sim/Nao} | {Sim/Nao} | {lista de alvos} |

### Comparativo completo de engines

| Criterio | {Engine1} | {Engine2} | {Engine3} | {Engine4} |
| --- | --- | --- | --- | --- |
| **{Compilador1}** | {Sim/Nao} | {Sim/Nao} | {Sim/Nao} | {Sim/Nao} |
| **{Compilador2}** | {Sim/Nao} | {Sim/Nao} | {Sim/Nao} | {Sim/Nao} |
| **Licenca** | {tipo} | {tipo} | {tipo} | {tipo} |
| **{Alvo1}** | {Sim/Nao} | {Sim/Nao} | {Sim/Nao} | {Sim/Nao} |

### {Alvos} suportados

| {Alvo} | Tipo |
| --- | --- |
| {Alvo1} | {tipo} |
| {Alvo2} | {tipo} |

### Comparativo geral de {alvos}

| Caracteristica | {Alvo1} | {Alvo2} | {Alvo3} | {Alvo4} | {Alvo5} | {Alvo6} |
| --- | --- | --- | --- | --- | --- | --- |
| **Licenca** | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} |
| **{Aspecto1}** | {valor} | {valor} | {valor} | {valor} | {valor} | {valor} |

### Engines de servicos auxiliares

| Tipo | Opcoes |
| --- | --- |
| {Servico1} | {opcoes} |
| {Servico2} | {opcoes} |

---

## Funcionalidades

### Nucleo

Hierarquia de objetos mapeando a estrutura:

```text
{ComponenteA} -> {ComponenteB} -> {ComponenteC} -> {ComponenteD}
```

Camadas auxiliares ativaveis por diretiva:

| Componente | Diretiva | Responsabilidade |
| --- | --- | --- |
| `{Componente1}` | `{USE_XXX}` | {descricao} |
| `{Componente2}` | `{USE_YYY}` | {descricao} |

### {FuncionalidadeA}

{Descricao breve.}

```{linguagem}
{Exemplo de codigo fluente}
```

### {FuncionalidadeB}

{Descricao breve + tabela de metodos.}

---

## Dialetos e mapeamento de tipos por {alvo}

### Paginacao por {alvo}

| {Alvo} | Sintaxe |
| --- | --- |
| {Alvo1} | `{LIMIT 50 OFFSET 100}` |
| {Alvo2} | `{OFFSET 100 ROWS FETCH NEXT 50 ROWS ONLY}` |

### Retorno de ID apos INSERT

| {Alvo} | Mecanismo |
| --- | --- |
| {Alvo1} | `{RETURNING id}` |
| {Alvo2} | `{SELECT LAST_INSERT_ID()}` |

### Quoting de identificadores

| {Alvo} | Abre | Fecha | Exemplo |
| --- | --- | --- | --- |
| {Alvo1} | `"` | `"` | `"schema"."tabela"` |
| {Alvo2} | `[` | `]` | `[schema].[tabela]` |

### Mapeamento de tipos {Linguagem} -> {Alvo}

| Tipo {Linguagem} | {Alvo1} | {Alvo2} | {Alvo3} | {Alvo4} | {Alvo5} | {Alvo6} |
| --- | --- | --- | --- | --- | --- | --- |
| `Integer` | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} |
| `Int64` | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} |
| `string` | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} |
| `Boolean` | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} |
| `TDateTime` | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} |
| `TDate` | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} |
| `TTime` | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} |
| `Currency` | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} |
| `Double` | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} |
| `TBytes` / `TStream` | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} |
| `TGUID` | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} | {tipo} |

### Concatenacao de strings por {alvo}

| {Alvo} | Operador / Funcao |
| --- | --- |
| {Alvo1} | `{operador}` |
| {Alvo2} | `{operador}` |

---

## Modulos e API publica

| Modulo | API publica (`src/Main/`) | Internas (`src/Modulos/`) |
| --- | --- | --- |
| {Modulo1} | `{API1}` | `{Path1}` |
| {Modulo2} | `{API2}` | `{Path2}` |

---

## {Pontos de entrada / Formularios de teste}

| {Ponto} | Proposito |
| --- | --- |
| `{Form1}` | {proposito} |
| `{Form2}` | {proposito} |

---

---

## Modulo {NomeModulo1}

> {Tagline descritiva do modulo em uma linha.}

---

### {NomeModulo1}: O que e

{2-4 paragrafos: proposito, fonte publica, ativacao por diretiva, representacao de dados.}

---

### {NomeModulo1}: Diretivas de compilacao

| Diretiva | Efeito quando ativa |
| --- | --- |
| `{USE_XXX}` | {descricao} |

> {Nota: regra de conflito ou prioridade.}

---

### {NomeModulo1}: Caracteristicas

- **{Feature 1}** -- {descricao}.
- **{Feature 2}** -- {descricao}.
- **{Feature 3}** -- {descricao}.
- **{Feature 4}** -- {descricao}.
- **{Feature 5}** -- {descricao}.
- **{Feature 6}** -- {descricao}.
- **{Feature 7}** -- {descricao}.
- **{Feature 8}** -- {descricao}.

---

### {NomeModulo1}: Engines

#### {Sub-categoria de engines}

| Diretiva / Constante | Engine / Destino | Disponibilidade |
| --- | --- | --- |
| `{DIRETIVA}` | {engine} | {plataforma} |

---

### {NomeModulo1}: Funcionalidades

#### {Sub-grupo funcional}

| Metodo | Descricao |
| --- | --- |
| `{Metodo1}` | {descricao} |
| `{Metodo2}` | {descricao} |

#### Configuracao fluente

```{linguagem}
T{Provedor}.New
  .{Metodo1}('{valor}')
  .{Metodo2}({valor})
  .Connect;
```

#### Excepcoes do modulo

| Faixa | Classe | Categoria |
| --- | --- | --- |
| {faixa} | `{EClasse}` | {categoria} |

---

<!-- Repetir o bloco "## Modulo {NomeModuloN}" para cada modulo adicional -->

---

## Resumo de diretivas de compilacao por modulo

| Modulo | Diretiva de ativacao | Diretivas adicionais |
| --- | --- | --- |
| **{Modulo1}** | `{USE_XXX}` | {lista} |
| **{Modulo2}** | *(sempre compilado)* | {lista} |

---

## Changelog (este arquivo)

- {versao} (DD/MM/AAAA): Criacao do documento de visao geral.

---

## Versao interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Politica** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.0 (04/04/2026): Versionamento interno inicial (pacote `.cursor`).
