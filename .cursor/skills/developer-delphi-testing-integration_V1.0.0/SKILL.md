---
name: developer-delphi-testing-integration
description: Testes de integração em Delphi — banco real com rollback automatico (FireDAC/SQLite), fixtures de dados, smoke tests de modulos e testes de regras de negocio cruzando camadas.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-testing-integration

## Versao interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Data** | 11/04/2026 |

## Responsabilidade unica

Esta skill cobre testes de integracao em Delphi que envolvem recursos externos reais: banco de dados SQLite em memoria ou arquivo (via FireDAC) com padrao BEGIN/test/ROLLBACK para isolamento, fixtures de dados reutilizaveis, smoke tests de inicializacao de modulos, e testes de regras de negocio que cruzam multiplas camadas (repositorio + servico + dominio). Ela NÃO cobre testes unitarios com mocks (→ `developer-delphi-testing-dunitx`) e NÃO configura pipeline de CI (→ `developer-delphi-to-fpc-build`).

## When to use

- Verificar que o repositorio salva e le corretamente do banco de dados.
- Testar regras de negocio que dependem de estado persistido (ex.: validacao de duplicidade).
- Executar smoke test: verificar que todos os modulos inicializam sem erro.
- Testar comportamento com banco real (nao mocado) para cobrir casos de SQLite vs. producao.
- Verificar que uma transacao e revertida corretamente em caso de erro.

## When NOT to use

- Nao usar quando o comportamento pode ser testado com mocks → use `developer-delphi-testing-dunitx` (mais rapido).
- Nao usar para performance benchmarks → use `developer-delphi-to-fpc-performance-profiling`.
- Nao usar para testes E2E com UI → escopo diferente; usar ferramenta de automacao de UI.
- Nao usar com banco de producao — sempre usar banco de teste isolado.

## Inputs

- Esquema do banco de dados (DDL das tabelas a testar).
- Regras de negocio a verificar na integracao.
- Fixtures de dados de teste necessarios.

## Estrategia de isolamento — BEGIN/ROLLBACK

A tecnica fundamental para isolamento de testes de banco:

```
[SetupFixture]  → Conectar ao banco de teste; criar schema
[Setup]         → BEGIN TRANSACTION
[Test]          → Executar operacoes; verificar resultados
[TearDown]      → ROLLBACK (desfaz tudo — banco fica limpo para proximo teste)
[TearDownFixture] → Fechar conexao; deletar arquivo SQLite (opcional)
```

Esta tecnica garante que cada teste e independente mesmo com banco real.

## Banco de teste recomendado

| Opcao | Tecnologia | Quando usar |
|-------|-----------|-------------|
| SQLite em memoria | `FDConnection.Params.Database := ':memory:'` | Testes rapidos sem arquivo |
| SQLite em arquivo | `FDConnection.Params.Database := 'test.db'` | Debugar estado entre testes |
| Banco de producao em schema separado | `SET search_path = test_schema` | Compatibilidade maxima |

**Regra:** NUNCA usar banco de producao. SEMPRE usar banco dedicado para testes.

## Workflow executavel

1. **Definir schema de teste** — DDL minimo das tabelas necessarias.
2. **Criar conexao SQLite** — FireDAC com `DriverID=SQLite; Database=:memory:`.
3. **Implementar [SetupFixture]** — conectar e criar tabelas via DDL.
4. **Implementar [Setup]** — `BeginTransaction`.
5. **Implementar [TearDown]** — `Rollback` (SEMPRE, nunca `Commit`).
6. **Escrever fixtures de dados** — metodos `CriarCliente(...)`, `CriarProduto(...)`.
7. **Escrever testes** — exercitar repositorios e servicos; verificar via SELECT.
8. **Implementar [TearDownFixture]** — fechar conexao; deletar arquivo se necessario.

## Dependencias (skills previas)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-testing-dunitx` | Atributos DUnitX e Assert API devem ser conhecidos antes |
| `developer-delphi-to-fpc-build` | Build limpo com FireDAC no Search Path |

## Checklist de testes de integracao

- [ ] Banco de teste e separado do banco de producao
- [ ] Cada teste executa dentro de uma transacao; [TearDown] sempre faz ROLLBACK
- [ ] Schema criado em [SetupFixture]; nao em cada teste
- [ ] Fixtures de dados sao criados via metodos auxiliares, nao hardcoded em cada teste
- [ ] Testes nao dependem de ordem de execucao
- [ ] Smoke test verifica inicializacao de todos os modulos
- [ ] Suite executa com exit code 0 sem banco externo (SQLite in-memory)

## Exemplo minimo compilavel

