# Padrao: BEGIN TRANSACTION + Test + ROLLBACK

**Skill:** developer-delphi-testing-integration_V1.0.0

---

## Por que ROLLBACK e nao COMMIT

Em testes de integracao com banco real, o objetivo e:
1. Exercitar o codigo com banco real (verificar SQL, constraints, tipos)
2. Garantir que cada teste comeca com banco limpo
3. Nao acumular dados entre testes (sem "lixo" de runs anteriores)

**ROLLBACK garante:** o banco volta ao estado exato anterior ao teste.
**COMMIT quebraria:** dados inseridos por um teste contaminam os proximos.

---

## Implementacao padrao em DUnitX (FireDAC)

```pascal
type
  [TestFixture]
  TMeuRepositorioTests = class
  private
    FConn: TFDConnection;
    FRepo: TMeuRepositorio;
  public
    [SetupFixture]
    procedure SetupFixture;
    // Executado UMA VEZ: conectar ao banco de teste; criar schema

    [TearDownFixture]
    procedure TearDownFixture;
    // Executado UMA VEZ: fechar conexao; deletar banco de teste

    [Setup]
    procedure Setup;
    // Executado ANTES de cada teste: BEGIN TRANSACTION

    [TearDown]
    procedure TearDown;
    // Executado APOS cada teste: ROLLBACK (SEMPRE — mesmo com falha)

    [Test]
    procedure MeuTeste;
    // Nao precisa limpar — TearDown faz ROLLBACK automaticamente
  end;

procedure TMeuRepositorioTests.SetupFixture;
begin
  FConn := TFDConnection.Create(nil);
  FConn.DriverName := 'SQLite';
  FConn.Params.Database := ':memory:';  // ou 'test.db' para depuracao
  FConn.Connected := True;
  FConn.ExecSQL('CREATE TABLE ...');    // schema de teste
  FRepo := TMeuRepositorio.Create(FConn);
end;

procedure TMeuRepositorioTests.TearDownFixture;
begin
  FRepo.Free;
  FConn.Free;
end;

procedure TMeuRepositorioTests.Setup;
begin
  FConn.StartTransaction;
end;

procedure TMeuRepositorioTests.TearDown;
begin
  FConn.Rollback;  // NUNCA Commit aqui
end;

procedure TMeuRepositorioTests.MeuTeste;
begin
  FRepo.Salvar(...);   // vai para banco real
  var R := FRepo.BuscarPorId(...);
  Assert.AreEqual(..., R.Nome);
  // TearDown fara Rollback automaticamente
end;
```

---

## SQLite in-memory vs. arquivo

| Opcao | Comando | Vantagem | Desvantagem |
|-------|---------|---------|-------------|
| In-memory | `Database=:memory:` | Sem arquivo residual; rapido | Nao persiste entre conexoes |
| Arquivo temp | `Database=test.db` | Inspecionar estado com DB browser | Limpar arquivo apos suite |
| Schema separado | `ATTACH '...'` | Sem dados de producao | Mais complexo |

**Recomendacao:** usar `:memory:` para CI; usar arquivo para depuracao local.

---

## Verificar que ROLLBACK funcionou

Incluir teste de isolamento na suite:

```pascal
[Test]
procedure Isolamento_TabelaDeveEstarVazia;
begin
  // Este teste nao insere nada.
  // Se um [TearDown] anterior nao fez ROLLBACK, esta tabela teria dados.
  var Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text   := 'SELECT COUNT(*) FROM minhaTabela';
    Q.Open;
    Assert.AreEqual(0, Q.Fields[0].AsInteger,
      'Tabela deve estar vazia — ROLLBACK garantido pelo TearDown anterior');
  finally
    Q.Free;
  end;
end;
```

---

## SavePoint para testes aninhados

Para testes que precisam de sub-transacoes:

```pascal
// No [Setup] do teste:
FConn.StartTransaction;
FConn.SavepointStart('sp_teste');

// No [TearDown]:
FConn.SavepointRollback('sp_teste');
FConn.Rollback;
```

Use com cautela — aumenta complexidade; prefira ROLLBACK simples na maioria dos casos.

---

## Checklist de isolamento

- [ ] [Setup] chama `StartTransaction`
- [ ] [TearDown] chama `Rollback` — SEM condicional (sempre)
- [ ] Schema criado em [SetupFixture], nao em [Setup]
- [ ] Teste de isolamento ("tabela deve estar vazia") incluido na suite
- [ ] Nenhum teste depende de dados inseridos por outro teste
- [ ] Banco de producao NUNCA usado (connection string verificada)
