{Projeto} · RN-M{xx}-{nnn} — Título descritivo da regra | V1.0
====================================================================

{Projeto} · Regra de Negócio

**ID da Regra**: RN-M{xx}-{nnn}
**Módulo**: M{xx} — Nome do Módulo
**Fase**: Fase {n} ({Descrição da fase})
**Prioridade**: Alta / Média / Baixa
**Status**: Proposto / Em detalhamento / Aprovado / Implementado / Testado
**Título**: Título descritivo da regra
**Ref. Arquitetura**: {Documento de Arquitetura} · Cap. {n} §{seção}

## PRÉ-CONDIÇÕES — O que deve ser verdadeiro antes desta regra ser aplicada

1. [Condição que deve ser verdadeira antes da execução desta regra]
2. [Configuração necessária em config/banco/ambiente]
3. [Serviços ou endpoints que devem estar acessíveis]

## FLUXO PRINCIPAL — Sequência feliz (passo a passo quando tudo funciona)

1. [Passo 1 — descrição detalhada da ação, quem faz, resultado]
2. [Passo 2 — dados processados, chamadas, transformações]
3. [Passo 3 — persistência, retorno, evento disparado]

## FLUXOS DE EXCEÇÃO — O que acontece quando algo dá errado

- **E1. [Título da exceção]**
  - `HTTP {código} { "error": "{erro_code}" }`
  - [Ação do sistema / mensagem ao usuário]

- **E2. [Título da exceção]**
  - [Descrição da condição de erro e resposta]

- **E3. [Título da exceção]**
  - [Descrição da condição de erro e resposta]

## VALIDAÇÕES

| Campo / Dado | Condição / Regra | Mensagem de Erro | HTTP |
|---|---|---|---|
| [nome do campo] | [condição que deve ser verdadeira] | [mensagem exibida ao usuário] | [código HTTP] |
| [nome do campo] | [condição] | [mensagem] | [código] |

## TABELAS / CAMPOS DO BANCO DE DADOS

| Tabela | Op. | Campos Relevantes |
|---|---|---|
| `{schema}.{tabela}` | R/W | `campo1`, `campo2`, `campo3` |
| `{schema}.{tabela}` | W | `campo1`, `campo2` |

## IMPACTO EM OUTRAS RNs

- **RN-M{xx}-{yyy}** — [Descrição do impacto e dependência]
- **RN-M{zz}-{www}** — [Descrição do impacto e dependência]

## LGPD — Dados pessoais envolvidos, base legal e prazo de retenção

- **Dados tratados**: [lista de dados pessoais envolvidos]
- **Base legal**: [artigo e inciso da LGPD aplicável]
- **Retenção**: [prazo de retenção e política de expurgo]

## ESBOÇO DE IMPLEMENTAÇÃO — {Stack tecnológica}

```pascal
// {Unit} — {Descrição}
procedure T{Classe}.{Metodo};
begin
  // Esboço de implementação demonstrando o fluxo principal
end;
```

## NOTAS / OBSERVAÇÕES

- [Decisões de design, justificativas, observações relevantes]
- [Parâmetros configuráveis e seus valores padrão]

## Assinaturas

- **Elaborado por**: Equipe {Projeto} — ___/___/______
- **Revisado por**: ___________________ — ___/___/______
- **Aprovado por**: ___________________ — ___/___/______
