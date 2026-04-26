# Unit Test vs. Integration Test — Quando usar cada um

**Skill:** developer-delphi-testing-integration_V1.0.0

---

## Piramide de testes

```
         /\
        /E2E\          <- Poucos; lentos; custosos
       /------\
      /Integra-\       <- Moderado; verifica camadas juntas
     /  cao     \
    /------------\
   / Unit Tests   \    <- Muitos; rapidos; isolados
  /________________\
```

**Regra de ouro:** mais unitarios, menos integracao, muito menos E2E.

---

## Comparativo

| Aspecto | Unit Test | Integration Test |
|---------|-----------|-----------------|
| Velocidade | Muito rapido (< 1ms/teste) | Moderado (10ms–1s/teste) |
| Dependencias | Mockadas/stubadas | Reais (banco, arquivo, rede) |
| Isolamento | Total (cada teste e independente) | Parcial (ROLLBACK/cleanup obrigatorio) |
| O que verifica | Comportamento de UMA unidade | Colaboracao entre camadas |
| Quando falha | Facil isolar a causa | Pode ser falha em qualquer camada |
| Custo de manutencao | Baixo | Medio-alto |
| Ferramenta Delphi | DUnitX + mocks | DUnitX + FireDAC + SQLite |

---

## Criterios de decisao

### Usar UNIT TEST quando:

- A logica e pura (sem I/O, banco, arquivo, rede)
- A dependencia pode ser mockada com interface
- O comportamento pode ser verificado sem estado externo
- O caso de teste e simples e bem definido (happy path, edge cases)

**Exemplos:**
- Validar formato de CPF/CNPJ
- Calcular desconto por categoria
- Parsear JSON de entrada
- Formatar moeda para exibicao

### Usar INTEGRATION TEST quando:

- O comportamento depende de banco de dados real (constraints, triggers, cascade)
- Varios modulos precisam colaborar para produzir o resultado
- O comportamento com dados reais difere do mock (ex.: ORDER BY, NULL handling)
- Verificar que o schema do banco esta correto para as queries

**Exemplos:**
- Repositorio salva e recupera cliente corretamente do banco
- Regra de unicidade de email e aplicada pelo banco
- Transacao cruzando 2 tabelas e atomica
- Arquivo gerado tem encoding correto

### Usar SMOKE TEST quando:

- Verificar que todos os modulos inicializam (gate de sanidade no CI)
- Verificar que a configuracao de producao nao quebra na inicializacao
- Gate rapido antes de suite mais demorada

---

## Custo de um test mal categorizado

| Problema | Consequencia |
|----------|-------------|
| Integration test quando unit seria suficiente | Suite lenta; dependencia de banco em CI |
| Unit test mockado quando banco importa | Falsa seguranca; bugs de SQL em producao |
| Nenhum smoke test | Problemas de inicializacao descobertos tarde |

---

## Distribuicao recomendada

Para um modulo de repositorio tipico:

```
70% — Unit tests (logica de negocio, validacoes, formatacoes)
25% — Integration tests (repositorio, transacoes, joins)
 5% — Smoke tests (inicializacao, configuracao)
```