```pascal
program SampleIntegrationDelphi;
{$APPTYPE CONSOLE}
uses
  System.SysUtils,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Phys.SQLite,
  FireDAC.Comp.Client,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console;

type
  [TestFixture]
  TExemploIntegracaoFixture = class
  private
    FConn: TFDConnection;
  public
    [SetupFixture]
    procedure SetupFixture;
    [TearDownFixture]
    procedure TearDownFixture;
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestInserirEBuscar;
  end;

procedure TExemploIntegracaoFixture.SetupFixture;
begin
  FConn := TFDConnection.Create(nil);
  FConn.DriverName := 'SQLite';
  FConn.Params.Database := ':memory:';
  FConn.Connected := True;
  FConn.ExecSQL('CREATE TABLE itens (id INTEGER PRIMARY KEY, nome TEXT)');
end;

procedure TExemploIntegracaoFixture.TearDownFixture;
begin
  FConn.Free;
end;

procedure TExemploIntegracaoFixture.Setup;
begin
  FConn.StartTransaction;
end;

procedure TExemploIntegracaoFixture.TearDown;
begin
  FConn.Rollback;
end;

procedure TExemploIntegracaoFixture.TestInserirEBuscar;
begin
  FConn.ExecSQL('INSERT INTO itens VALUES (1, ''teste'')');
  var Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text   := 'SELECT nome FROM itens WHERE id=1';
    Q.Open;
    Assert.AreEqual('teste', Q.Fields[0].AsString);
  finally
    Q.Free;
  end;
end;

var
  Runner:  ITestRunner;
  Results: IRunResults;
begin
  TDUnitX.RegisterTestFixture(TExemploIntegracaoFixture);
  Runner  := TDUnitX.CreateRunner;
  Results := Runner.Execute;
  Halt(Ord(not Results.AllPassed));
end.
```

## Anti-padroes

| Anti-padrao | Por que e errado | Como corrigir |
|-------------|-----------------|---------------|
| [TearDown] faz COMMIT | Estado vazado contamina testes subsequentes | Sempre ROLLBACK no [TearDown] |
| Usar banco de producao | Risco de corrupir dados reais | Sempre SQLite in-memory ou banco dedicado de teste |
| Schema criado em cada [Test] | Lento; cada teste recria tabelas | Criar schema UMA vez em [SetupFixture] |
| Fixtures hardcoded em cada teste | Duplicacao; dificil de manter | Extrair em metodos `CriarEntidade(...)` reutilizaveis |
| Testes que dependem de outros | Falha em cascata; ordem importa | Cada teste deve ser independente via ROLLBACK |
| Testar logica que pode ser mockada | Teste de integracao desnecessario | Usar `developer-delphi-testing-dunitx` quando mock e suficiente |

## Metricas de sucesso

- Suite executa com exit code 0 sem banco externo (SQLite in-memory).
- Cada teste e independente: pode ser executado em qualquer ordem.
- [TearDown] sempre faz ROLLBACK — verificado por insercao + rollback + SELECT = 0 rows.
- Smoke test confirma que todos os modulos inicializam sem excecao.

## Responsavel principal

| Papel | Quem |
|-------|------|
| Autor dos testes de integracao | Desenvolvedor do modulo |
| Revisor de isolamento | Par no code review |

## Avaliacao de risco e confirmacao

- Se a suite precisar de banco diferente de SQLite (ex.: PostgreSQL), confirmar disponibilidade no ambiente de CI antes de implementar.
- Nunca executar com banco de producao — parar e confirmar se houver dubvida sobre o connection string.

## Referencias

- `exemplos/db_real_test.pas` — teste contra banco real com rollback
- `exemplos/filesystem_test.pas` — teste com arquivos em pasta temporaria
- `exemplos/smoke_test.pas` — smoke test de modulos
- `consultas_rapidas/integration_vs_unit.md` — quando escrever unit vs integration test
- `consultas_rapidas/db_transaction_rollback.md` — padrao BEGIN + test + ROLLBACK
- `consultas_rapidas/test_data_builders.md` — builder de dados de teste
- `templates/TEMPLATE_integration_db.pas` — integration test com rollback
- `templates/TEMPLATE_http_stub.pas` — stub de servidor HTTP
- FireDAC docs — SQLite in-memory, TFDConnection, TFDTransaction
- `.cursor/skills/developer-delphi-testing-dunitx_V1.0.0/SKILL.md`

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Skill nova — SP-F1 do plano master; cobre testes de integracao com banco real (SQLite/FireDAC), padrao BEGIN/ROLLBACK, fixtures, smoke tests e testes cruzando camadas.
